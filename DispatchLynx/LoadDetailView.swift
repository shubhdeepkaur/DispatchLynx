//
//  LoadDetailView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 11/24/25.
//
import SwiftUI
import MapKit

struct LoadDetailView: View {
    let load: Load
    @Environment(\.modelContext) private var context
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var mapService = MapService()
    @StateObject private var documentVM = DocumentViewModel()
    @StateObject private var routeService = RouteService()
    
    @State private var showingPickupMap = false
    @State private var showingDropoffMap = false
    @State private var showingDriverMap = false
    @State private var showingDocuments = false
    @State private var showingAssignDriver = false
    @State private var selectedStatus: Load.LoadStatus
    @State private var routeInfo: RouteInfo?
    @State private var isLoadingRoute = false
    @State private var routeError: String?
    
    init(load: Load) {
        self.load = load
        _selectedStatus = State(initialValue: load.statusEnum)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                loadInfoCard
                routeInfoSection
                mapActionsRow
                documentsSection
                assignDriverButton
            }
            .padding()
        }
        .navigationTitle("Load Details")
        .sheet(isPresented: $showingPickupMap) {
            LocationMapView(locationName: "Pickup: \(load.pickupLocation)", address: load.pickupLocation)
        }
        .sheet(isPresented: $showingDropoffMap) {
            LocationMapView(locationName: "Dropoff: \(load.dropoffLocation)", address: load.dropoffLocation)
        }
        .sheet(isPresented: $showingDriverMap) {
            if let driver = load.assignedDriver {
                DriverMapView(driverName: driver)
            }
        }
        .sheet(isPresented: $showingDocuments) {
            DocumentListView(load: load)
                .environmentObject(documentVM)
        }
        .sheet(isPresented: $showingAssignDriver) {
            AssignDriverView(load: load)
        }
        .onAppear {
            documentVM.context = context
            documentVM.fetchData()
            fetchRouteInfo()
        }
    }
    
    private var routeInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Route Information")
                    .font(.headline)
                Spacer()
                
                if isLoadingRoute {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if routeInfo == nil && routeError == nil {
                    Button("Calculate Route") {
                        fetchRouteInfo()
                    }
                    .font(.caption)
                }
            }
            
            if let error = routeError {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
            } else if let info = routeInfo {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "road.lanes")
                            .foregroundColor(.blue)
                        Text("Distance: \(info.formattedDistance)")
                    }
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        Text("Estimated Time: \(info.formattedDuration)")
                    }
                    HStack {
                        Image(systemName: "car.fill")
                            .foregroundColor(.blue)
                        Text("Average Speed: \(String(format: "%.0f mph", info.distanceInMiles / info.durationInHours))")
                    }
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func fetchRouteInfo() {
        guard !isLoadingRoute else { return }
        
        isLoadingRoute = true
        routeError = nil
        
        routeService.calculateRoute(
            from: load.pickupLocation,
            to: load.dropoffLocation
        ) { routeInfo in
            isLoadingRoute = false
            
            if let routeInfo = routeInfo {
                self.routeInfo = routeInfo
            } else {
                self.routeError = "Could not calculate route"
            }
        }
    }
    
    private var loadInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Load #\(load.loadNumber)")
                .font(.title2)
                .fontWeight(.bold)
            
            InfoRow(icon: "building.2", text: "Client: \(load.clientInfo)")
            InfoRow(icon: "flag", text: "Pickup: \(load.pickupLocation)")
            InfoRow(icon: "flag.fill", text: "Dropoff: \(load.dropoffLocation)")
            
            if let driver = load.assignedDriver {
                driverRow(driver: driver)
            }
            
            statusSection
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func driverRow(driver: String) -> some View {
        HStack {
            Image(systemName: "person")
                .foregroundColor(.blue)
                .frame(width: 20)
            Text("Driver: \(driver)")
            Spacer()
            Button {
                showingDriverMap = true
            } label: {
                Image(systemName: "map")
            }
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status:")
                .font(.headline)
            
            ForEach(Load.LoadStatus.allCases, id: \.self) { status in
                statusRow(status: status)
            }
        }
        .padding(.top, 8)
    }
    
    private func statusRow(status: Load.LoadStatus) -> some View {
        HStack {
            Image(systemName: selectedStatus.rawValue == status.rawValue ? "checkmark.circle.fill" : "circle")
                .foregroundColor(selectedStatus.rawValue == status.rawValue ? .green : .gray)
            Text(status.rawValue)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedStatus = status
            load.status = status.rawValue
            try? context.save()
        }
    }
    
    private var mapActionsRow: some View {
        HStack(spacing: 20) {
            MapActionButton(
                title: "Pickup Map",
                icon: "mappin.circle.fill",
                color: .blue,
                action: { showingPickupMap = true }
            )
            
            MapActionButton(
                title: "Dropoff Map",
                icon: "mappin.circle.fill",
                color: .red,
                action: { showingDropoffMap = true }
            )
            
            if load.assignedDriver != nil {
                MapActionButton(
                    title: "Driver Map",
                    icon: "person.circle.fill",
                    color: .green,
                    action: { showingDriverMap = true }
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Documents")
                    .font(.headline)
                Spacer()
                Button {
                    showingDocuments = true
                } label: {
                    HStack {
                        Text("View All")
                        Image(systemName: "chevron.right")
                    }
                }
            }
            
            let loadDocuments = documentVM.getDocumentsForLoad(loadId: load.id)
            if loadDocuments.isEmpty {
                Text("No documents yet")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(loadDocuments.prefix(3)) { document in
                    documentRow(document: document)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func documentRow(document: Document) -> some View {
        HStack {
            Image(systemName: "doc.text")
                .foregroundColor(.blue)
            Text(document.name)
                .font(.subheadline)
            Spacer()
            Text(document.uploadDate, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private var assignDriverButton: some View {
        Group {
            if load.assignedDriver == nil {
                Button {
                    showingAssignDriver = true
                } label: {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Assign Driver")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
            Spacer()
        }
    }
}

struct MapActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}
