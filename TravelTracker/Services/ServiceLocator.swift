import Foundation

/// Service locator for app-wide dependency injection
class ServiceLocator {
    static let shared = ServiceLocator()
    
    private init() {
        // Initialize with mock services by default
        self.keychainService = MockKeychainService()
        self.apiService = MockAPIService(keychainService: keychainService)
    }
    
    // Services
    private(set) var keychainService: KeychainServiceProtocol
    private(set) var apiService: APIServiceProtocol
    
    /// Replace services with real implementations when backend is available
    func configureRealServices() {
        // In the future:
        // self.keychainService = RealKeychainService()
        // self.apiService = RealAPIService(keychainService: keychainService)
    }
    
    /// Replace services with mock implementations for testing
    func configureMockServices() {
        self.keychainService = MockKeychainService()
        self.apiService = MockAPIService(keychainService: keychainService)
    }
} 