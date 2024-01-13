import SwiftUI
import Firebase

struct UserSignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userName = ""
    @State private var userProfession = ""
    @State private var userOwnKit = false
    @State private var userFlashExp = false
    @State private var userBeautyLights = false
    @State private var userExternalLights = false
    @State private var userPracticalLights = false
    @State private var userIsLoggedIn = false
    
    // Binding to the array of gaffers
    @Binding var gaffers: [User]
    @State private var isUserSignedUp = false
    
    var body: some View {
        if userIsLoggedIn {
            ListView()
        }
        else
        {
            content
        }
        
    }
    
    var content: some View {
        NavigationView {
            Form {
                Section(header: Text("Sign Up Information")) {
                    TextField("Email", text: $email)
                        .foregroundColor(email.isEmpty ? Color.gray : Color.black)
                    SecureField("Password", text: $password)
                        .foregroundColor(password.isEmpty ? Color.gray : Color.black)
                }
                Section(header: Text("User Information")) {
                    TextField("Name", text: $userName)
                    TextField("Profession", text: $userProfession)
                }
                
                Section(header: Text("Experience")) {
                    Toggle("Own Kit", isOn: $userOwnKit)
                    Toggle("Flash Experience", isOn: $userFlashExp)
                }
                
                Section(header: Text("Lighting Preferences")) {
                    Toggle("Beauty Lights", isOn: $userBeautyLights)
                    Toggle("External Lights", isOn: $userExternalLights)
                    Toggle("Practical Lights", isOn: $userPracticalLights)
                }
                
                Section {
                    VStack{
                        Button(action: {
                            register()
                            let user = User(
                                name: userName,
                                profession: userProfession,
                                ownKit: userOwnKit,
                                flashExp: userFlashExp,
                                beautyLights: userBeautyLights,
                                externalLights: userExternalLights,
                                practicalLights: userPracticalLights
                            )
                            
                            gaffers.append(user)
                            FirebaseService.shared.addUser(user) // Store user in Firebase
                            // Optionally, you can reset the form fields if needed
                            userName = ""
                            userProfession = ""
                            // ... reset other fields if needed ...
                        })
                        {
                            Text("Sign Up")
                        }
                        
                        Button(action: {
                            login()
                        }) {
                            Text("Login")
                        }
                    }
                }
                .onAppear {
                    Auth.auth().addStateDidChangeListener { auth, user in
                        if user != nil {
                            userIsLoggedIn.toggle()
                        }
                    }
                }
            }
            .navigationBarTitle("User Sign Up")
        }
    }
    
    // Function to register user using Firebase Authentication
    private func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // Function to log in user using Firebase Authentication
    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
