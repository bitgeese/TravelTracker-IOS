import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            NavigationView {
                DashboardView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Dashboard", systemImage: "house")
            }
            .tag(0)
            
            // Travel List Tab
            NavigationView {
                TravelListView()
            }
            .tabItem {
                Label("Travel", systemImage: "list.bullet")
            }
            .tag(1)
            
            // Calendar Tab
            Text("Calendar View - Coming Soon")
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(2)
            
            // Map Tab
            Text("Map View - Coming Soon")
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(3)
            
            // Settings Tab
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(4)
        }
        .environmentObject(authViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
} 