import Foundation

/// Protocol defining the keychain service for secure token storage
protocol KeychainServiceProtocol {
    /// Save access token to keychain
    func saveAccessToken(_ token: String) throws
    
    /// Save refresh token to keychain
    func saveRefreshToken(_ token: String) throws
    
    /// Get access token from keychain
    func getAccessToken() -> String?
    
    /// Get refresh token from keychain
    func getRefreshToken() -> String?
    
    /// Clear all tokens from keychain
    func clearTokens() throws
    
    /// Check if user is logged in (has valid tokens)
    func isLoggedIn() -> Bool
}

/// Keychain error enum
enum KeychainError: Error {
    case saveFailed(OSStatus)
    case readFailed(OSStatus)
    case deleteFailed(OSStatus)
    case itemNotFound
    case unexpectedData
    
    var localizedDescription: String {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to Keychain: \(status)"
        case .readFailed(let status):
            return "Failed to read from Keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from Keychain: \(status)"
        case .itemNotFound:
            return "Item not found in Keychain"
        case .unexpectedData:
            return "Unexpected data format in Keychain"
        }
    }
} 