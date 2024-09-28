//
//  ContactsChangeNotifier.swift
//
//  Created by Yonat Sharon on 10/07/2022.
//

@preconcurrency import Contacts
import UIKit

#if !COCOAPODS
import ContactStoreChangeHistory
#endif

public extension Notification {
    internal static let contactsChangeEventsKey = "ContactsChangeEvents"
    
    /// Contacts change events in a ``ContactsChangeNotifier.didChangeNotification``
    var contactsChangeEvents: [CNChangeHistoryEvent]? {
        userInfo?[Self.contactsChangeEventsKey] as? [CNChangeHistoryEvent]
    }
}

public extension CNChangeHistoryFetchRequest {
    /// Creates a request with sensible defaults:
    /// Only retrieve contact identifiers, and ignore changes with the `transactionAuthor == Bundle.main.bundleIdentifier`.
    /// Pass parameters to override defaults.
    static func fetchRequest(
        shouldUnifyResults: Bool = true,
        excludedTransactionAuthors: [String]? = Bundle.main.bundleIdentifier.flatMap { [$0] },
        additionalContactKeyDescriptors: [CNKeyDescriptor] = []
    ) -> CNChangeHistoryFetchRequest {
        let request = CNChangeHistoryFetchRequest()
        request.shouldUnifyResults = shouldUnifyResults
        request.excludedTransactionAuthors = excludedTransactionAuthors
        request.additionalContactKeyDescriptors = additionalContactKeyDescriptors
        return request
    }
}

/// Posts notifications of *external* changes in Contacts (i.e., changes made outside the app). **Note**: Requires user contacts authorization.
///
/// To use, keep a`ContactsChangeNotifier` object, and observe ``ContactsChangeNotifier.didChangeNotification`` notifications.
///
/// Example:
///
/// ```swift
/// let notifier = ContactsChangeNotifier(store: myCNContactStore)
///
/// init() {
///     NotificationCenter.default.addObserver(
///         self,
///         selector: #selector(contactsStoreChanged), // func that handles change notifications
///         name: ContactsChangeNotifier.didChangeNotification,
///         object: nil
///     )
/// }
/// ```
final class ContactsChangeNotifier: NSObject, Sendable {
    /// Posted when *external* changes occur in Contacts (i.e., changes made outside the app). Includes `contactsChangeEvents` with all changes.
    ///
    /// Replaces `CNContactStoreDidChange` which is called both for internal changes and for phantom echoes of changes.
    public static let didChangeNotification = Notification.Name("ContactsChangeNotifier.didChangeNotification")
    
    public let store: CNContactStore
    
    /// Spec of which changes to observe.
    ///
    /// `startingToken` is ignored: `lastHistoryToken` will be automatically used.
    ///
    /// Use `.fetchRequest()` for sensible defaults.
    public let fetchRequest: CNChangeHistoryFetchRequest
    
    public enum HistoryTokenStorageType: Sendable {
        case userDefaults(suiteName: String? = nil)
        case iCloudKeyValueStore
        case custom(HistoryTokenStorage)
        
        private static let lastHistoryTokenUserDefaultsKey = "ContactsChangeNotifier.lastHistoryToken"
        
        func getHistoryToken() -> Data? {
            switch self {
            case .userDefaults(suiteName: let suiteName):
                UserDefaults(suiteName: suiteName)?.data(forKey: Self.lastHistoryTokenUserDefaultsKey)
            case .iCloudKeyValueStore:
                NSUbiquitousKeyValueStore.default.data(forKey: Self.lastHistoryTokenUserDefaultsKey)
            case .custom(let storage):
                storage.getHistoryToken()
            }
        }
        
        func setHistoryToken(_ token: Data?) {
            switch self {
            case .userDefaults(let suiteName):
                UserDefaults(suiteName: suiteName)?.set(token, forKey: Self.lastHistoryTokenUserDefaultsKey)
            case .iCloudKeyValueStore:
                NSUbiquitousKeyValueStore.default.set(token, forKey: Self.lastHistoryTokenUserDefaultsKey)
            case .custom(let storage):
                storage.setHistoryToken(token)
            }
        }
    }
    
    /// The location where `lastHistoryToken` is stored.
    public let historyTokenStorage: HistoryTokenStorageType
    
    /// Used as `startingToken` when fetching Contacts change history.
    /// Updated after every fetch, to avoid getting the same changes over and over again.
    public var lastHistoryToken: Data? {
        get { historyTokenStorage.getHistoryToken() }
        set { historyTokenStorage.setHistoryToken(newValue) }
    }
    
    /// Create a notifier of *external* changes in Contacts (i.e., changes made outside the app). **Note**: Requires user contacts authorization.
    ///
    /// > Warning: To use `iCloudKeyValueStore` as the `lastHistoryToken` storage type,
    /// > add "iCloud" to "Signing & Capabilities" and enable "Key-value storage".
    ///
    /// - Parameters:
    ///   - store: The contacts store to use
    ///   - historyTokenStorage: The location where `lastHistoryToken` is stored
    ///   - fetchRequest: Optional spec of which changes to observe.
    ///
    ///     `fetchRequest.startingToken` is ignored, `lastHistoryToken` will be used instead.
    public init(
        store: CNContactStore,
        historyTokenStorage: HistoryTokenStorageType = .userDefaults(),
        fetchRequest: CNChangeHistoryFetchRequest = .fetchRequest()
    ) throws {
        self.store = store
        self.historyTokenStorage = historyTokenStorage
        self.fetchRequest = fetchRequest
        super.init()
        Task {
            try await setupContactStore()
        }
    }
    
