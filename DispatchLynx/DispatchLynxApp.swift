//
//  DispatchLynxApp.swift
//  DispatchLynx
//
//  Created by Shubhdeep Kaur on 10/31/25.
//

import SwiftUI
import SwiftData

@main
struct DispatchLynxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [User.self, Load.self, Document.self])
    }
}
