//
//  LocationMapView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 11/24/25.
//
import SwiftUI
import MapKit

struct LocationMapView: View {
    let locationName: String
    let address: String
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var mapService = MapService()
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading map...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let coordinate = coordinate {
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    )), annotationItems: [LocationAnnotation(coordinate: coordinate, title: locationName)]) { location in
                        MapMarker(coordinate: location.coordinate, tint: .red)
                    }
                    .ignoresSafeArea()
                } else {
                    Text("Unable to load map")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(locationName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                mapService.geocodeAddress(address) { coord in
                    coordinate = coord
                    isLoading = false
                }
            }
        }
    }
}

struct LocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}
