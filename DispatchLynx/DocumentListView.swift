//
//  DocumentListView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 11/24/25.
//
import SwiftUI

struct DocumentListView: View {
    let load: Load
    @EnvironmentObject var documentVM: DocumentViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingUploadDocument = false
    @State private var showingDocumentView = false
    @State private var selectedDocument: Document?
    @State private var showingDeleteAlert = false
    @State private var documentToDelete: Document?
    
    var body: some View {
        NavigationView {
            VStack {
                let loadDocuments = documentVM.getDocumentsForLoad(loadId: load.id)
                
                if loadDocuments.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No documents yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Upload your first document to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(loadDocuments) { document in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(document.name)
                                        .font(.headline)
                                    Text("\(document.documentTypeEnum.rawValue) • \(document.uploadDate, style: .date)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button {
                                    selectedDocument = document
                                    showingDocumentView = true
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    documentToDelete = document
                                    showingDeleteAlert = true
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Documents for Load #\(load.loadNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingUploadDocument = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingUploadDocument) {
                UploadDocumentView(load: load)
                    .environmentObject(documentVM)
            }
            .sheet(isPresented: $showingDocumentView) {
                if let document = selectedDocument {
                    DocumentView(document: document)
                }
            }
            .alert("Delete Document", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let document = documentToDelete {
                        documentVM.deleteDocument(documentId: document.id)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this document? This action cannot be undone.")
            }
        }
    }
}
