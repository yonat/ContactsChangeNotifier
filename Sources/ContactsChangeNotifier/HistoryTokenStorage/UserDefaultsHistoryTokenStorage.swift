//
//  UserDefaultsHistoryTokenStorage.swift
//  ContactsChangeNotifier
//
//  Created by JP Toro on 10/19/24.
//

import Foundation

/// A concrete implementation of `HistoryTokenStorage` that uses UserDefaults for storing history tokens.
public final class UserDefaultsHistoryTokenStorage: HistoryTokenStorage {
    /// The name of the UserDefaults suite to use.
    private let suiteName: String?

    /// Initializes a new instance of `UserDefaultsHistoryTokenStorage`.
    ///
    /// - Parameter suiteName: The name of the UserDefaults suite to use. Default is `nil`.
    public init(suiteName: String? = nil) {
        self.suiteName = suiteName
    }

    public var tokenData: Data? {
        get {
            UserDefaults(suiteName: suiteName)?.data(forKey: lastHistoryTokenUserDefaultsKey)
        }
        set {
            UserDefaults(suiteName: suiteName)?.set(newValue, forKey: lastHistoryTokenUserDefaultsKey)
        }
    }
}

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
