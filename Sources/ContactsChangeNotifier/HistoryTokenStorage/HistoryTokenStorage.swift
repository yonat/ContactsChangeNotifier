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
public protocol HistoryTokenStorage: Sendable, AnyObject {
    /// A `Data` object representing the history token, or `nil` if no token is stored.
    var tokenData: Data? { get set }
}