    /// Get changes in Contacts.
    /// - Parameter fetchRequest: Optional change history request.
    ///   By default, uses `self.fetchRequest` with `lastHistoryToken`, so will return only changes made since the last call.
    ///   Passing a request with nil `startingToken` will return all contacts and groups.
    /// - Returns: An enumerator of ``CNChangeHistoryEvent`` objects.
    public func changeHistory(fetchRequest: CNChangeHistoryFetchRequest? = nil) throws -> NSEnumerator {
        let fetchRequest = fetchRequest ?? {
            self.fetchRequest.startingToken = lastHistoryToken
            return self.fetchRequest
        }()
        var error: NSError?
        let fetchResult = store.swiftEnumerator(for: fetchRequest, error: &error)
        if let error = error { throw error }
        return fetchResult.value
    }
    
    // MARK: - Privates
    
    @MainActor private var observation: NSObjectProtocol?
    
    private func setupContactStore() async throws {
        try await store.requestAccess(for: .contacts)
        
        // wake up store, otherwise change notification not received
        _ = store.defaultContainerIdentifier()
        
        // don't get changes that occurred before app was ever run
        if nil == lastHistoryToken {
            lastHistoryToken = store.currentHistoryToken
        } else { // get changes since the last update
            Task.detached(priority: .background) { [weak self] in
                self?.forwardChangeHistoryEvents()
            }
        }
        
        await MainActor.run {
            observation = NotificationCenter.default.addObserver(
                forName: .CNContactStoreDidChange,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                self?.contactsStoreChanged(isExternal: notification.isContactsStoreChangeExternal)
            }
        }
    }
    
    @Sendable @objc private func contactsStoreChanged(isExternal: Bool) {
        // avoid phantom echoes of internal changes by checking `applicationState`:
        //   .background => called from background refresh => external change
        //   .inactive => called when app opened => external change
        //   .active => regular app execution => internal change
        Task { @MainActor in
            guard isExternal, !applicateStateIsActive() else {
                lastHistoryToken = store.currentHistoryToken
                return
            }
            
            Task.detached(priority: .background) { [weak self] in
                self?.forwardChangeHistoryEvents()
            }
        }
    }
    
    @MainActor
    private func applicateStateIsActive() -> Bool {
        UIApplication.safeShared?.applicationState == .active
    }
    
    /// Get contacts change events and post them in a `didChangeNotification`
    private func forwardChangeHistoryEvents() {
        do {
            let changes = try changeHistory()
            lastHistoryToken = store.currentHistoryToken
            let changeHistoryEvents = changes.compactMap { $0 as? CNChangeHistoryEvent }
            guard !changeHistoryEvents.isEmpty else { return }
            Task { @MainActor [weak self] in
                self?.postNotification(changeHistoryEvents: changeHistoryEvents)
            }
        } catch {
            #if DEBUG
            print("ContactsChangeNotifier failed to get Contacts change history:", error.localizedDescription)
            #endif
        }
    }
    
    private func postNotification(changeHistoryEvents: [CNChangeHistoryEvent]) {
        NotificationCenter.default.post(
            name: Self.didChangeNotification,
            object: self,
            userInfo: [Notification.contactsChangeEventsKey: changeHistoryEvents]
        )
    }
}

// Applies to .CNContactStoreDidChange
private extension Notification {
    /// (Undocumented) Did the change originate outside the app
    var isContactsStoreChangeExternal: Bool {
        nil != userInfo?["CNNotificationOriginationExternally"]
    }
    
    /// (Undocumented) Empty for external-to-app changes, some `CNDataMapperContactStore` for internal changes.
    var contactsStoreChangeSources: NSArray {
        userInfo?["CNNotificationSourcesKey"] as? NSArray ?? []
    }
    
    /// (Undocumented) Empty for external-to-app changes, something like `["CA37C0B8-85A0-49BF-A03B-3F3C40C2CF8E"]` for internal changes.
    var contactsStoreChangeIdentifiers: [String] {
        (userInfo?["CNNotificationSaveIdentifiersKey"] as? NSArray ?? [])
            .compactMap { $0 as? String }
    }
}

// From https://stackoverflow.com/a/69153780/1176162
extension UIApplication {
    static var safeShared: UIApplication? {
        guard UIApplication.responds(to: Selector(("sharedApplication"))) else {
            return nil
        }
        
        guard let unmanagedSharedApplication = UIApplication.perform(Selector(("sharedApplication"))) else {
            return nil
        }
        
        return unmanagedSharedApplication.takeUnretainedValue() as? UIApplication
    }
}
