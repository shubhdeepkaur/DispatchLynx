//
//  LoginView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 10/31/25.
//
import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingSignUp = false
    
    var body: some View {
        Form {
            Section(header: Text("Login Information")) {
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $password)
            }
            
            if let errorMessage = authViewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
            
            Section {
                Button("Login") {
                    authViewModel.login(username: username, password: password)
                }
                .disabled(username.isEmpty || password.isEmpty)
            }
            
            Section {
                Button("Don't have an account? Sign Up") {
                    showingSignUp = true
                }
            }
        }
        .navigationTitle("Login to DispatchLynx")
        .sheet(isPresented: $showingSignUp) {
            SignUpView(authViewModel: authViewModel)
        }
    }
}
