//
//  LocalizationHelper.swift
//  Show Me KC Guide
//
//  Created to handle custom language selection that overrides system settings
//

import Foundation
import SwiftUI

/// Custom Bundle subclass that returns localized strings based on app's language preference
class LocalizedBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        // Get the current language code from UserDefaults
        let languageCode = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        
        // Get the path to the .lproj directory for the selected language
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fall back to English if the language bundle isn't found
            if let fallbackPath = Bundle.main.path(forResource: "en", ofType: "lproj"),
               let fallbackBundle = Bundle(path: fallbackPath) {
                return fallbackBundle.localizedString(forKey: key, value: value, table: tableName)
            }
            return key
        }
        
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

/// Extension to String to provide custom localized string lookup
extension String {
    /// Returns a localized string using the app's selected language from LanguageManager
    var localized: String {
        let languageCode = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        
        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fall back to English
            if let fallbackPath = Bundle.main.path(forResource: "en", ofType: "lproj"),
               let fallbackBundle = Bundle(path: fallbackPath) {
                return NSLocalizedString(self, tableName: nil, bundle: fallbackBundle, comment: "")
            }
            return self
        }
        
        return NSLocalizedString(self, tableName: nil, bundle: bundle, comment: "")
    }
}

/// Observable class to trigger view refreshes when language changes
@Observable
class LocalizationRefresh {
    var languageCode: String = UserDefaults.standard.string(forKey: "app_language") ?? "en"
    
    init() {
        // Listen for language change notifications
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("LanguageChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.languageCode = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        }
    }
}
