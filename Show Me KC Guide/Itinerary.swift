//
//  Itinerary.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/21/26.
//

import Foundation
import CoreLocation

struct Itinerary: Identifiable, Hashable {
    let id = UUID()
    let itineraryName: String
    let radius: Double
    let shortDescription: String
    let longDescription: String
    let locations: [Place]
    
    var center: CLLocationCoordinate2D {
        guard !locations.isEmpty else {
            return CLLocationCoordinate2D(latitude: 39.0997, longitude: -94.5786)
        }
        
        let avgLat = locations.map(\.latitude).reduce(0, +) / Double(locations.count)
        let avgLng = locations.map(\.longitude).reduce(0, +) / Double(locations.count)
        
        return CLLocationCoordinate2D(latitude: avgLat, longitude: avgLng)
    }
    
    static func == (lhs: Itinerary, rhs: Itinerary) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension Itinerary: Decodable {
    enum CodingKeys: String, CodingKey {
        case itineraryName = "itinerary_name"
        case radius
        case shortDescription = "short_description"
        case longDescription = "long_description"
        case locations
    }
}
