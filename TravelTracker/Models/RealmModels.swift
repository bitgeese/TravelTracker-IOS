import Foundation
import RealmSwift

// MARK: - User Model
class User: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var email: String
    @Persisted var firstName: String?
    @Persisted var lastName: String?
    @Persisted var updatedAt: Date
    @Persisted var createdAt: Date
    @Persisted var isSynced: Bool = false
    
    convenience init(id: String, email: String, firstName: String? = nil, lastName: String? = nil) {
        self.init()
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.updatedAt = Date()
        self.createdAt = Date()
    }
}

// MARK: - Country Model
class Country: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var code: String
    @Persisted var isSchengen: Bool
    @Persisted var updatedAt: Date
    @Persisted var createdAt: Date
    @Persisted var isSynced: Bool = false
    
    convenience init(id: String, name: String, code: String, isSchengen: Bool) {
        self.init()
        self.id = id
        self.name = name
        self.code = code
        self.isSchengen = isSchengen
        self.updatedAt = Date()
        self.createdAt = Date()
    }
}

// MARK: - TravelSegment Model
class TravelSegment: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var startDate: Date
    @Persisted var endDate: Date
    @Persisted var country: Country?
    @Persisted var countryCode: String // Redundant for easier querying
    @Persisted var notes: String?
    @Persisted var updatedAt: Date
    @Persisted var createdAt: Date
    @Persisted var isSynced: Bool = false
    
    convenience init(id: String, startDate: Date, endDate: Date, country: Country?, countryCode: String, notes: String? = nil) {
        self.init()
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.country = country
        self.countryCode = countryCode
        self.notes = notes
        self.updatedAt = Date()
        self.createdAt = Date()
    }
}

// MARK: - DTO (Data Transfer Objects) for API interaction
struct UserDTO: Codable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let updatedAt: Date
    let createdAt: Date
}

struct CountryDTO: Codable {
    let id: String
    let name: String
    let code: String
    let isSchengen: Bool
    let updatedAt: Date
    let createdAt: Date
}

struct TravelSegmentDTO: Codable {
    var id: String
    let startDate: Date
    let endDate: Date
    let countryCode: String
    let notes: String?
    let updatedAt: Date
    let createdAt: Date
}

struct SchengenStatusDTO: Codable {
    let daysUsed: Int
    let daysRemaining: Int
    let currentStatus: String // "In" or "Out" of Schengen
    let periodEndDate: Date
} 