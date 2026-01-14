//
//  DriverView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 10/31/25.
//
import SwiftUI
import SwiftData

struct DriverView: View {
    @Environment(\.modelContext) private var context
    @StateObject var driverVM = DriverViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showingDriverLoadsMap = false
    
    var body: some View {
        NavigationView {
            VStack {
                List(driverVM.assignedLoads) { load in
                    NavigationLink(destination: LoadDetailView(load: load)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Load #\(load.loadNumber)")
                                .font(.headline)
                            Text("\(load.pickupLocation) → \(load.dropoffLocation)")
                                .font(.subheadline)
                            Text("Status: \(load.statusEnum.rawValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Spacer()
                
                // Map icon at bottom right
                HStack {
                    Spacer()
                    Button {
                        showingDriverLoadsMap = true
                    } label: {
                        Image(systemName: "map.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                    }
                    .padding(.trailing)
                }
                .padding(.bottom)
            }
            .navigationTitle("Driver Dashboard")
            .toolbar {
                // Logout at upper right
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        authViewModel.logout()
                    }
                }
            }
            .sheet(isPresented: $showingDriverLoadsMap) {
                AllLoadsMapView(loads: driverVM.assignedLoads)
            }
            .onAppear {
                driverVM.context = context
                if let currentDriverName = authViewModel.currentUser?.name {
                    driverVM.fetchData(currentDriverName: currentDriverName)
                }
            }
        }
    }
}
