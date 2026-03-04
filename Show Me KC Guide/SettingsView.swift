//
//  SettingsView.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/28/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var languageManager = LanguageManager()
    @State private var languageChanged = false
    @State private var localizationRefresh = LocalizationRefresh()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("settings_language_picker".localized, selection: $languageManager.selectedLanguage) {
                        ForEach(Language.allLanguages) { language in
                            Text(language.nativeName)
                                .tag(language)
                        }
                    }
                    .onChange(of: languageManager.selectedLanguage) { oldValue, newValue in
                        languageManager.setLanguage(newValue)
                        languageChanged = true
                    }
                } header: {
                    Text("settings_app_language_header".localized)
                } footer: {
                    if languageChanged {
                        Text("settings_language_changed_message".localized)
                            .foregroundStyle(.green)
                    }
                }
            }
            .navigationTitle("settings_nav_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
