import SwiftUI
import Firebase

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @Binding var isSignedIn: Bool // Binding to update sign-in state
    @Environment(\.presentationMode) var presentationMode

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
                    do {
                        //very useful way of closing the current page to open the next
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                
                NavigationLink(destination: SignUpView(), label: {
                    Text("Don't have an account?")
                        .foregroundColor(.blue)
                })
                .padding(.top, 20)
            }
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
            }
        }
    }
}
