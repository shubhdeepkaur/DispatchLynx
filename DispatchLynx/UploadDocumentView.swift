//
//  UploadDocumentView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 11/24/25.
//
import SwiftUI

struct UploadDocumentView: View {
    let load: Load
    @EnvironmentObject var documentVM: DocumentViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var documentName: String = ""
    @State private var selectedDocumentType: Document.DocumentType = .billOfLading
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Document Information")) {
                    TextField("Document Name", text: $documentName)
                    
                    Picker("Document Type", selection: $selectedDocumentType) {
                        ForEach(Document.DocumentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section {
                    Button {
                        documentVM.uploadDocument(
                            name: documentName.isEmpty ? "\(selectedDocumentType.rawValue) - \(load.loadNumber)" : documentName,
                            loadId: load.id,
                            documentType: selectedDocumentType
                        )
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Upload Document")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(Color.blue)
                    .disabled(documentName.isEmpty)
                }
            }
            .navigationTitle("Upload Document")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
