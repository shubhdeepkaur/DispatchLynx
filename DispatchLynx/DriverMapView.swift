//
//  DriverMapView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 11/24/25.
//
import SwiftUI
import MapKit

struct DriverMapView: View {
    let driverName: String
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var mapService = MapService()
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading driver location...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let coordinate = coordinate {
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    )), annotationItems: [LocationAnnotation(coordinate: coordinate, title: "\(driverName)'s Location")]) { location in
                        MapAnnotation(coordinate: location.coordinate) {
                            VStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.green)
                                Text(driverName)
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.white)
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .ignoresSafeArea()
                } else {
                    Text("Unable to load driver location")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("\(driverName)'s Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                mapService.geocodeAddress("\(driverName), USA") { coord in
                    DispatchQueue.main.async {
                        coordinate = coord
                        isLoading = false
                    }
                }
            }
        }
    }
}
