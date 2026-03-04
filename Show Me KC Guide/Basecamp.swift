//
//  Basecamp.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/22/26.
//

import Foundation
import CoreLocation

struct Basecamp: Identifiable, Hashable {
    let id = UUID()
    let team: String
    let formattedAddress: String?
    let iconFlag: String
    let notes: String?
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func == (lhs: Basecamp, rhs: Basecamp) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension Basecamp: Decodable {
    enum CodingKeys: String, CodingKey {
        case team
        case formattedAddress = "formatted_address"
        case iconFlag = "icon_flag"
        case notes
        case latitude = "lat"
        case longitude = "lng"
    }
}
