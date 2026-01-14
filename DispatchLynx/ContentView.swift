//
//  ContentView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 10/31/25.
//
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if authViewModel.isLoading {
                    Text("Loading...")
                } else if let user = authViewModel.currentUser {
                    switch user.userTypeEnum {
                    case .driver:
                        DriverView()
                    case .dispatcher:
                        DispatcherView()
                    }
                } else {
                    LoginView(authViewModel: authViewModel)
                }
            }
            .navigationTitle("DispatchLynx")
        }
        .environmentObject(authViewModel)
        .onAppear {
            authViewModel.context = context
            authViewModel.fetchData()
        }
    }
}

#Preview {
    ContentView()
}
