//
//  BasecampLoader.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/22/26.
//

import Foundation

enum BasecampLoader {
    static func loadAll() -> [Basecamp] {
        guard let url = Bundle.main.url(forResource: "basecamps", withExtension: "json") else {
            print("BasecampLoader: Could not find basecamps.json in bundle.")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Basecamp].self, from: data)
        } catch {
            print("BasecampLoader: Failed to decode basecamps.json — \(error)")
            return []
        }
    }
}
