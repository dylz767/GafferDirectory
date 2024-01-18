import SwiftUI
import Firebase

struct SignUpView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var newProfession = ""
    @State private var newName = ""
    @State private var newEmail = ""
    @State private var password = ""
    @State private var isSignUpSuccess = false
    @State private var navigateToListView = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Text("New User Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 30)
                
                TextField("Email", text: $newEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Profession", text: $newProfession)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Name", text: $newName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Already registered? Login") {
                    presentationMode.wrappedValue.dismiss() // Dismiss SignUpView to go back
                }
                .foregroundColor(.blue)
                .padding(.bottom, 20)

                Button("Sign Up") {
                    signUp()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                    
                if isSignUpSuccess {
                    Text("Sign up successful!")
                        .foregroundColor(.green)
                        .padding()
                }

                Spacer()
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .onAppear {
                resetSignUpForm() // Reset the form fields when the view appears
            }
            .background(
                NavigationLink(destination: ListView(), isActive: $navigateToListView) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }

    private func signUp() {
        Auth.auth().createUser(withEmail: newEmail, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            } else {
                print("User created successfully!")
                self.dataManager.addUser(userProfession: newProfession, usersName: newName, emailAdd: newEmail)
                self.isSignUpSuccess = true

                // Automatically log in the user after successful sign-up
                self.signInUser()
            }
        }
    }

    private func signInUser() {
        Auth.auth().signIn(withEmail: newEmail, password: password) { authResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
            } else {
                print("User signed in successfully!")
                // Update any state variable or perform navigation as needed
                // For example, set a state variable to true to navigate to the main app view
                self.navigateToListView = true // Assuming this state triggers navigation to the main view
            }
        }
    }
    private func resetSignUpForm() {
        // Reset all the form fields to empty strings
        newProfession = ""
        newName = ""
        newEmail = ""
        password = ""
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(DataManager())
    }
}
