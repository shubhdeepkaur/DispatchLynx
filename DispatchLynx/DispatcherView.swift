//
//  DispatcherView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 10/31/25.
//
import SwiftUI
import SwiftData

struct DispatcherView: View {
    @Environment(\.modelContext) private var context
    @StateObject var dispatcherVM = DispatcherViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showingCreateLoadForm = false
    @State private var newLoadNumber: String = ""
    @State private var newPickupLocation: String = ""
    @State private var newDropoffLocation: String = ""
    @State private var newClientInfo: String = ""
    @State private var showingAllLoadsMap = false
    
    var body: some View {
        NavigationView {
            VStack {
                List(dispatcherVM.loads) { load in
                    NavigationLink(destination: LoadDetailView(load: load)) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Load #\(load.loadNumber)")
                                .font(.headline)
                            Text("\(load.pickupLocation) → \(load.dropoffLocation)")
                                .font(.subheadline)
                            Text("Driver: \(load.assignedDriver ?? "Not assigned")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                HStack {
                    // Add button at bottom left
                    Button {
                        showingCreateLoadForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    // Map icon at bottom right
                    Button {
                        showingAllLoadsMap = true
                    } label: {
                        Image(systemName: "map.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                    }
                    .padding(.trailing)
                }
                .padding(.bottom)
            }
            .navigationTitle("Dispatcher Dashboard")
            .toolbar {
                // Logout at upper right
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        authViewModel.logout()
                    }
                }
            }
            .sheet(isPresented: $showingCreateLoadForm) {
                NavigationView {
                    Form {
                        Section(header: Text("Load Information")) {
                            TextField("Load Number", text: $newLoadNumber)
                            TextField("Pickup Location", text: $newPickupLocation)
                            TextField("Dropoff Location", text: $newDropoffLocation)
                            TextField("Client Information", text: $newClientInfo)
                        }
                    }
                    .navigationTitle("Create New Load")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingCreateLoadForm = false
                                clearForm()
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                let newLoad = Load(
                                    loadNumber: newLoadNumber,
                                    pickupLocation: newPickupLocation,
                                    dropoffLocation: newDropoffLocation,
                                    clientInfo: newClientInfo,
                                    status: .pending,
                                    assignedDriver: nil
                                )
                                dispatcherVM.createLoad(load: newLoad)
                                showingCreateLoadForm = false
                                clearForm()
                            }
                            .disabled(newLoadNumber.isEmpty || newPickupLocation.isEmpty || newDropoffLocation.isEmpty)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAllLoadsMap) {
                AllLoadsMapView(loads: dispatcherVM.loads)
            }
            .onAppear {
                dispatcherVM.context = context
                dispatcherVM.fetchData()
            }
        }
    }
    
    private func clearForm() {
        newLoadNumber = ""
        newPickupLocation = ""
        newDropoffLocation = ""
        newClientInfo = ""
    }
}
