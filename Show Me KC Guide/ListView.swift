//
//  ListView.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/27/26.
//

import SwiftUI

struct ListView: View {
    let itineraries: [Itinerary]
    let landmarks: [Landmark]
    let basecamps: [Basecamp]
    @Binding var selectedPlace: Place?
    @Binding var selectedLandmark: Landmark?
    @Binding var selectedBasecamp: Basecamp?
    @State private var selectedItinerary: Itinerary?
    @State private var localizationRefresh = LocalizationRefresh()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                itinerariesSection
                landmarksSection
            }
            .navigationTitle("listview_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Button(action: { dismiss() }) {
                              Image(systemName: "xmark")
                          }
                    }
                }
            }
            .sheet(item: $selectedItinerary) { itinerary in
                itineraryDetailSheet(for: itinerary)
            }
        }
    }
    
    // MARK: - Section Views
    
    private var itinerariesSection: some View {
        Section {
            ForEach(itineraries) { itinerary in
                DisclosureGroup {
                    ForEach(itinerary.locations) { place in
                        placeRow(place)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Button {
                            selectedItinerary = itinerary
                        } label: {
                            ZStack {
                                Image("custom-pin")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundStyle(.red)
                                    .frame(width: 24, height: 30)
                                
                                Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .offset(y: -3)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Text(itinerary.itineraryName)
                            .font(.headline)
                    }
                }
            }
        } header: {
            Text("section_itineraries".localized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
    }
    
    private var landmarksSection: some View {
        Section {
            ForEach(landmarks) { landmark in
                landmarkRow(landmark)
            }
            
            ForEach(basecamps) { basecamp in
                basecampRow(basecamp)
            }
        } header: {
            Text("section_landmarks_basecamps".localized)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
    }
    
    // MARK: - Row Views
    
    private func placeRow(_ place: Place) -> some View {
        Button {
            selectedPlace = place
            dismiss()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: iconForCategory(place.icon_category))
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(colorForCategory(place.icon_category))
                    .clipShape(Circle())
                
                Text(place.name)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
    
    private func landmarkRow(_ landmark: Landmark) -> some View {
        Button {
            selectedLandmark = landmark
            dismiss()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: landmark.iconName)
                    .font(.system(size: 12))
                    .foregroundStyle(.black)
                    .frame(width: 28, height: 28)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                
                Text(landmark.name)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
    
    private func basecampRow(_ basecamp: Basecamp) -> some View {
        Button {
            selectedBasecamp = basecamp
            dismiss()
        } label: {
            HStack(spacing: 12) {
                Text(basecamp.iconFlag)
                    .font(.system(size: 18))
                    .frame(width: 28, height: 28)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                
                Text(basecamp.team)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helper Functions
    
    private func iconForCategory(_ category: String?) -> String {
        guard let category = category else { return "mappin" }
        
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
    
    private func colorForCategory(_ category: String?) -> Color {
        guard let category = category else { return .blue }
        
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
    
    // MARK: - Detail Sheet
    
    private func itineraryDetailSheet(for itinerary: Itinerary) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(itinerary.itineraryName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(itinerary.shortDescription)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Text(itinerary.longDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { selectedItinerary = nil }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
