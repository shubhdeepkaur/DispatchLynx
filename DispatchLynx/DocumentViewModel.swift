//
//  DocumentViewModel.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 11/24/25.
//
import Foundation
import SwiftData

class DocumentViewModel: ObservableObject {
    @Published var documents: [Document] = []
    
    var context: ModelContext?
    
    func fetchData() {
        guard let context = context else { return }
        
        do {
            let descriptor = FetchDescriptor<Document>(sortBy: [SortDescriptor(\.uploadDate)])
            documents = try context.fetch(descriptor)
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
    
    func uploadDocument(name: String, loadId: UUID, documentType: Document.DocumentType) {
        let newDocument = Document(name: name, loadId: loadId, documentType: documentType)
        documents.append(newDocument)
        context?.insert(newDocument)
        saveContext()
        fetchData()
    }
    
    func deleteDocument(documentId: UUID) {
        if let index = documents.firstIndex(where: { $0.id == documentId }) {
            let document = documents[index]
            context?.delete(document)
            documents.remove(at: index)
            saveContext()
            fetchData()
        }
    }
    
    func getDocumentsForLoad(loadId: UUID) -> [Document] {
        return documents.filter { $0.loadId == loadId }.sorted { $0.uploadDate < $1.uploadDate }
    }
}
