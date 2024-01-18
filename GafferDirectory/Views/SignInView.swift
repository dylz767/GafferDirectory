import SwiftUI
import Firebase

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @Binding var isSignedIn: Bool // Binding to update sign-in state
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToSignUp = false // State for controlling navigation

    var body: some View {
        NavigationView {
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Login") {
                    signIn()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                
                Button("Don't have an account?") {
                                    navigateToSignUp = true // Trigger navigation
                                }
                .padding(.top, 20)
            }
            .background(
                            NavigationLink(destination: SignUpView(), isActive: $navigateToSignUp) {
                                EmptyView()
                            }
                            .hidden()
                        )
            .padding()
            .navigationBarTitle("Sign in", displayMode: .inline)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                // Optionally, show an alert or some UI feedback
            } else {
                print("Sign in successful!")
                self.isSignedIn = true // Update this on successful sign-in
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
