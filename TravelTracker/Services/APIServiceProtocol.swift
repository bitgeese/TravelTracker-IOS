import Foundation

/// Protocol defining the API service for backend communication
protocol APIServiceProtocol {
    // MARK: - Authentication
    func login(email: String, password: String) async throws -> String // Returns authentication token
    func register(email: String, password: String, firstName: String?, lastName: String?) async throws -> String // Returns authentication token
    func refreshToken() async throws -> String // Returns new auth token using refresh token
    func logout() async throws
    
    // MARK: - Travel Segments
    func fetchTravelSegments() async throws -> [TravelSegmentDTO]
    func createTravelSegment(segment: TravelSegmentDTO) async throws -> TravelSegmentDTO
    func updateTravelSegment(segment: TravelSegmentDTO) async throws -> TravelSegmentDTO
    func deleteTravelSegment(id: String) async throws
    
    // MARK: - CSV Import
    func importCSV(fileURL: URL) async throws -> String // Returns task ID
    func checkImportStatus(taskId: String) async throws -> ImportStatus
    
    // MARK: - Calculations
    func fetchSchengenStatus() async throws -> SchengenStatusDTO
}

/// Import status enum
enum ImportStatus: String, Codable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    
    var description: String {
        switch self {
        case .pending:
            return "Waiting to start"
        case .processing:
            return "Processing..."
        case .completed:
            return "Import completed"
        case .failed:
            return "Import failed"
        }
    }
}

/// API error enum
enum APIError: Error {
    case unauthorized
    case networkError
    case serverError(String)
    case decodingError
    case invalidInput
    case requestFailed(Int)
    
    var localizedDescription: String {
        switch self {
        case .unauthorized:
            return "Authentication required"
        case .networkError:
            return "Network connection error"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "Error parsing response data"
        case .invalidInput:
            return "Invalid input provided"
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        }
    }
} 