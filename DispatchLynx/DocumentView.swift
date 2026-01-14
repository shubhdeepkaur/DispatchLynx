//
//  DocumentView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 11/24/25.
//
import SwiftUI

struct DocumentView: View {
    let document: Document
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                
                Text(document.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 8) {
                    Text("Type: \(document.documentTypeEnum.rawValue)")
                    Text("Uploaded: \(document.uploadDate, style: .date)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Document Preview")
                    .font(.headline)
                
                // Simulated document content
                VStack(alignment: .leading, spacing: 12) {
                    Text("LOAD #\(document.name.components(separatedBy: " ").last ?? "")")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("This is a simulated preview of the \(document.documentTypeEnum.rawValue).")
                    Text("In a real application, this would display the actual document content or PDF.")
                    
                    ForEach(0..<5) { i in
                        HStack {
                            Text("•")
                            Text("Document detail line \(i + 1)")
                                .font(.body)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Document View")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
