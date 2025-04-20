import Foundation

/// Mock implementation of the KeychainServiceProtocol for development and testing
class MockKeychainService: KeychainServiceProtocol {
    // Use UserDefaults as a simple in-memory store for testing
    // In a real implementation, you would use the Keychain APIs
    private let userDefaults = UserDefaults.standard
    
    private let accessTokenKey = "mock_access_token"
    private let refreshTokenKey = "mock_refresh_token"
    
    func saveAccessToken(_ token: String) throws {
        userDefaults.set(token, forKey: accessTokenKey)
    }
    
    func saveRefreshToken(_ token: String) throws {
        userDefaults.set(token, forKey: refreshTokenKey)
    }
    
    func getAccessToken() -> String? {
        return userDefaults.string(forKey: accessTokenKey)
    }
    
    func getRefreshToken() -> String? {
        return userDefaults.string(forKey: refreshTokenKey)
    }
    
    func clearTokens() throws {
        userDefaults.removeObject(forKey: accessTokenKey)
        userDefaults.removeObject(forKey: refreshTokenKey)
    }
    
    func isLoggedIn() -> Bool {
        return getAccessToken() != nil && getRefreshToken() != nil
    }
} 