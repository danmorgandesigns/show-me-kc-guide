//
//  ContentView.swift
//  Show Me KC Guide
//
//  Created by Dan Morgan on 2/18/26.
//

import SwiftUI
import MapKit

struct ContentView: View {

    // Downtown Kansas City, MO - wider view to show all itineraries
    private static let kcCenter = CLLocationCoordinate2D(
        latitude: 39.0997,
        longitude: -94.5786
    )

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: kcCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    )

    @State private var itineraries: [Itinerary] = []
    @State private var landmarks: [Landmark] = []
    @State private var basecamps: [Basecamp] = []

    @State private var selectedPlace: Place?
    @State private var selectedItinerary: Itinerary?
    @State private var placeToShowDetail: Place?
    @State private var selectedLandmark: Landmark?
    @State private var landmarkToShowDetail: Landmark?
    @State private var basecampToShowDetail: Basecamp?
    @State private var showUserLocation = false
    @State private var isStandardMap = true
    @State private var showListView = false
    @State private var showMenu = false
    @State private var showHelp = false
    @State private var showInformation = false
    @State private var showSettings = false
    @State private var locationManager = LocationManager()
    @State private var currentSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    @State private var localizationRefresh = LocalizationRefresh()
    
    @Environment(\.dismiss) private var dismiss
    
    // Computed property: show itinerary labels only when zoomed in
    private var isZoomedIn: Bool {
        currentSpan.latitudeDelta < 0.1 // Show labels when zoomed closer than 0.1 degrees
    }

    var body: some View {
        Map(position: $position, selection: $selectedPlace) {
            ForEach(itineraries) { itinerary in
                itineraryContent(for: itinerary)
            }
            
            ForEach(landmarks) { landmark in
                Annotation(landmark.name, coordinate: landmark.coordinate, anchor: .center) {
                    Button {
                        landmarkToShowDetail = landmark
                    } label: {
                        LandmarkMarker(iconName: landmark.iconName)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            ForEach(basecamps) { basecamp in
                Annotation(basecamp.team, coordinate: basecamp.coordinate, anchor: .center) {
                    Button {
                        basecampToShowDetail = basecamp
                    } label: {
                        BasecampMarker(flagEmoji: basecamp.iconFlag)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            if showUserLocation && locationManager.isAuthorized {
                UserAnnotation()
            }
        }
        .mapStyle(isStandardMap ? .standard(elevation: .realistic) : .imagery(elevation: .realistic))
        .mapControls {
            // Empty mapControls to hide all default controls
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .top) {
            navigationControls
                .padding(.top, 8)
                .padding(.horizontal, 16)
                .background(.clear)
        }
        .onTapGesture {
            selectedPlace = nil
        }
        .onChange(of: selectedPlace) { oldValue, newValue in
            if let place = newValue {
                placeToShowDetail = place
                selectedPlace = nil
            }
        }
        .sheet(item: $selectedItinerary) { itinerary in
            itineraryDetailSheet(for: itinerary)
        }
        .sheet(item: $placeToShowDetail) { place in
            placeDetailSheet(for: place)
        }
        .sheet(item: $landmarkToShowDetail) { landmark in
            landmarkDetailSheet(for: landmark)
        }
        .sheet(item: $basecampToShowDetail) { basecamp in
            basecampDetailSheet(for: basecamp)
        }
        .overlay {
            if showMenu {
                menuOverlay
            }
        }
        .sheet(isPresented: $showListView) {
            ListView(
                itineraries: itineraries,
                landmarks: landmarks,
                basecamps: basecamps,
                selectedPlace: $placeToShowDetail,
                selectedLandmark: $landmarkToShowDetail,
                selectedBasecamp: $basecampToShowDetail
            )
        }
        .sheet(isPresented: $showHelp) {
            HelpView()
        }
        .sheet(isPresented: $showInformation) {
            AboutView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onMapCameraChange { context in
            currentSpan = context.region.span
        }
        .onChange(of: locationManager.isAuthorized) { oldValue, newValue in
            if newValue && showUserLocation {
                // Permission granted, zoom to user location
                if let userLocation = locationManager.currentLocation {
                    let region = MKCoordinateRegion(
                        center: userLocation.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )
                    withAnimation {
                        position = .region(region)
                    }
                }
            }
        }
        .onChange(of: localizationRefresh.languageCode) { oldValue, newValue in
            // Reload itineraries when language changes
            print("ContentView - Language changed from \(oldValue) to \(newValue), reloading content")
            itineraries = ItineraryLoader.loadAll()
            landmarks = LandmarkLoader.loadAll()
            basecamps = BasecampLoader.loadAll()
        }
        .onAppear {
            // Load itineraries and landmarks in current language
            let currentLang = ItineraryLoader.currentLanguage
            print("ContentView.onAppear - Loading with language: \(currentLang)")
            itineraries = ItineraryLoader.loadAll()
            landmarks = LandmarkLoader.loadAll()
            basecamps = BasecampLoader.loadAll()
            print("ContentView.onAppear - Loaded \(itineraries.count) itineraries, \(landmarks.count) landmarks, \(basecamps.count) basecamps")
        }
    }
    
    // MARK: - Navigation Controls
    
    private var navigationControls: some View {
        HStack(spacing: 12) {
            // User location toggle
            Button {
                toggleUserLocation()
            } label: {
                Image(systemName: showUserLocation ? "location.fill" : "location")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            // Map style toggle
            Button {
                toggleMapStyle()
            } label: {
                Image(systemName: isStandardMap ? "map" : "globe")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
            
            // List view toggle
            Button {
                showListView = true
            } label: {
                Image(systemName: "list.bullet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            // Menu button
            Button {
                showMenu = true
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    private func toggleMapStyle() {
        isStandardMap.toggle()
    }
    
    private func toggleUserLocation() {
        if locationManager.isAuthorized {
            // Already authorized, just toggle display
            showUserLocation.toggle()
            if showUserLocation {
                locationManager.startTracking()
                // Zoom to user's location when enabling
                if let userLocation = locationManager.currentLocation {
                    let region = MKCoordinateRegion(
                        center: userLocation.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )
                    withAnimation {
                        position = .region(region)
                    }
                }
            } else {
                locationManager.stopTracking()
            }
        } else if locationManager.authorizationStatus == .notDetermined {
            // Request permission and enable location
            showUserLocation = true
            locationManager.requestPermission()
        } else {
            // Permission denied - optionally show alert to go to settings
            showUserLocation = false
        }
    }
    
    // MARK: - Map Content
    
    @MapContentBuilder
    private func itineraryContent(for itinerary: Itinerary) -> some MapContent {
        // Radius circle - changes color based on map style
        MapCircle(center: itinerary.center, radius: itinerary.radius)
            .foregroundStyle(isStandardMap ? .black.opacity(0.3) : .white.opacity(0.4))
        
        // Place markers
        ForEach(itinerary.locations) { place in
            Annotation(place.name, coordinate: place.coordinate, anchor: .center) {
                PlaceMarker(category: place.icon_category)
            }
            .tag(place)
        }
        
        // Itinerary marker - always visible
        Annotation(itinerary.itineraryName, coordinate: itinerary.center, anchor: .bottom) {
            Button {
                selectedItinerary = itinerary
            } label: {
                VStack(spacing: 4) {
                    ZStack {
                        Image("custom-pin")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.red)
                            .frame(width: 40, height: 50)
                        
                        Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .offset(y: -5)
                    }
                    
                    if isZoomedIn {
                        Text(itinerary.itineraryName)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                            .shadow(color: .white.opacity(0.8), radius: 2, x: 0, y: 0)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .annotationTitles(.hidden)
    }
    
    // MARK: - Helper Methods
    
    private func topOfCircle(center: CLLocationCoordinate2D, radius: Double) -> CLLocationCoordinate2D {
        // Calculate coordinate at top of circle (north of center)
        // 1 degree latitude ≈ 111,000 meters
        let latitudeOffset = radius / 111_000
        
        return CLLocationCoordinate2D(
            latitude: center.latitude + latitudeOffset,
            longitude: center.longitude
        )
    }

    // MARK: - Itinerary Detail Sheet
    
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

    // MARK: - Place Detail Sheet
    
    private func placeDetailSheet(for place: Place) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Name
                    Text(place.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Notes (below name, above address)
                    if let notes = place.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.body)
                            .italic()
                            .foregroundStyle(.primary)
                    }
                    
                    // Tags (below notes, above address)
                    if let tags = place.tags, !tags.isEmpty {
                        HStack {
                            Image(systemName: "tag.circle.fill")
                                .foregroundStyle(.purple)
                            Text(tags.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Address (tappable to open in Maps)
                    if let address = place.formattedAddress {
                        Button {
                            openInMaps(place: place)
                        } label: {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                Text(address)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Phone (tappable to dial)
                    if let phone = place.phone {
                        Button {
                            dialPhone(number: phone)
                        } label: {
                            HStack {
                                Image(systemName: "phone.circle.fill")
                                    .foregroundStyle(.green)
                                Text(phone)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Website (tappable to open in Safari)
                    if let website = place.website {
                        Button {
                            openWebsite(url: website)
                        } label: {
                            HStack {
                                Image(systemName: "safari.fill")
                                    .foregroundStyle(.blue)
                                Text(website)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Opening Hours
                    if let hours = place.openingHours, !hours.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundStyle(.orange)
                                Text("hours_label".localized)
                                    .fontWeight(.semibold)
                            }
                            
                            ForEach(hours, id: \.self) { hour in
                                Text(hour)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    // Photo (if available)
                    if let photoName = place.photo, !photoName.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(photoName)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Caption (if available)
                            if let caption = place.caption, !caption.isEmpty {
                                Text(caption)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { 
                        zoomToLocation(coordinate: place.coordinate)
                        placeToShowDetail = nil
                    }) {
                        Image(systemName: "location.north.fill")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { placeToShowDetail = nil }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Landmark Detail Sheet
    
    private func landmarkDetailSheet(for landmark: Landmark) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Name with icon
                    HStack(spacing: 12) {
                        LandmarkMarker(iconName: landmark.iconName)
                        Text(landmark.name)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    // Notes (below name, above address)
                    if let notes = landmark.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.body)
                            .italic()
                            .foregroundStyle(.primary)
                    }
                    
                    // Address (tappable to open in Maps)
                    if let address = landmark.formattedAddress {
                        Button {
                            openInMaps(coordinate: landmark.coordinate)
                        } label: {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                Text(address)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Website (tappable to open in Safari)
                    if let website = landmark.website {
                        Button {
                            openWebsite(url: website)
                        } label: {
                            HStack {
                                Image(systemName: "safari.fill")
                                    .foregroundStyle(.blue)
                                Text(website)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { 
                        zoomToLocation(coordinate: landmark.coordinate)
                        landmarkToShowDetail = nil
                    }) {
                        Image(systemName: "location.north.fill")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { landmarkToShowDetail = nil }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Basecamp Detail Sheet
    
    private func basecampDetailSheet(for basecamp: Basecamp) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Team name with flag
                    HStack(spacing: 12) {
                        BasecampMarker(flagEmoji: basecamp.iconFlag)
                        Text(basecamp.team)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    // Notes (below name, above address)
                    if let notes = basecamp.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.body)
                            .italic()
                            .foregroundStyle(.primary)
                    }
                    
                    // Address (tappable to open in Maps)
                    if let address = basecamp.formattedAddress {
                        Button {
                            openInMaps(coordinate: basecamp.coordinate)
                        } label: {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                Text(address)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { 
                        zoomToLocation(coordinate: basecamp.coordinate)
                        basecampToShowDetail = nil
                    }) {
                        Image(systemName: "location.north.fill")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { basecampToShowDetail = nil }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Action Helpers
    
    private func openInMaps(place: Place) {
        let urlString = "http://maps.apple.com/?q=\(place.latitude),\(place.longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openInMaps(coordinate: CLLocationCoordinate2D) {
        let urlString = "http://maps.apple.com/?q=\(coordinate.latitude),\(coordinate.longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func dialPhone(number: String) {
        let cleanNumber = number.filter { "0123456789".contains($0) }
        if let url = URL(string: "tel://\(cleanNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openWebsite(url: String) {
        if let websiteURL = URL(string: url) {
            UIApplication.shared.open(websiteURL)
        }
    }
    
    private func zoomToLocation(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        withAnimation {
            position = .region(region)
        }
    }
    
    // MARK: - Menu Overlay
    
    private var menuOverlay: some View {
        ZStack {
            // Transparent background to capture taps
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showMenu = false
                    }
                }
            
            // Menu dropdown
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Settings
                        Button {
                            showMenu = false
                            showSettings = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.primary)
                                    .frame(width: 28)
                                
                                Text("menu_settings".localized)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // Help
//                        Button {
//                            showMenu = false
//                            showHelp = true
//                        } label: {
//                            HStack(spacing: 12) {
//                                Image(systemName: "questionmark.circle")
//                                    .font(.system(size: 20))
//                                    .foregroundStyle(.primary)
//                                    .frame(width: 28)
//                                
//                                Text("Help")
//                                    .font(.body)
//                                    .foregroundStyle(.primary)
//                                
//                                Spacer()
//                            }
//                            .padding(.horizontal, 24)
//                            .padding(.vertical, 20)
//                        }
//                        .buttonStyle(.plain)
//                        
//                        Divider()
//                            .padding(.leading, 56)
                        
                        // About
                        Button {
                            showMenu = false
                            showInformation = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.primary)
                                    .frame(width: 28)
                                
                                Text("menu_about".localized)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                        }
                        .buttonStyle(.plain)
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .frame(width: 220)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.top, 60)
                    .padding(.trailing, 16)
                }
                
                Spacer()
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .topTrailing)))
        }
        .ignoresSafeArea()
    }
    
}

#Preview {
    ContentView()
}
