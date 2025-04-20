import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegistration = false
    @State private var showPassword = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Logo/Header
                    VStack(spacing: 10) {
                        Image(systemName: "airplane.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                        
                        Text("Travel Tracker")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Track your travel time for visa compliance")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 30)
                    
                    // Login Form
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        
                        HStack {
                            if showPassword {
                                TextField("Password", text: $password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("Password", text: $password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        
                        if let error = authViewModel.error {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 5)
                        }
                        
                        Button(action: login) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Log In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(authViewModel.isLoading)
                        
                        Button("Forgot Password?") {
                            // Implement in future
                        }
                        .font(.callout)
                        .padding(.top, 5)
                    }
                    .padding(.horizontal)
                    
                    // Registration Link
                    VStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        
                        Button("Create Account") {
                            showingRegistration = true
                        }
                        .font(.headline)
                        .padding(.top, 2)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .sheet(isPresented: $showingRegistration) {
                RegistrationView()
                    .environmentObject(authViewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func login() {
        Task {
            await authViewModel.login(email: email, password: password)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
} 