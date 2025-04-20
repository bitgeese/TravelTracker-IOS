import Foundation

/// Mock implementation of the APIServiceProtocol for development and testing
class MockAPIService: APIServiceProtocol {
    private let keychainService: KeychainServiceProtocol
    private let simulatedNetworkDelay: TimeInterval = 1.0 // Simulated network delay in seconds
    
    // Sample data
    private var mockUsers: [String: (email: String, password: String, firstName: String?, lastName: String?)] = [
        "user@example.com": (email: "user@example.com", password: "password123", firstName: "John", lastName: "Doe")
    ]
    
    private var mockTravelSegments: [TravelSegmentDTO] = [
        TravelSegmentDTO(
            id: "1",
            startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            countryCode: "FR",
            notes: "Paris trip",
            updatedAt: Date(),
            createdAt: Date()
        ),
        TravelSegmentDTO(
            id: "2",
            startDate: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            countryCode: "DE",
            notes: "Berlin business trip",
            updatedAt: Date(),
            createdAt: Date()
        ),
        TravelSegmentDTO(
            id: "3",
            startDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!,
            endDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
            countryCode: "IT",
            notes: "Upcoming Rome vacation",
            updatedAt: Date(),
            createdAt: Date()
        )
    ]
    
    // Currently active import tasks
    private var mockImportTasks: [String: ImportStatus] = [:]
    
