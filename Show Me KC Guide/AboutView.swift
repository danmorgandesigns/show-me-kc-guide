//
//  AboutView.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/28/26.
//

import SwiftUI

struct AboutView: View {
    @State private var localizationRefresh = LocalizationRefresh()
    @Environment(\.dismiss) var dismiss
    
    // Determine if current language is RTL
    private var isRTL: Bool {
        let languageCode = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        return ["ar", "he", "fa", "ur"].contains(languageCode)
    }
    
    private var textAlignment: HorizontalAlignment {
        isRTL ? .trailing : .leading
    }
    
    private var frameAlignment: Alignment {
        isRTL ? .trailing : .leading
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Centered title section
                    VStack(spacing: 8) {
                        Text("Show Me KC Guide")
                            .font(.title)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        Text("about_tagline".localized)
                            .font(.body)
                            .fontWeight(.regular)
                            .italic()
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 14)
                    
                    Divider()
                        .padding(.top, 6)

                    VStack(alignment: textAlignment, spacing: 6) {
                        Text("about_paragraph1".localized)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: frameAlignment)

                        Text("about_paragraph2".localized)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: frameAlignment)

                        Text("about_paragraph3".localized)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: frameAlignment)
                    }
                    .padding(.horizontal, 18)
                    .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
                

                    Divider()
                        .padding(.bottom, 6)
                    
                    // Centered "Created by:" text
                    Text("about_created_by".localized)
                        .font(.headline)
                        .padding(.top, 6)
                    
                    // Logo centered
                    Link(destination: URL(string: "https://danmorgandesigns.com")!) {
                        Image("dmd-full-outlines")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 120)
                            .padding(.vertical, 6)
                    }
                    
                    // Contact info centered
                    VStack(alignment: .center) {
                        Text("©2026 Dan Morgan Designs LLC")
                            .font(.caption)
                        Text("Overland Park, KS")
                            .font(.caption)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("about_nav_title".localized)
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
    AboutView()
}

