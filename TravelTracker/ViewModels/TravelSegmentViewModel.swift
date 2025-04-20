import Foundation
import RealmSwift
import SwiftUI

class TravelSegmentViewModel: ObservableObject {
    @Published var travelSegments: Results<TravelSegment>?
    @Published var isLoading: Bool = false
    
    private var realm: Realm?
    private var notificationTokens: [NotificationToken] = []
    
    init() {
        do {
            realm = try RealmService.shared.getRealm()
            loadTravelSegments()
            setupNotifications()
        } catch {
            print("Error initializing Realm in ViewModel: \(error.localizedDescription)")
        }
    }
    
    deinit {
        // Clean up notification tokens
        notificationTokens.forEach { $0.invalidate() }
    }
    
    func loadTravelSegments() {
        guard let realm = realm else { return }
        travelSegments = realm.objects(TravelSegment.self).sorted(byKeyPath: "startDate", ascending: false)
    }
    
    func setupNotifications() {
        guard let realm = realm, let segments = travelSegments else { return }
        
        // Set up notification for changes to the travel segments collection
        let token = segments.observe { [weak self] changes in
            guard let self = self else { return }
            
            // Notify SwiftUI that our data has changed
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        
        notificationTokens.append(token)
    }
    
    // Date validation function to check for overlapping travel segments
    func validateDateRange(startDate: Date, endDate: Date, excludingId: String? = nil) -> (isValid: Bool, message: String?) {
        guard let segments = travelSegments else { return (true, nil) }
        
        // Check that end date is not before start date
        if endDate < startDate {
            return (false, "End date cannot be before start date")
        }
        
        // Start and end dates at beginning of day for comparison
        let startDay = Calendar.current.startOfDay(for: startDate)
        let endDay = Calendar.current.startOfDay(for: endDate)
        
        // Get all existing segments (excluding the one being edited if applicable)
        let existingSegments = segments.filter { segment in
            if let excludingId = excludingId, segment.id == excludingId {
                return false
            }
            return true
        }
        
        // Check for overlaps with existing segments
        for segment in existingSegments {
            let segmentStartDay = Calendar.current.startOfDay(for: segment.startDate)
            let segmentEndDay = Calendar.current.startOfDay(for: segment.endDate)
            
            // Complete overlap (new segment is contained within existing segment)
            if startDay >= segmentStartDay && endDay <= segmentEndDay {
                return (false, "This travel overlaps with an existing trip to \(segment.country?.name ?? segment.countryCode)")
            }
            
            // Partial overlap (new segment starts during existing segment)
            if startDay >= segmentStartDay && startDay <= segmentEndDay && endDay > segmentEndDay {
                // Allow one day overlap for travel between countries
                if Calendar.current.dateComponents([.day], from: segmentEndDay, to: startDay).day == 0 {
                    // This is a one-day overlap, which is allowed for travel between countries
                    continue
                }
                return (false, "Start date overlaps with a trip to \(segment.country?.name ?? segment.countryCode)")
            }
            
            // Partial overlap (new segment ends during existing segment)
            if startDay < segmentStartDay && endDay >= segmentStartDay && endDay <= segmentEndDay {
                // Allow one day overlap for travel between countries
                if Calendar.current.dateComponents([.day], from: endDay, to: segmentStartDay).day == 0 {
                    // This is a one-day overlap, which is allowed for travel between countries
                    continue
                }
                return (false, "End date overlaps with a trip to \(segment.country?.name ?? segment.countryCode)")
            }
            
            // Complete containment (new segment contains existing segment)
            if startDay <= segmentStartDay && endDay >= segmentEndDay {
                return (false, "This travel completely overlaps an existing trip to \(segment.country?.name ?? segment.countryCode)")
            }
        }
        
        return (true, nil)
    }
    
    func addTravelSegment(startDate: Date, endDate: Date, countryCode: String, notes: String?) -> (success: Bool, message: String?) {
        guard let realm = realm else { return (false, "Realm database unavailable") }
        
        // Validate date range
        let validation = validateDateRange(startDate: startDate, endDate: endDate)
        if !validation.isValid {
            return (false, validation.message)
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try realm.write {
                let id = UUID().uuidString
                let country = findOrCreateCountry(code: countryCode, inWriteTransaction: true)
                
                // Create and add new travel segment
                let travelSegment = TravelSegment(
                    id: id,
                    startDate: startDate,
                    endDate: endDate,
                    country: country,
                    countryCode: countryCode,
                    notes: notes
                )
                
                realm.add(travelSegment)
            }
            return (true, "Travel segment saved successfully")
        } catch {
            print("Error adding travel segment: \(error.localizedDescription)")
            return (false, "Error saving: \(error.localizedDescription)")
        }
    }
    
    func updateTravelSegment(id: String, startDate: Date, endDate: Date, countryCode: String, notes: String?) -> (success: Bool, message: String?) {
        guard let realm = realm else { return (false, "Realm database unavailable") }
        
        // Validate date range, excluding the current segment being edited
        let validation = validateDateRange(startDate: startDate, endDate: endDate, excludingId: id)
        if !validation.isValid {
            return (false, validation.message)
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let travelSegment = realm.object(ofType: TravelSegment.self, forPrimaryKey: id) {
                try realm.write {
                    let country = findOrCreateCountry(code: countryCode, inWriteTransaction: true)
                    
                    travelSegment.startDate = startDate
                    travelSegment.endDate = endDate
                    travelSegment.country = country
                    travelSegment.countryCode = countryCode
                    travelSegment.notes = notes
                    travelSegment.updatedAt = Date()
                    travelSegment.isSynced = false
                }
                return (true, "Travel segment updated successfully")
            } else {
                return (false, "Travel segment not found")
            }
        } catch {
            print("Error updating travel segment: \(error.localizedDescription)")
            return (false, "Error updating: \(error.localizedDescription)")
        }
    }
    
    func deleteTravelSegment(id: String) {
        guard let realm = realm else { return }
        
        do {
            if let travelSegment = realm.object(ofType: TravelSegment.self, forPrimaryKey: id) {
                try realm.write {
                    realm.delete(travelSegment)
                }
            }
        } catch {
            print("Error deleting travel segment: \(error.localizedDescription)")
        }
    }
    
    // Helper method to find or create a country
    private func findOrCreateCountry(code: String, inWriteTransaction: Bool = false) -> Country? {
        guard let realm = realm else { return nil }
        
        // Look for existing country with the same code
        if let existingCountry = realm.objects(Country.self).filter("code == %@", code).first {
            return existingCountry
        }
        
        // Create new country with a consistent ID based on the country code
        // This prevents duplicate countries with different IDs but the same code
        let countryId = "country-\(code)"  // Use a deterministic ID based on the code
        let countryName = getCountryName(for: code) // Get proper country name
        let isSchengen = isSchengenCountry(code: code) // Check if it's a Schengen country
        
        // Create new country
        let country = Country(id: countryId, name: countryName, code: code, isSchengen: isSchengen)
        
        // Only start a write transaction if we're not already in one
        if inWriteTransaction {
            // We're already in a write transaction, just add the country
            realm.add(country)
        } else {
            // Start a new write transaction
            try? realm.write {
                realm.add(country)
            }
        }
        
        return country
    }
    
    // Helper method to get the country name from its code
    private func getCountryName(for code: String) -> String {
        let current = Locale.current
        if let name = current.localizedString(forRegionCode: code) {
            return name
        }
        return code // Fallback to code if name not found
    }
    
    // Helper method to check if a country is in the Schengen Area
    private func isSchengenCountry(code: String) -> Bool {
        // List of Schengen Area country codes
        let schengenCountries = [
            "AT", "BE", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU",
            "IS", "IT", "LV", "LI", "LT", "LU", "MT", "NL", "NO", "PL",
            "PT", "SK", "SI", "ES", "SE", "CH"
        ]
        return schengenCountries.contains(code)
    }
} 