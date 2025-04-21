//
//  AuthViewModel.swift
//  NomadTravelTracker
//
//  Created by Maciej Janowski on 21/04/2025.
//
import Foundation
import SwiftUI
import AuthenticationServices

class AuthViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    
    // MARK: - Private Properties
    private var presentationAnchor: ASPresentationAnchor?
    
    // MARK: - Init
    
    override init() {
        super.init()
        checkAuthStatus()
    }
    
    // MARK: - public methods
    
    func checkAuthStatus() {
        do {
            if try KeychainService.retrieveAccessToken() != nil {
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
            }
        } catch {
            self.isAuthenticated = false
            self.errorMessage = "Error checking authentication status: \(error.localizedDescription)"
        }
    }
    
    func signIn(email: String, password: String) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            let tokenResponse = try await APIService.shared.loginWithEmail(email: email, password: password)
            
            // Store Tokens in keychain
            try KeychainService.saveAccessToken(tokenResponse.access)
            try KeychainService.saveRefreshToken(tokenResponse.refresh)
            
            await MainActor.run {
                self.isAuthenticated = true
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Authentication failed: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func signOut() {
        do {
            try KeychainService.deleteTokens()
            self.isAuthenticated = false
        } catch {
            self.errorMessage = "Sign out failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: Sign in with apple
    
    func startSignInWithApple(anchor: ASPresentationAnchor) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        self.presentationAnchor = anchor
        authorizationController.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityToken = appleIDCredential.identityToken,
           let tokenString = String(data: identityToken, encoding: .utf8) {
            Task {
                await MainActor.run {
                    self.isLoading = true
                }
                
                do {
                    let tokenResponse = try await APIService.shared.loginWithApple(appleIdToken: tokenString)
                    
                    // Store tokens in kaychain
                    try KeychainService.saveAccessToken(tokenResponse.access)
                    try KeychainService.saveRefreshToken(tokenResponse.refresh)
                    
                    await MainActor.run {
                        self.isAuthenticated = true
                        self.isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = "Failed to authenticate with Apple: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.errorMessage = "Sign in with Apple failed: \(error.localizedDescription)"
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let anchor = presentationAnchor else {
            fatalError("Presentation anchor not set")
        }
        return anchor
    }
}
