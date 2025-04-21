//
//  APIService.swift
//  NomadTravelTracker
//
//  Created by Maciej Janowski on 21/04/2025.
//

import Foundation
import Alamofire

/// A service class responsible for handling API network requests
class APIService {
    /// Shared singleton instance
    static let shared = APIService()
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    // MARK: - Properties
    
    private let baseURL = "http://localhost:8000"
    
    // MARK: - Authentication Models
    
    struct LoginCredentials: Encodable {
        let email: String
        let password: String
    }
    
    struct TokenResponse: Decodable {
        let access: String
        let refresh: String
    }
    
    struct RefreshTokenRequest: Encodable {
        let refresh: String
    }
    
    struct RegistrationRequest: Encodable {
        let email: String
        let password: String
        let password_confirm: String
        let first_name: String
        let last_name: String
    }
    
    // MARK: - Authentication Methods
    
    /// Login with email and password
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    /// - Returns: Token response with access and refresh tokens
    func loginWithEmail(email: String, password: String) async throws -> TokenResponse {
        let credentials = LoginCredentials(email: email, password: password)
        
        let url = "\(baseURL)/api/auth/login/email/"
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                       method: .post,
                       parameters: credentials,
                       encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: TokenResponse.self) { response in
                switch response.result {
                case .success(let tokenResponse):
                    continuation.resume(returning: tokenResponse)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Login with Apple
    /// - Parameter appleIdToken: Token received from Sign in with Apple
    /// - Returns: JWT token response
    func loginWithApple(appleIdToken: String) async throws -> TokenResponse {
        let url = "\(baseURL)/api/auth/login/apple/"
        
        // We need to know the exact format the backend expects
        // This is a placeholder structure
        let parameters: [String: Any] = ["id_token": appleIdToken]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                       method: .post,
                       parameters: parameters,
                       encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: TokenResponse.self) { response in
                switch response.result {
                case .success(let tokenResponse):
                    continuation.resume(returning: tokenResponse)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Register a new user
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    ///   - passwordConfirm: Password confirmation
    ///   - firstName: User's first name
    ///   - lastName: User's last name
    /// - Returns: Success or failure
    func registerUser(email: String,
                      password: String,
                      passwordConfirm: String,
                      firstName: String,
                      lastName: String) async throws -> Bool {
        
        let registrationData = RegistrationRequest(
            email: email,
            password: password,
            password_confirm: passwordConfirm,
            first_name: firstName,
            last_name: lastName
        )
        
        let url = "\(baseURL)/api/auth/register/"
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                       method: .post,
                       parameters: registrationData,
                       encoder: JSONParameterEncoder.default)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    continuation.resume(returning: true)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Refresh the JWT access token using a refresh token
    /// - Parameter refreshToken: The refresh token
    /// - Returns: New access token
    func refreshToken(refreshToken: String) async throws -> String {
        let refreshRequest = RefreshTokenRequest(refresh: refreshToken)
        
        let url = "\(baseURL)/api/auth/token/refresh/"
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                       method: .post,
                       parameters: refreshRequest,
                       encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: TokenResponse.self) { response in
                switch response.result {
                case .success(let tokenResponse):
                    continuation.resume(returning: tokenResponse.access)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Create an authorization header with the access token
    /// - Parameter token: The JWT access token
    /// - Returns: HTTP headers with authorization
    func authHeaders(token: String) -> HTTPHeaders {
        return ["Authorization": "Bearer \(token)"]
    }
}
