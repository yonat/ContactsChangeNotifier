//
//  CloudKitHistoryTokenStorage.swift
//  ContactsChangeNotifier
//
//  Created by JP Toro on 10/19/24.
//

import Foundation

/// A concrete implementation of `HistoryTokenStorage` that uses CloudKit (NSUbiquitousKeyValueStore) for storing history tokens.
public final class CloudKitHistoryTokenStorage: HistoryTokenStorage {
    public var tokenData: Data? {
        get {
            NSUbiquitousKeyValueStore.default.data(forKey: lastHistoryTokenUserDefaultsKey)
        }
        set {
            NSUbiquitousKeyValueStore.default.set(newValue, forKey: lastHistoryTokenUserDefaultsKey)
        }
    }
}

public extension HistoryTokenStorage where Self == CloudKitHistoryTokenStorage {
    /// Creates a CloudKitHistoryTokenStorage instance using the default iCloud key-value store.
    static var iCloudKeyValueStore: CloudKitHistoryTokenStorage { CloudKitHistoryTokenStorage() }
}
