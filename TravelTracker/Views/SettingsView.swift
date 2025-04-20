import SwiftUI

struct SettingsView: View {
    @State private var darkModeEnabled = false
    @State private var notificationsEnabled = true
    @State private var syncFrequency = "Daily"
    @State private var showingLogoutAlert = false
    
    let syncOptions = ["Manual", "Daily", "Weekly"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }
                
                Section(header: Text("Data Synchronization")) {
                    Picker("Sync Frequency", selection: $syncFrequency) {
                        ForEach(syncOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    Button("Sync Now") {
                        // This will be implemented in Phase 5 when we have a real backend
                    }
                }
                
                Section(header: Text("Account")) {
                    // These will be implemented in Phase 3 when we add authentication
                    Text("User: Not Logged In")
                        .foregroundColor(.secondary)
                    
                    Button("Log In") {
                        // Login will be implemented in Phase 3
                    }
                    
                    Button("Log Out") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(.red)
                    .disabled(true) // Disabled until authentication is implemented
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    // Logout will be implemented in Phase 3
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 