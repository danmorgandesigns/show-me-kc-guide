//
//  PlaceMarker.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/18/26.
//

import SwiftUI

struct PlaceMarker: View {

    let category: String

    var body: some View {
        ZStack {
            Circle()
                .fill(markerColor)
                .frame(width: 36, height: 36)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)

            Image(systemName: markerSymbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Symbol

    private var markerSymbol: String {
        switch category {
        case "restaurant":  return "fork.knife"
        case "museum":      return "building.columns.fill"
        case "music":       return "music.quarternote.3"
        case "bar":         return "wineglass.fill"
        case "beer":         return "mug.fill"
        case "shop":        return "storefront.fill"
        case "hiking":      return "figure.hiking"
        case "biking":      return "figure.outdoor.cycle"
        case "zoo":         return "lizard.fill"
        case "theater":     return "theatermasks.fill"
        case "park":        return "tree.fill"
        case "family":      return "figure.2.and.child.holdinghands"
        case "golf":        return "figure.golf"
        case "tour":        return "lightbulb.max.fill"
        case "amusement":   return "balloon.2.fill"
        case "casino":      return "dollarsign"
        case "cafe":      return "cup.and.saucer.fill"
        default:            return "mappin"
        }
    }

    // MARK: - Color

    private var markerColor: Color {
        switch category {
        case "restaurant":  return .blue
        case "museum":      return .blue
        case "music":       return .blue
        case "bar":         return .blue
        case "shop":        return .blue
        case "hiking":      return .blue
        case "biking":      return .blue
        case "zoo":         return .blue
        case "theater":     return .blue
        case "park":        return .blue
        case "family":      return .blue
        case "golf":        return .blue
        case "tour":        return .blue
        case "amusement":   return .blue
        case "casino":      return .blue
        case "beer":        return .blue
        case "cafe":        return .blue
        default:            return .blue
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PlaceMarker(category: "restaurant")
        PlaceMarker(category: "museum")
        PlaceMarker(category: "music")
        PlaceMarker(category: "shop")
        PlaceMarker(category: "unknown")
    }
    .padding()
}
