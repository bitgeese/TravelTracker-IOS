import SwiftUI

struct ManualEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TravelSegmentViewModel()
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400) // Default to next day
    @State private var countryCode = "US" // Default country code
    @State private var notes = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var alertIsError = false
    
    // Get list of country codes in a more comprehensive way
    let countries: [(code: String, name: String)] = {
        let locales = Locale.isoRegionCodes
        return locales.compactMap { code in
            if let name = Locale.current.localizedString(forRegionCode: code) {
                return (code, name)
            }
            return nil
        }.sorted { $0.name < $1.name }
    }()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Travel Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date])
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: [.date])
                }
                
                Section(header: Text("Country")) {
                    Picker("Country", selection: $countryCode) {
                        ForEach(countries, id: \.code) { country in
                            Text(country.name).tag(country.code)
                        }
                    }
                }
                
                Section(header: Text("Notes (Optional)")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Button(action: saveTravelSegment) {
                    Text("Save Travel")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .listRowInsets(EdgeInsets())
                .disabled(viewModel.isLoading)
            }
            .navigationTitle("Add Travel")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Travel Tracker", isPresented: $showAlert) {
                Button("OK") {
                    if !alertIsError {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveTravelSegment() {
        // Save travel segment with validation
        let result = viewModel.addTravelSegment(
            startDate: startDate,
            endDate: endDate,
            countryCode: countryCode,
            notes: notes.isEmpty ? nil : notes
        )
        
        alertIsError = !result.success
        alertMessage = result.message ?? (result.success ? "Travel segment saved successfully" : "Failed to save travel segment")
        showAlert = true
    }
}

struct ManualEntryView_Previews: PreviewProvider {
    static var previews: some View {
        ManualEntryView()
    }
} 