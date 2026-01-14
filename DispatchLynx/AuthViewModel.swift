//
//  AuthViewModel.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 10/31/25.
//
import Foundation
import SwiftData

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var context: ModelContext?
    
    // example users for implementation
    private var users: [User] = [
        User(username: "JackIsAwesome", password: "password1", name: "Jack", userType: .driver),
        User(username: "MikeIsCool", password: "password2", name: "Mike", userType: .dispatcher)
    ]
    
    func fetchData() {
        guard let context = context else {
            return
        }
        
        do {
            let descriptor = FetchDescriptor<User>()
            let existingUsers = try context.fetch(descriptor)
            
            // Only insert sample users if database is empty
            if existingUsers.isEmpty {
                for user in users {
                    context.insert(user)
                }
                try context.save()
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
    
    func login(username: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        // API call this needs to be fixed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            
            if let user = self.users.first(where: { $0.username == username && $0.password == password }) {
                self.currentUser = user
            } else {
                self.errorMessage = "Invalid username or password"
            }
        }
    }
    
    func signUp(username: String, password: String, name: String, userType: User.UserType) {
        isLoading = true
        errorMessage = nil
        
        // check if it exists already then print message
        if users.contains(where: { $0.username == username }) {
            isLoading = false
            errorMessage = "Username already exists"
            return
        }
        
        // example signing up
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            let newUser = User(
                username: username,
                password: password,
                name: name,
                userType: userType
            )
            self.users.append(newUser)
            self.currentUser = newUser
            
            //specifically save to SwiftData
            self.context?.insert(newUser)
            self.saveContext()
        }
    }
    
    func logout() {
        currentUser = nil
    }
}
