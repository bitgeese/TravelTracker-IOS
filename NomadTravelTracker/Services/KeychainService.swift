import Foundation
import Security

class KeychainService {
    
    enum KeychainError: Error {
        case itemNotFound
        case duplicateItem
        case unexpectedStatus(OSStatus)
    }
    
    // MARK: - Save Item
    
    static func saveItem(_ value: String, forAccount account: String, withService service: String = "NomadTravelTracker") throws {
            guard let valueData = value.data(using: .utf8) else {
            throw KeychainError.unexpectedStatus(0)
        }
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: valueData
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            throw KeychainError.duplicateItem
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    // MARK: - Retrieve Item
    
    static func retrieveItem(forAccount account: String, withService service: String = "NomadTravelTracker") throws -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecItemNotFound {
            return nil
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
        
        guard let data = item as? Data else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Update item
    
    static func updateItem(_ value: String, forAccount account: String, withService service: String = "NomadTravelTracker") throws {
        guard let valueData = value.data(using: .utf8) else {
            throw KeychainError.unexpectedStatus(0)
        }
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        
        let attributesToUpdate: [CFString: Any] = [
            kSecValueData: valueData
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    // MARK: - Delete Item
    
    static func deleteItem(forAccount account: String, withService service: String = "NomadTravelTracker") throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecItemNotFound {
            throw KeychainError.itemNotFound
        } else if status != errSecSuccess {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    // MARK: - Convenience methods for auth tokens
    
    static func saveAccessToken(_ token: String) throws {
        try saveItem(token, forAccount: "accessToken")
    }
    
    static func retrieveAccessToken() throws -> String? {
        return try retrieveItem(forAccount: "accessToken")
    }
    
    static func saveRefreshToken(_ token: String) throws {
        try saveItem(token, forAccount: "refreshToken")
    }
    
    static func retrieveRefreshToken() throws -> String? {
        return try retrieveItem(forAccount: "refreshToken")
    }
    
    static func deleteTokens() throws {
        try deleteItem(forAccount: "accessToken")
        try deleteItem(forAccount: "refreshToken")
    }
    
}
