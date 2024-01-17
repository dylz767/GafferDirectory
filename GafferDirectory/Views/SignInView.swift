import SwiftUI
import Firebase

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isProfileActive = false
    @State private var isListViewActive = false
    @State private var isSignInSuccess = false
    @State private var isSignInViewActive = true
    @Binding var isSignedIn: Bool // Added binding

    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                NavigationLink(destination: ProfileView(), isActive: $isSignInSuccess) {
                    EmptyView()
                }
                .hidden()

                Button(action: {
                    signIn()
                }) {
                    Text("Login")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                .navigationBarBackButtonHidden(true)
                NavigationLink(destination: SignUpView()) {
                    Text("Don't have an account?")
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                        .navigationBarBackButtonHidden(true)
                }
                .navigationBarBackButtonHidden(true)
                
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("Sign in", displayMode: .inline)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func signIn() {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                } else {
                    print("Sign in successful!")
                    self.isSignedIn = true // Update this on successful sign-in
                }
            }
        }
    }
