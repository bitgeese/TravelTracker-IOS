import Foundation
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    private let apiService: APIServiceProtocol
    private let keychainService: KeychainServiceProtocol
    
    init() {
        self.apiService = ServiceLocator.shared.apiService
        self.keychainService = ServiceLocator.shared.keychainService
    }
    
    /// Check if user is logged in
    func checkLoginStatus() {
        isLoggedIn = keychainService.isLoggedIn()
    }
    
    /// Login with email and password
    func login(email: String, password: String) async -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            await MainActor.run {
                self.error = "Email and password are required"
            }
            return false
        }
        
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let _ = try await apiService.login(email: email, password: password)
            
            await MainActor.run {
                self.isLoading = false
                self.isLoggedIn = true
            }
            return true
        } catch let error as APIError {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            return false
        } catch {
            await MainActor.run {
                self.error = "An unknown error occurred"
                self.isLoading = false
            }
            return false
        }
    }
    
    /// Register with email, password, and optional names
    func register(email: String, password: String, confirmPassword: String, firstName: String?, lastName: String?) async -> Bool {
        // Validate inputs
        if email.isEmpty || password.isEmpty {
            await MainActor.run {
                self.error = "Email and password are required"
            }
            return false
        }
        
        if password != confirmPassword {
            await MainActor.run {
                self.error = "Passwords do not match"
            }
            return false
        }
        
        // Validate email format
        if !isValidEmail(email) {
            await MainActor.run {
                self.error = "Please enter a valid email address"
            }
            return false
        }
        
        // Validate password strength
        if password.count < 8 {
            await MainActor.run {
                self.error = "Password must be at least 8 characters long"
            }
            return false
        }
        
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            let _ = try await apiService.register(email: email, password: password, firstName: firstName, lastName: lastName)
            
            await MainActor.run {
                self.isLoading = false
                self.isLoggedIn = true
            }
            return true
        } catch let error as APIError {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
            return false
        } catch {
            await MainActor.run {
                self.error = "An unknown error occurred"
                self.isLoading = false
            }
            return false
        }
    }
    
    /// Logout
    func logout() async {
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            try await apiService.logout()
            
            await MainActor.run {
                self.isLoading = false
                self.isLoggedIn = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                // We still want to log out locally even if the server request fails
                self.isLoggedIn = false
            }
        }
    }
    
    // Helper method to validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
} 