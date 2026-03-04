//
//  Landmark.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/22/26.
//

import Foundation
import CoreLocation

struct Landmark: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let formattedAddress: String?
    let website: String?
    let notes: String?
    let iconName: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func == (lhs: Landmark, rhs: Landmark) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension Landmark: Decodable {
    enum CodingKeys: String, CodingKey {
        case name
        case formattedAddress = "formatted_address"
        case website
        case notes
        case iconName = "icon_name"
        case latitude = "lat"
        case longitude = "lng"
    }
}
