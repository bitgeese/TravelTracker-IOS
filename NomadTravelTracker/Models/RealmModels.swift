//
//  RealmModels.swift
//  NomadTravelTracker
//
//  Created by Maciej Janowski on 21/04/2025.
//

import Foundation
import RealmSwift

// User model for storing authenticated user data
class User: Object {
    @Persisted(primaryKey: true) var id: String = ""
    @Persisted var email: String = ""
    @Persisted var updatedAt: Date = Date()
}

// Country model for storing country information
class Country: Object {
    @Persisted(primaryKey: true) var code: String = "" // ISO country code
    @Persisted var name: String = ""
    @Persisted var isSchengen: Bool = false
}

// TravelSegment model for storing individual travel records
class TravelSegment: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var countryCode: String = ""
    @Persisted var entryDate: Date
    @Persisted var exitDate: Date
    @Persisted var updatedAt: Date = Date()
    @Persisted var isSynced: Bool = false
}
