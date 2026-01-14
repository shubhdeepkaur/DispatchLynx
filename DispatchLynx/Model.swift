//
//  Model.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 10/31/25.
//
import Foundation
import SwiftData

@Model
class User: Identifiable {
    var id = UUID()
    var username: String
    var password: String
    var name: String
    var userType: String
    
    init(username: String, password: String, name: String, userType: UserType) {
        self.username = username
        self.password = password
        self.name = name
        self.userType = userType.rawValue
    }
    
    var userTypeEnum: UserType {
        return UserType(rawValue: userType) ?? .driver
    }
    
    enum UserType: String, CaseIterable {
        case driver
        case dispatcher
    }
}

@Model
class Load: Identifiable {
    var id = UUID()
    var loadNumber: String
    var pickupLocation: String
    var dropoffLocation: String
    var clientInfo: String
    var status: String
    var assignedDriver: String?
    var createdAt: Date
    
    init(loadNumber: String, pickupLocation: String, dropoffLocation: String,
         clientInfo: String, status: LoadStatus, assignedDriver: String? = nil) {
        self.loadNumber = loadNumber
        self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation
        self.clientInfo = clientInfo
        self.status = status.rawValue
        self.assignedDriver = assignedDriver
        self.createdAt = Date()
    }
    
    var statusEnum: LoadStatus {
        return LoadStatus(rawValue: status) ?? .pending
    }
    
    enum LoadStatus: String, CaseIterable {
        case pending = "Pending"
        case assigned = "Assigned"
        case inProgress = "In Progress"
        case completed = "Completed"
    }
}

@Model
class Document: Identifiable{
    var id = UUID()
    var name: String
    var loadId: UUID
    var uploadDate: Date
    var documentType: String
    
    init(name: String, loadId: UUID, documentType: DocumentType) {
        self.name = name
        self.loadId = loadId
        self.uploadDate = Date()
        self.documentType = documentType.rawValue
    }

    var documentTypeEnum: DocumentType {
        return DocumentType(rawValue: documentType) ?? .other
    }
    
    enum DocumentType: String, CaseIterable {
        case billOfLading = "Bill of Lading"
        case deliveryReceipt = "Delivery Receipt"
        case invoice = "Invoice"
        case other = "Other"
    }
}

// sample drivers
let sampleDrivers = ["Jack", "Sarah", "Mike", "Emily"]

// example loads for implementation
/*let sampleLoads: [Load] = [
    Load(loadNumber: "001", pickupLocation: "Phoenix", dropoffLocation: "Seattle", clientInfo: "Amazon", status: .assigned, assignedDriver: "Jack"),
    Load(loadNumber: "002", pickupLocation: "Yuma", dropoffLocation: "Tempe", clientInfo: "TechCompany", status: .pending, assignedDriver: nil)
]*/
