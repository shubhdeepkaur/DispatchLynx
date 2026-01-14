//
//  DispatcherViewModel.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 10/31/25.
//
import Foundation
import SwiftData

class DispatcherViewModel: ObservableObject {
    @Published var loads: [Load] = []
    @Published var drivers: [String] = sampleDrivers
    
    var context: ModelContext?
    
    func fetchData() {
        guard let context = context else {
            return
        }
        
        do {
            // First, fetch existing loads
            let descriptor = FetchDescriptor<Load>()
            let existingLoads = try context.fetch(descriptor)
            
            // If there are no loads in the database, insert sample data
            if existingLoads.isEmpty {
                let sampleLoads = [
                    Load(loadNumber: "001", pickupLocation: "Phoenix", dropoffLocation: "Seattle", clientInfo: "Amazon", status: .assigned, assignedDriver: "Jack"),
                    Load(loadNumber: "002", pickupLocation: "Yuma", dropoffLocation: "Tempe", clientInfo: "TechCompany", status: .pending, assignedDriver: nil),
                    Load(loadNumber: "003", pickupLocation: "Flagstaff", dropoffLocation: "Tucson", clientInfo: "Retail Corp", status: .inProgress, assignedDriver: "Jack")
                ]
                
                // Insert sample loads into context
                for load in sampleLoads {
                    context.insert(load)
                }
                
                // Save to database
                saveContext()
                
                // Set loads to the sample data
                loads = sampleLoads
            } else {
                // Use existing loads from database
                loads = existingLoads
            }
            
        } catch {
            print("Fetch error: \(error)")
        }
    }
    
    func saveContext() {
        do {
            try context?.save()
        } catch {
            print("Save error: \(error)")
        }
    }
    
    func createLoad(load: Load) {
        loads.append(load)
        context?.insert(load)
        saveContext()
    }
    
    func assignLoad(loadId: UUID, driverId: String) {
        if let index = loads.firstIndex(where: { $0.id == loadId }) {
            loads[index].assignedDriver = driverId
            loads[index].status = Load.LoadStatus.assigned.rawValue
            saveContext()
        }
    }
}
