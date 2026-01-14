//
//  SignUpView.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 10/31/25.
//
import SwiftUI

struct SignUpView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var userType: User.UserType = .driver
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $name)
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                }
                
                Section(header: Text("Account Type")) {
                    Picker("I am a", selection: $userType) {
                        Text("Driver").tag(User.UserType.driver)
                        Text("Dispatcher").tag(User.UserType.dispatcher)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Sign Up")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        authViewModel.signUp(username: username, password: password, name: name, userType: userType)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(username.isEmpty || password.isEmpty || name.isEmpty)
                }
            }
        }
    }
}
