//
//  ContactsChangeNotifier.swift
//
//  Created by Yonat Sharon on 10/07/2022.
//

import Contacts
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
open class ContactsChangeNotifier: NSObject {
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
    public var fetchRequest: CNChangeHistoryFetchRequest

    /// Used as `startingToken` when fetching Contacts change history.
    /// Updated after every fetch, to avoid getting the same changes over and over again.
    public var lastHistoryToken: Data? {
        get { UserDefaults.standard.data(forKey: lastHistoryTokenUserDefaultsKey) }
        set { UserDefaults.standard.set(newValue, forKey: lastHistoryTokenUserDefaultsKey) }
    }

    /// Create a notifier of *external* changes in Contacts (i.e., changes made outside the app). **Note**: Requires user contacts authorization.
    /// - Parameters:
    ///   - store: The contacts store to use
    ///   - fetchRequest: Optional spec of which changes to observe.
    ///
    ///     `fetchRequest.startingToken` is ignored, `lastHistoryToken` will be used instead.
    public init(store: CNContactStore, fetchRequest: CNChangeHistoryFetchRequest = .fetchRequest()) throws {
        self.store = store
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
        lastHistoryToken = fetchResult.currentHistoryToken
        return fetchResult.value
    }

    // MARK: - Privates

    private let lastHistoryTokenUserDefaultsKey = "ContactsChangeNotifier.lastHistoryToken"

    private func setupContactStore() async throws {
        try await store.requestAccess(for: .contacts)

        // wake up store, otherwise change notification not received
        _ = store.defaultContainerIdentifier()

        // don't get changes that occurred before app was ever run
        if nil == lastHistoryToken {
            lastHistoryToken = store.currentHistoryToken
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contactsStoreChanged),
            name: .CNContactStoreDidChange,
            object: nil
        )
    }

    @objc private func contactsStoreChanged(notification: Notification) throws {
        // avoid phantom echoes of internal changes by checking `applicationState`:
        //   .background => called from background refresh => external change
        //   .inactive => called when app opened => external change
        //   .active => regular app execution => internal change
        guard UIApplication.shared.applicationState != .active else { return }
        guard notification.contactsStoreChangeExternal else { return }

        // if there are new external changes, post them in a didChangeNotification
        let changes = try changeHistory()
        let changeHistoryEvents = changes.compactMap { $0 as? CNChangeHistoryEvent }
        guard !changeHistoryEvents.isEmpty else { return }
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
    var contactsStoreChangeExternal: Bool {
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