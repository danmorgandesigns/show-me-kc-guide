//
//  LandmarkLoader.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/22/26.
//

import Foundation

enum LandmarkLoader {
    static func loadAll() -> [Landmark] {
        guard let url = Bundle.main.url(forResource: "landmarks", withExtension: "json") else {
            print("LandmarkLoader: Could not find landmarks.json in bundle.")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Landmark].self, from: data)
        } catch {
            print("LandmarkLoader: Failed to decode landmarks.json — \(error)")
            return []
        }
    }
}
