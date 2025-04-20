//
//  TravelTrackerApp.swift
//  TravelTracker
//
//  Created by Maciej Janowski on 20/04/2025.
//

import SwiftUI

@main
struct TravelTrackerApp: App {
    
    init() {
        // Set up Realm on app launch
        RealmService.shared.setupRealm()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
