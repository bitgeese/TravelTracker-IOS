import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
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
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Button(action: {
                        // Login action will be implemented later
                        print("Login button tapped")
                    }) {
                        Text("Login")
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
                    print("Sign in with Apple tapped")
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                        Text("Sign in with Apple")
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
                NavigationLink(destination: RegistrationView()) {
                    Text("Don't have an account? Sign up")
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

// Preview provider for Canvas
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
