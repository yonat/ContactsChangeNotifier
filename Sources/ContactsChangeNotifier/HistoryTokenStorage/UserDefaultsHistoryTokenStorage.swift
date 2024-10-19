//
//  UserDefaultsHistoryTokenStorage.swift
//  ContactsChangeNotifier
//
//  Created by JP Toro on 10/19/24.
//

import Foundation

/// A concrete implementation of `HistoryTokenStorage` that uses UserDefaults for storing history tokens.
public struct UserDefaultsHistoryTokenStorage: HistoryTokenStorage {
    /// The name of the UserDefaults suite to use.
    private let suiteName: String?

    /// Initializes a new instance of `UserDefaultsHistoryTokenStorage`.
    ///
    /// - Parameter suiteName: The name of the UserDefaults suite to use. Default is `nil`.
    public init(suiteName: String? = nil) {
        self.suiteName = suiteName
    }

    public func getHistoryToken() -> Data? {
        UserDefaults(suiteName: suiteName)?.data(forKey: lastHistoryTokenUserDefaultsKey)
    }

    public func setHistoryToken(_ token: Data?) {
        UserDefaults(suiteName: suiteName)?.set(token, forKey: lastHistoryTokenUserDefaultsKey)
    }
}
