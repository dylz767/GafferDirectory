import SwiftUI
import Firebase

struct SignUpView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var newProfession = ""
    @State private var newName = ""
    @State private var newEmail = ""
    @State private var password = ""
    @State private var isSignUpSuccess = false
    @State private var showSignInView = false
    
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

                NavigationLink(destination: SignInView()) {
                    Text("Already registered? Login")
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                        .navigationBarBackButtonHidden(true)
                }
                .navigationBarBackButtonHidden(true)
                

                Button("Sign Up") {
                    signUp()
                }
                .navigationBarBackButtonHidden(true)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                .navigationBarBackButtonHidden(true)

                if isSignUpSuccess {
                    Text("Sign up successful!")
                        .foregroundColor(.green)
                        .padding()
                }

                Spacer()
                    
            }
            
            .padding()
            
        }
        .navigationBarBackButtonHidden(true)
    }

    private func signUp() {
        Auth.auth().createUser(withEmail: newEmail, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            } else {
                print("User created successfully!")
                dataManager.addUser(userProfession: newProfession, usersName: newName, emailAdd: newEmail)
                isSignUpSuccess = true
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(DataManager())
    }
}
