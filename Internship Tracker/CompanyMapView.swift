import SwiftUI
import SwiftData
import MapKit
import CoreLocation

struct CompanyMapView: View {
    @Query(sort: \Internship.companyName) private var internships: [Internship]

    @StateObject private var locationManager = LocationManager()

    @State private var searchText = ""
    @State private var results: [CompanyPlace] = []
    @State private var selectedPlace: CompanyPlace?
    @State private var isSearching = false
    @State private var errorMessage: String?

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
            span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
        )
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
                .frame(minHeight: 300)

                List {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Şirket Konumu ve Yol Tarifi")
                                .font(.title3)
                                .bold()

                            Text("Cihaz konumunu kullanarak şirket adı/adres arayabilir, sonucu haritada görebilir ve Apple Maps ile yol tarifi başlatabilirsin.")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack {
                                TextField("Şirket veya adres ara", text: $searchText)
                                    .textFieldStyle(.roundedBorder)
                                    .submitLabel(.search)
                                    .onSubmit {
                                        Task { await searchPlaces() }
                                    }

                                Button {
                                    Task { await searchPlaces() }
                                } label: {
                                    Image(systemName: "magnifyingglass")
                                }
                                .disabled(isSearching || searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }

                            HStack {
                                Button {
                                    locationManager.requestLocationAccess()
                                    centerToUserLocation()
                                } label: {
                                    Label("Konumumu Kullan", systemImage: "location.fill")
                                }

                                Spacer()

                                if isSearching {
                                    ProgressView()
                                }
                            }
                            .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }

                    if !internships.isEmpty {
                        Section("Başvurularımdan Ara") {
                            ForEach(internships.prefix(10), id: \.persistentModelID) { internship in
                                Button {
                                    searchText = internship.companyName
                                    Task { await searchPlaces() }
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
                        } else {
                            ForEach(results) { place in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(place.name)
                                        .font(.headline)

                                    if !place.address.isEmpty {
                                        Text(place.address)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    HStack {
                                        Button {
                                            focus(on: place)
                                        } label: {
                                            Label("Haritada Göster", systemImage: "mappin.and.ellipse")
                                        }

                                        Spacer()

                                        Button {
                                            openDirections(to: place)
                                        } label: {
                                            Label("Yol Tarifi", systemImage: "arrow.triangle.turn.up.right.diamond")
                                        }
                                    }
                                    .font(.caption)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Harita")
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
