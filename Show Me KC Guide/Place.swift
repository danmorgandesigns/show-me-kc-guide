//
//  Place.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/18/26.
//

import Foundation
import CoreLocation

struct Place: Identifiable, Hashable {
    let id: String          // mapped from "place_id"
    let name: String
    let latitude: Double    // mapped from "lat"
    let longitude: Double   // mapped from "lng"
    let icon_category: String
    let formattedAddress: String?
    let phone: String?
    let website: String?
    let openingHours: [String]?
    let notes: String?
    let tags: [String]?
    let photo: String?
    let caption: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: Place, rhs: Place) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension Place: Decodable {
    enum CodingKeys: String, CodingKey {
        case id                = "place_id"
        case name
        case latitude          = "lat"
        case longitude         = "lng"
        case icon_category
        case formattedAddress  = "formatted_address"
        case phone
        case website
        case openingHours      = "opening_hours"
        case notes
        case tags
        case photo
        case caption
    }
}
