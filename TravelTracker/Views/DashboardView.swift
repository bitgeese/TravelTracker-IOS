import SwiftUI
import RealmSwift

struct DashboardView: View {
    @StateObject private var viewModel = TravelSegmentViewModel()
    @Binding var selectedTab: Int
    
    init(selectedTab: Binding<Int>? = nil) {
        // Make binding optional for preview support
        self._selectedTab = selectedTab ?? .constant(0)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Current Status Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Status")
                        .font(.headline)
                    
                    HStack(spacing: 15) {
                        VStack(alignment: .leading) {
                            Text("Current Location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(currentLocation)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            Text("Days in Current Location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(daysInCurrentLocation)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                // Schengen Status Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Schengen Status")
                        .font(.headline)
                    
                    HStack(spacing: 15) {
                        VStack(alignment: .leading) {
                            Text("Days Used")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("0/90")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            Text("Current Status")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Outside Schengen")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    // Placeholder for progress bar
                    Rectangle()
                        .frame(height: 10)
                        .foregroundColor(.green)
                        .cornerRadius(5)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                // Recent Travel Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recent Travel")
                            .font(.headline)
                        
                        Spacer()
                        
                        // Future Travel section link
                        if hasFutureTravel {
                            NavigationLink(destination: FutureTravelView()) {
                                Text("Future Travel")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    if let segments = recentTravelSegments, !segments.isEmpty {
                        ForEach(segments, id: \.id) { segment in
                            RecentTravelRow(segment: segment)
                            
                            if segment != segments.last {
                                Divider()
                            }
                        }
                        
                        Button {
                            // Use direct tab navigation instead of NavigationLink
                            selectedTab = 1 // Switch to Travel List tab
                        } label: {
                            Text("View All Travel")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text("No recent travel")
                            .foregroundColor(.secondary)
                            .padding(.vertical)
                        
                        NavigationLink(destination: ManualEntryView()) {
                            Text("Add Travel")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Travel Dashboard")
        .onAppear {
            viewModel.loadTravelSegments()
        }
    }
    
    // Only include non-future travel segments in "Recent Travel"
    private var recentTravelSegments: [TravelSegment]? {
        guard let segments = viewModel.travelSegments else { return nil }
        let today = Calendar.current.startOfDay(for: Date())
        
        // Filter to only include segments that have started on or before today
        let nonFutureSegments = segments.filter { 
            Calendar.current.startOfDay(for: $0.startDate) <= today 
        }
        
        // Return up to 3 segments
        return Array(nonFutureSegments.prefix(3))
    }
    
    // Check if there are any future trips
    private var hasFutureTravel: Bool {
        guard let segments = viewModel.travelSegments else { return false }
        let today = Calendar.current.startOfDay(for: Date())
        
        return segments.contains { 
            Calendar.current.startOfDay(for: $0.startDate) > today 
        }
    }
    
    private var currentLocation: String {
        // Use the most recent non-future travel segment to determine current location
        if let currentSegment = viewModel.travelSegments?.filter({ 
            $0.startDate <= Date() && $0.endDate >= Date() 
        }).first {
            return currentSegment.country?.name ?? currentSegment.countryCode
        } else if let recentSegment = viewModel.travelSegments?.filter({ 
            $0.endDate <= Date() 
        }).first {
            return recentSegment.country?.name ?? recentSegment.countryCode
        }
        return "Unknown"
    }
    
    private var daysInCurrentLocation: String {
        // Calculate days in current location if we have a current segment
        let today = Date()
        if let currentSegment = viewModel.travelSegments?.filter({ 
            $0.startDate <= today && $0.endDate >= today 
        }).first {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: currentSegment.startDate, to: today)
            if let days = components.day {
                return "\(days + 1) \(days + 1 == 1 ? "day" : "days")"
            }
        }
        return "0 days"
    }
}

// Placeholder for Future Travel View - will implement later
struct FutureTravelView: View {
    var body: some View {
        Text("Future Travel - Coming Soon")
            .navigationTitle("Future Travel")
    }
}

struct RecentTravelRow: View {
    let segment: TravelSegment
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(segment.country?.name ?? segment.countryCode)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(dateFormatter.string(from: segment.startDate)) - \(dateFormatter.string(from: segment.endDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(durationText)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(6)
        }
    }
    
    private var durationText: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: segment.startDate, to: segment.endDate)
        if let days = components.day {
            return "\(days + 1) \(days + 1 == 1 ? "day" : "days")"
        }
        return ""
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
        }
    }
} 