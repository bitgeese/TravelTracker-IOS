//
//  TravelTrackerApp.swift
//  TravelTracker
//
//  Created by Maciej Janowski on 20/04/2025.
//

import SwiftUI

@main
struct TravelTrackerApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        // Set up Realm on app launch
        RealmService.shared.setupRealm()
        
        // Initialize services
        _ = ServiceLocator.shared
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoggedIn {
                    ContentView()
                        .environmentObject(authViewModel)
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
            .onAppear {
                // Check login status
                authViewModel.checkLoginStatus()
            }
        }
    }
}