    init(keychainService: KeychainServiceProtocol) {
        self.keychainService = keychainService
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedNetworkDelay * 1_000_000_000))
        
        // Check if user exists and password matches
        guard let user = mockUsers[email], user.password == password else {
            throw APIError.unauthorized
        }
        
        // Generate mock token
        let token = "mock_access_token_\(UUID().uuidString)"
        try keychainService.saveAccessToken(token)
        try keychainService.saveRefreshToken("mock_refresh_token_\(UUID().uuidString)")
        
        return token
    }
    
    func register(email: String, password: String, firstName: String?, lastName: String?) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedNetworkDelay * 1_000_000_000))
        
        // Check if user already exists
        if mockUsers[email] != nil {
            throw APIError.serverError("User already exists")
        }
        
        // Add new user
        mockUsers[email] = (email: email, password: password, firstName: firstName, lastName: lastName)
        
        // Generate mock token
        let token = "mock_access_token_\(UUID().uuidString)"
        try keychainService.saveAccessToken(token)
        try keychainService.saveRefreshToken("mock_refresh_token_\(UUID().uuidString)")
        
        return token
    }
    
    func refreshToken() async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedNetworkDelay * 1_000_000_000))
        
        // Check if refresh token exists
        guard keychainService.getRefreshToken() != nil else {
            throw APIError.unauthorized
        }
        
        // Generate new access token
        let newToken = "mock_access_token_\(UUID().uuidString)"
        try keychainService.saveAccessToken(newToken)
        
        return newToken
    }
    
    func logout() async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedNetworkDelay * 1_000_000_000))
        
        // Clear tokens
        try keychainService.clearTokens()
    }
    
    // MARK: - Travel Segment Methods
    
    func fetchTravelSegments() async throws -> [TravelSegmentDTO] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedNetworkDelay * 1_000_000_000))
        
        // Check authentication
        if !keychainService.isLoggedIn() {
            throw APIError.unauthorized
        }
        
        return mockTravelSegments
    }
    
    func createTravelSegment(segment: TravelSegmentDTO) async throws -> TravelSegmentDTO {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedNetworkDelay * 1_000_000_000))
        
        // Check authentication
        if !keychainService.isLoggedIn() {
            throw APIError.unauthorized
        }
        
        // Create new segment with server-generated ID
        var newSegment = segment
        newSegment.id = UUID().uuidString
        
        // Add to mock data
        mockTravelSegments.append(newSegment)
        
        return newSegment
    }
    
    func updateTravelSegment(segment: TravelSegmentDTO) async throws -> TravelSegmentDTO {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedNetworkDelay * 1_000_000_000))
        
        // Check authentication
        if !keychainService.isLoggedIn() {
            throw APIError.unauthorized
        }
        
        // Find and update the segment
        if let index = mockTravelSegments.firstIndex(where: { $0.id == segment.id }) {
            mockTravelSegments[index] = segment
            return segment
        } else {
            throw APIError.serverError("Travel segment not found")
        }
    }
    
    func deleteTravelSegment(id: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedNetworkDelay * 1_000_000_000))
        
        // Check authentication
        if !keychainService.isLoggedIn() {
            throw APIError.unauthorized
        }
        
        // Remove segment if it exists
        if let index = mockTravelSegments.firstIndex(where: { $0.id == id }) {
            mockTravelSegments.remove(at: index)
        } else {
            throw APIError.serverError("Travel segment not found")
        }
    }
    
    // MARK: - CSV Import Methods
    
    func importCSV(fileURL: URL) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedNetworkDelay * 1_000_000_000))
        
        // Check authentication
        if !keychainService.isLoggedIn() {
            throw APIError.unauthorized
        }
        
        // Generate task ID
        let taskId = "task_\(UUID().uuidString)"
        
        // Set initial status to pending
        mockImportTasks[taskId] = .pending
        
        // Simulate background processing
        Task {
            try? await Task.sleep(nanoseconds: UInt64(2.0 * 1_000_000_000))
            mockImportTasks[taskId] = .processing
            
            try? await Task.sleep(nanoseconds: UInt64(3.0 * 1_000_000_000))
            
            // Randomly succeed or fail to simulate real-world behavior
            let randomSuccess = Bool.random()
            mockImportTasks[taskId] = randomSuccess ? .completed : .failed
            
            if randomSuccess {
                // Add some fake imported segments
                let importedSegment = TravelSegmentDTO(
                    id: UUID().uuidString,
                    startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                    endDate: Calendar.current.date(byAdding: .day, value: -20, to: Date())!,
                    countryCode: "ES",
                    notes: "Imported from CSV",
                    updatedAt: Date(),
                    createdAt: Date()
                )
                mockTravelSegments.append(importedSegment)
            }
        }
        
        return taskId
    }
    
    func checkImportStatus(taskId: String) async throws -> ImportStatus {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedNetworkDelay * 1_000_000_000))
        
        // Check authentication
        if !keychainService.isLoggedIn() {
            throw APIError.unauthorized
        }
        
        // Return status or error if not found
        if let status = mockImportTasks[taskId] {
            return status
        } else {
            throw APIError.serverError("Import task not found")
        }
    }
    
    // MARK: - Calculations Methods
    
    func fetchSchengenStatus() async throws -> SchengenStatusDTO {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(simulatedNetworkDelay * 1_000_000_000))
        
        // Check authentication
        if !keychainService.isLoggedIn() {
            throw APIError.unauthorized
        }
        
        // Calculate mock Schengen status
        let schengenSegments = mockTravelSegments.filter { segment in
            // Check if it's a Schengen country (this would normally be done server-side)
            let schengenCountries = ["AT", "BE", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", 
                                      "IS", "IT", "LV", "LI", "LT", "LU", "MT", "NL", "NO", "PL", 
                                      "PT", "SK", "SI", "ES", "SE", "CH"]
            return schengenCountries.contains(segment.countryCode)
        }
        
        // Mock calculation (in reality would be more complex)
        let daysUsed = min(schengenSegments.count * 5, 90) // Mock calculation
        
        return SchengenStatusDTO(
            daysUsed: daysUsed,
            daysRemaining: 90 - daysUsed,
            currentStatus: daysUsed < 90 ? "In" : "Out",
            periodEndDate: Calendar.current.date(byAdding: .day, value: 180, to: Date())!
        )
    }
} 