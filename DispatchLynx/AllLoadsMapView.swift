//
//  AllLoadsMapView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 12/5/25.
//
import SwiftUI
import MapKit
import SwiftData

struct AllLoadsMapView: View {
    let loads: [Load]
    @Environment(\.modelContext) private var context
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var mapService = MapService()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.0902, longitude: -95.7129), // Center of US
        span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25)
    )
    
    @State private var annotations: [LoadAnnotation] = []
    @State private var isLoading = true
    @State private var selectedLoad: Load?
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
                    MapAnnotation(coordinate: annotation.coordinate) {
                        VStack(spacing: 4) {
                            Image(systemName: loadIcon(for: annotation.load))
                                .font(.title2)
                                .foregroundColor(loadColor(for: annotation.load))
                                .background(Circle().fill(Color.white).padding(2))
                            
                            Text("#\(annotation.load.loadNumber)")
                                .font(.caption2)
                                .padding(4)
                                .background(Color.white)
                                .cornerRadius(4)
                                .shadow(radius: 2)
                        }
                        .onTapGesture {
                            selectedLoad = annotation.load
                        }
                    }
                }
                .ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Loading map data...")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
            }
            .navigationTitle("All Loads Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(item: $selectedLoad) { load in
                LoadDetailView(load: load)
            }
            .onAppear {
                loadAnnotations()
            }
        }
    }
    
    private func loadIcon(for load: Load) -> String {
        switch load.statusEnum {
        case .pending: return "clock"
        case .assigned: return "person"
        case .inProgress: return "car"
        case .completed: return "checkmark"
        }
    }
    
    private func loadColor(for load: Load) -> Color {
        switch load.statusEnum {
        case .pending: return .orange
        case .assigned: return .blue
        case .inProgress: return .green
        case .completed: return .gray
        }
    }
    
    private func loadAnnotations() {
        isLoading = true
        
        // Group geocoding calls to avoid overwhelming the API
        let dispatchGroup = DispatchGroup()
        var tempAnnotations: [LoadAnnotation] = []
        
        for load in loads {
            dispatchGroup.enter()
            
            mapService.geocodeAddress(load.pickupLocation) { coordinate in
                if let coordinate = coordinate {
                    let annotation = LoadAnnotation(
                        id: load.id,
                        coordinate: coordinate,
                        title: "Load #\(load.loadNumber)",
                        subtitle: "Pickup: \(load.pickupLocation)",
                        load: load
                    )
                    tempAnnotations.append(annotation)
                }
                
                // Also geocode dropoff for route visualization (optional)
                mapService.geocodeAddress(load.dropoffLocation) { _ in
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            annotations = tempAnnotations
            
            // Adjust map region to show all annotations if we have any
            if !annotations.isEmpty {
                adjustRegionToFitAnnotations()
            }
            
            isLoading = false
        }
    }
    
    private func adjustRegionToFitAnnotations() {
        guard !annotations.isEmpty else { return }
        
        var minLat = annotations[0].coordinate.latitude
        var maxLat = annotations[0].coordinate.latitude
        var minLon = annotations[0].coordinate.longitude
        var maxLon = annotations[0].coordinate.longitude
        
        for annotation in annotations {
            minLat = min(minLat, annotation.coordinate.latitude)
            maxLat = max(maxLat, annotation.coordinate.latitude)
            minLon = min(minLon, annotation.coordinate.longitude)
            maxLon = max(maxLon, annotation.coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.2, // 20% padding
            longitudeDelta: (maxLon - minLon) * 1.2
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
}

struct LoadAnnotation: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let title: String
    let subtitle: String
    let load: Load
}
