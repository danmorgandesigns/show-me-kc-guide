//
//  LanguageManager.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/21/26.
//

import Foundation
import SwiftUI

struct Language: Identifiable, Hashable {
    let id: String
    let code: String
    let name: String
    let nativeName: String
    
    static let allLanguages: [Language] = [
        Language(id: "en", code: "en", name: "English (US)", nativeName: "English (US)"),
        Language(id: "ar", code: "ar", name: "Arabic", nativeName: "العربية"),
        Language(id: "de", code: "de", name: "German", nativeName: "Deutsch"),
        Language(id: "en-GB", code: "en-GB", name: "English (UK)", nativeName: "English (UK)"),
        Language(id: "es", code: "es", name: "Spanish", nativeName: "Español"),
        Language(id: "fr", code: "fr", name: "French", nativeName: "Français"),
        Language(id: "nl", code: "nl", name: "Dutch", nativeName: "Nederlands"),
        Language(id: "pt", code: "pt", name: "Portuguese", nativeName: "Português")
    ]
}

@Observable
class LanguageManager {
    var selectedLanguage: Language
    
    init() {
        // Get saved language or default to device language
        let savedCode = UserDefaults.standard.string(forKey: "app_language") 
            ?? Locale.current.language.languageCode?.identifier 
            ?? "en"
        
        self.selectedLanguage = Language.allLanguages.first { $0.code == savedCode } 
            ?? Language.allLanguages[0]
    }
    
    func setLanguage(_ language: Language) {
        selectedLanguage = language
        UserDefaults.standard.set(language.code, forKey: "app_language")
        
        // Post notification to trigger UI refresh
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
}
