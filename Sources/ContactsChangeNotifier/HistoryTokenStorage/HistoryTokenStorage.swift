//
//  HistoryTokenStorage.swift
//  ContactsChangeNotifier
//
//  Created by JP Toro on 9/28/24.
//

import Foundation

/// The key used to store the last history token in UserDefaults or NSUbiquitousKeyValueStore.
let lastHistoryTokenUserDefaultsKey = "ContactsChangeNotifier.lastHistoryToken"

/// A protocol for managing the storage of history tokens returned from `CNChangeHistoryFetchRequest`.
///
/// Conform to `HistoryTokenStorage` to implement custom storage for these tokens.
public protocol HistoryTokenStorage: Sendable {
    /// Retrieves the stored history token.
    ///
    /// - Returns: A `Data` object representing the history token, or `nil` if no token is stored.
    func getHistoryToken() -> Data?

    /// Stores or updates the history token.
    ///
    /// - Parameter token: The `Data` object to store as the history token. Pass `nil` to remove the token.
    func setHistoryToken(_ token: Data?)
}

/// Extension to provide convenient static accessors for UserDefaultsHistoryTokenStorage
public extension HistoryTokenStorage where Self == UserDefaultsHistoryTokenStorage {
    /// Creates a UserDefaultsHistoryTokenStorage instance using the standard UserDefaults.
    static var userDefaults: UserDefaultsHistoryTokenStorage { UserDefaultsHistoryTokenStorage() }

    /// Creates a UserDefaultsHistoryTokenStorage instance with a specific suite name.
    /// - Parameter suiteName: The name of the UserDefaults suite to use.
    /// - Returns: A UserDefaultsHistoryTokenStorage instance configured with the specified suite name.
    static func userDefaults(suiteName: String) -> UserDefaultsHistoryTokenStorage {
        UserDefaultsHistoryTokenStorage(suiteName: suiteName)
    }
}

/// Extension to provide a convenient static accessor for CloudKitHistoryTokenStorage
public extension HistoryTokenStorage where Self == CloudKitHistoryTokenStorage {
    /// Creates a CloudKitHistoryTokenStorage instance using the default iCloud key-value store.
    static var iCloudKeyValueStore: CloudKitHistoryTokenStorage { CloudKitHistoryTokenStorage() }
}
