//
//  LandingView.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/21/26.
//
//  DEPRECATED: This view is no longer used as the app entry point.
//  Language selection has been moved to Settings (accessible from ContentView).
//  This file can be deleted after migrating language selection to SettingsView.
//

import SwiftUI

@available(*, deprecated, message: "Use SettingsView for language selection instead")
struct LandingView: View {
    @State private var languageManager = LanguageManager()
    @State private var showMap = false
    
    var body: some View {
        landingContent
            .fullScreenCover(isPresented: $showMap) {
                ContentView()
            }
    }
    
    private var landingContent: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Title
            VStack(spacing: 12) {
                Text("Show Me KC")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Kansas City Guide")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Language Picker
            VStack(alignment: .leading, spacing: 12) {
                Text("choose_language")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Menu {
                    ForEach(Language.allLanguages) { language in
                        Button {
                            languageManager.setLanguage(language)
                        } label: {
                            HStack {
                                Text(language.nativeName)
                                if languageManager.selectedLanguage.id == language.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(languageManager.selectedLanguage.nativeName)
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Continue Button
            Button {
                showMap = true
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.blue, in: Capsule())
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    LandingView()
}
