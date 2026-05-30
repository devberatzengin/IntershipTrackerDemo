import SwiftUI
import SwiftData
import MapKit
import CoreLocation
import Combine

struct CompanyMapView: View {
    @Query(sort: \Internship.companyName) private var internships: [Internship]

    @StateObject private var locationManager = LocationManager()

    @State private var searchText = ""
    @State private var results: [CompanyPlace] = []
    @State private var selectedPlace: CompanyPlace?
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var showingSearchPanel = true

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
            span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        )
    )

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                UserAnnotation()

                ForEach(results) { place in
                    Marker(place.name, coordinate: place.coordinate)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationTitle("Harita")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationManager.requestLocationAccess()
        }
        .onReceive(locationManager.$currentLocation.compactMap { $0 }) { newLocation in
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: newLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                )
            )
        }
        .sheet(isPresented: $showingSearchPanel) {
            MapSearchPanel(
                searchText: $searchText,
                results: $results,
                internships: internships,
                isSearching: isSearching,
                errorMessage: errorMessage,
                onSearch: {
                    Task { await searchPlaces() }
                },
                onUseMyLocation: {
                    locationManager.requestLocationAccess()
                    centerToUserLocation()
                },
                onFocus: { place in
                    focus(on: place)
                },
                onDirections: { place in
                    openDirections(to: place)
                }
            )
            .presentationDetents([.fraction(0.3), .medium, .large])
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .interactiveDismissDisabled()
            .presentationDragIndicator(.visible)
        }
    }

    private func searchPlaces() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        isSearching = true
        errorMessage = nil

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        if let currentLocation = locationManager.currentLocation {
            request.region = MKCoordinateRegion(
                center: currentLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.35, longitudeDelta: 0.35)
            )
        }

        do {
            let response = try await MKLocalSearch(request: request).start()
            results = response.mapItems.prefix(10).map { CompanyPlace(mapItem: $0) }

            if let first = results.first {
                focus(on: first)
            } else {
                errorMessage = "Bu arama için konum bulunamadı."
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isSearching = false
    }

    private func centerToUserLocation() {
        guard let location = locationManager.currentLocation else { return }
        cameraPosition = .region(
            MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
        )
    }

    private func focus(on place: CompanyPlace) {
        selectedPlace = place
        cameraPosition = .region(
            MKCoordinateRegion(
                center: place.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            )
        )
    }

    private func openDirections(to place: CompanyPlace) {
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]

        place.mapItem.openInMaps(launchOptions: launchOptions)
    }
}

struct MapSearchPanel: View {
    @Binding var searchText: String
    @Binding var results: [CompanyPlace]
    let internships: [Internship]
    let isSearching: Bool
    let errorMessage: String?
    
    let onSearch: () -> Void
    let onUseMyLocation: () -> Void
    let onFocus: (CompanyPlace) -> Void
    let onDirections: (CompanyPlace) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator space
            Spacer()
                .frame(height: 12)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Şirket Konumları")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    if isSearching {
                        ProgressView()
                    }
                }
                
                HStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Şirket veya adres ara", text: $searchText)
                            .submitLabel(.search)
                            .onSubmit(onSearch)
                    }
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    Button(action: onSearch) {
                        Text("Ara")
                            .fontWeight(.bold)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                HStack {
                    Button(action: onUseMyLocation) {
                        Label("Konumumu Kullan", systemImage: "location.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            Divider()
            
            List {
                if let errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Arama Sonuçları") {
                    if results.isEmpty {
                        ContentUnavailableView(
                            "Sonuç yok",
                            systemImage: "map",
                            description: Text("Bir şirket adı veya adres arat.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(results) { place in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(place.name)
                                    .font(.system(.headline, design: .rounded))

                                if !place.address.isEmpty {
                                    Text(place.address)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                HStack(spacing: 16) {
                                    Button {
                                        onFocus(place)
                                    } label: {
                                        Label("Odaklan", systemImage: "mappin.and.ellipse")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)

                                    Button {
                                        onDirections(place)
                                    } label: {
                                        Label("Yol Tarifi", systemImage: "arrow.triangle.turn.up.right.diamond")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.green.opacity(0.1))
                                            .foregroundColor(.green)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
                
                if !internships.isEmpty {
                    Section("Başvurularımdan Hızlı Ara") {
                        ForEach(internships.prefix(5), id: \.persistentModelID) { internship in
                            Button {
                                searchText = internship.companyName
                                onSearch()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(internship.companyName)
                                        .font(.subheadline)
                                        .bold()
                                    Text(internship.role)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

struct CompanyPlace: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let mapItem: MKMapItem

    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        self.name = mapItem.name ?? "Bilinmeyen Konum"
        self.address = [
            mapItem.placemark.thoroughfare,
            mapItem.placemark.subThoroughfare,
            mapItem.placemark.locality,
            mapItem.placemark.administrativeArea,
            mapItem.placemark.country
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
        self.coordinate = mapItem.placemark.coordinate
    }
}

#Preview {
    CompanyMapView()
        .modelContainer(for: [Internship.self, Reference.self, CVDocument.self, NetworkContact.self, InterviewQuestion.self, AppGoal.self, InterviewRound.self, CoverLetter.self], inMemory: true)
}
