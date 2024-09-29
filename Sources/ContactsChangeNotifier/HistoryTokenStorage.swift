//
//  HistoryTokenStorage.swift
//  ContactsChangeNotifier
//
//  Created by Joshua Toro on 9/28/24.
//

import Foundation

/// A protocol for managing the storage of history tokens returned from `CNChangeHistoryFetchRequest`.
///
/// Conform to `HistoryTokenStorage` to implement custom storage for these tokens.
///
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
