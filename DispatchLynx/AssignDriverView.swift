//
//  AssignDriverView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 11/24/25.
//
import SwiftUI

struct AssignDriverView: View {
    let load: Load
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var context
    @State private var selectedDriver: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Driver")) {
                    Picker("Driver", selection: $selectedDriver) {
                        Text("Select a driver").tag("")
                        ForEach(sampleDrivers, id: \.self) { driver in
                            Text(driver).tag(driver)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                if !selectedDriver.isEmpty {
                    Section(header: Text("Assignment Details")) {
                        Text("Load: #\(load.loadNumber)")
                        Text("Pickup: \(load.pickupLocation)")
                        Text("Dropoff: \(load.dropoffLocation)")
                        Text("Driver: \(selectedDriver)")
                    }
                }
            }
            .navigationTitle("Assign Driver")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Update the load with assigned driver
                        load.assignedDriver = selectedDriver
                        load.status = Load.LoadStatus.assigned.rawValue
                        try? context.save()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(selectedDriver.isEmpty)
                }
            }
        }
    }
}
