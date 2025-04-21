//
//  RegistrationView.swift
//  NomadTravelTracker
//
//  Created by Maciej Janowski on 21/04/2025.
//
import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var password1 = ""
    @State private var password2 = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App logo/title
                Text("Travel Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 50)
                
                // Form fields
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $password1)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    SecureField("Repeat Password", text: $password2)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Button(action: {
                        // Login action will be implemented later
                        print("Register button tapped")
                    }) {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Divider with "or" text
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(.systemGray4))
                    
                    Text("or")
                        .foregroundColor(Color(.systemGray))
                        .padding(.horizontal, 8)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(.systemGray4))
                }
                .padding(.horizontal)
                
                // Sign in with Apple button
                Button(action: {
                    // Apple sign in will be implemented later
                    print("Sign up with Apple tapped")
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                        Text("Sign up with Apple")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Registration link
                NavigationLink(destination: LoginView()) {
                    Text("Already have an account? Sign in")
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

// Preview provider for Canvas
struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
