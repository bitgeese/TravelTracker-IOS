import Foundation
import RealmSwift

class RealmService {
    static let shared = RealmService()
    
    private init() {}
    
    func setupRealm() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // In future, perform migrations if schema changes
                }
            },
            objectTypes: [User.self, Country.self, TravelSegment.self]
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        // Ensure Realm file can be created
        do {
            let _ = try Realm()
            print("Realm initialized successfully")
        } catch {
            print("Error initializing Realm: \(error.localizedDescription)")
        }
    }
    
    func getRealm() throws -> Realm {
        return try Realm()
    }
} 