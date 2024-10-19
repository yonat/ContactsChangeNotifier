//
//  CloudKitHistoryTokenStorage.swift
//  ContactsChangeNotifier
//
//  Created by JP Toro on 10/19/24.
//

import Foundation

/// A concrete implementation of `HistoryTokenStorage` that uses CloudKit (NSUbiquitousKeyValueStore) for storing history tokens.
public struct CloudKitHistoryTokenStorage: HistoryTokenStorage {
    public func getHistoryToken() -> Data? {
        NSUbiquitousKeyValueStore.default.data(forKey: lastHistoryTokenUserDefaultsKey)
    }

    public func setHistoryToken(_ token: Data?) {
        NSUbiquitousKeyValueStore.default.set(token, forKey: lastHistoryTokenUserDefaultsKey)
    }
}

public extension HistoryTokenStorage where Self == CloudKitHistoryTokenStorage {
    /// Creates a CloudKitHistoryTokenStorage instance using the default iCloud key-value store.
    static var iCloudKeyValueStore: CloudKitHistoryTokenStorage { CloudKitHistoryTokenStorage() }
}
