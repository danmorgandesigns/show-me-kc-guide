//
//  PlacesLoader.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/18/26.
//

import Foundation
import CoreLocation

enum ItineraryLoader {
    /// All supported language codes for suffix detection
    private static let supportedLanguages = ["en", "es", "ar", "de", "en-GB", "fr", "nl", "pt-BR", "pt"]
    
    /// Current language code for the app (can be overridden by user preference)
    static var currentLanguage: String {
        // Check for user override first
        if let override = UserDefaults.standard.string(forKey: "app_language") {
            return override
        }
        // Fall back to device language
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    /// Load a single itinerary with language fallback
    /// Tries: itin_name_es.json -> itin_name.json (English default)
    static func load(from filename: String) -> Itinerary? {
        let baseFilename = filename.replacingOccurrences(of: "itin_", with: "")
        let language = currentLanguage
        
        print("ItineraryLoader.load - filename: \(filename), language: \(language)")
        
        // Try localized version first (e.g., "itin_plaza_es")
        if language != "en" {
            let localizedFilename = "itin_\(baseFilename)_\(language)"
            print("ItineraryLoader.load - Trying localized: \(localizedFilename)")
            if let itinerary = loadFile(localizedFilename) {
                print("ItineraryLoader.load - Found localized file!")
                return itinerary
            }
            print("ItineraryLoader.load - Localized file not found, falling back to: \(filename)")
        }
        
        // Fall back to English/default version
        return loadFile(filename)
    }
    
    /// Load all itineraries in the current language
    static func loadAll(matching prefix: String = "itin_") -> [Itinerary] {
        guard let bundleURL = Bundle.main.resourceURL else { return [] }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: bundleURL,
                includingPropertiesForKeys: nil
            )
            
            // Get all base itinerary names (without language suffix)
            let baseNames = Set(fileURLs
                .filter { $0.pathExtension == "json" && $0.lastPathComponent.hasPrefix(prefix) }
                .map { url -> String in
                    let name = url.deletingPathExtension().lastPathComponent
                    // Remove language suffix if present (e.g., "itin_plaza_es" -> "itin_plaza")
                    // Check against all supported language codes
                    for langCode in supportedLanguages where name.hasSuffix("_\(langCode)") {
                        return String(name.dropLast(langCode.count + 1)) // +1 for underscore
                    }
                    return name
                }
            )
            
            // Load each base itinerary (load function handles language fallback)
            let itineraries = baseNames.compactMap { load(from: $0) }
            return itineraries.sorted { $0.center.latitude > $1.center.latitude } // North to South
            
        } catch {
            print("ItineraryLoader: Failed to scan bundle directory — \(error)")
            return []
        }
    }
    
    // MARK: - Private Helpers
    
    private static func loadFile(_ filename: String) -> Itinerary? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Itinerary.self, from: data)
        } catch {
            print("ItineraryLoader: Failed to decode \(filename).json — \(error)")
            return nil
        }
    }
}
