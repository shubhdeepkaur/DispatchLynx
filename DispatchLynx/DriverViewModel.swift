//
//  DriverViewModel.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 10/31/25.
//
import Foundation
import SwiftData

class DriverViewModel: ObservableObject {
    @Published var loads: [Load] = []
    @Published var assignedLoads: [Load] = []
    
    var context: ModelContext?
    
    func fetchData(currentDriverName: String) {
        guard let context = context else { return }
        
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
                
                // Set loads to sample data
                loads = sampleLoads
            } else {
                // Use existing loads from database
                loads = existingLoads
            }
            
            // Filter for assigned loads for current driver
            assignedLoads = loads.filter { $0.assignedDriver == currentDriverName }
            
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
    
    func updateStatus(loadId: UUID, newStatus: Load.LoadStatus) {
        if let index = assignedLoads.firstIndex(where: { $0.id == loadId }) {
            assignedLoads[index].status = newStatus.rawValue
            saveContext()
        }
    }
}
