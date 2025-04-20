import SwiftUI
import RealmSwift

struct TravelListView: View {
    @StateObject private var viewModel = TravelSegmentViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        Group {
            if let travelSegments = viewModel.travelSegments, !travelSegments.isEmpty {
                List {
                    ForEach(Array(travelSegments), id: \.id) { segment in
                        TravelSegmentRow(segment: segment)
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.deleteTravelSegment(id: segment.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "airplane.circle")
                        .font(.system(size: 80))
                        .foregroundColor(.blue.opacity(0.7))
                    
                    Text("No Travel Segments")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Add your first travel segment by tapping the Add button")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Add Travel") {
                        showingAddSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .padding()
            }
        }
        .navigationTitle("Travel History")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Travel", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    // This will handle CSV import in a later phase
                } label: {
                    Label("Import", systemImage: "square.and.arrow.down")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            ManualEntryView()
                .onDisappear {
                    // Ensure we refresh the data when the sheet is dismissed
                    viewModel.loadTravelSegments()
                }
        }
        .onAppear {
            viewModel.loadTravelSegments()
        }
    }
}

struct TravelSegmentRow: View {
    let segment: TravelSegment
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(segment.country?.name ?? segment.countryCode)
                .font(.headline)
            
            HStack {
                Label {
                    Text("\(dateFormatter.string(from: segment.startDate)) - \(dateFormatter.string(from: segment.endDate))")
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
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
            
            if let notes = segment.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
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

struct TravelListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TravelListView()
        }
    }
} 