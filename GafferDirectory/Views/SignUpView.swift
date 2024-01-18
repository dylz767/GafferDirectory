import SwiftUI
import Firebase
import CoreLocation

struct SignUpView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var newProfession = ""
    @State private var newName = ""
    @State private var newEmail = ""
    @State private var password = ""
    @State private var address = ""
    @State private var isSignUpSuccess = false
    @State private var navigateToListView = false
    @State private var emailInvalid = false
    
    
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
                
                TextField("Address", text: $address)
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
                    
                if emailInvalid {
                    Text("That email is already in use")
                }
                else {
                    
                }
               
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
            .navigationBarBackButtonHidden(true)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func signUp() {
        geocodeAddress(address) { geocodedCity in
            Auth.auth().createUser(withEmail: newEmail, password: password) { authResult, error in
                if let error = error as NSError? {
                    // Handle different error codes here
                    if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                        print("Email already exists")
                        emailInvalid = true
                    } else {
                        print("Error creating user: \(error.localizedDescription)")
                        
                    }
                    return
                }
                print("User created successfully!")
                self.dataManager.addUser(userProfession: newProfession, usersName: newName, emailAdd: newEmail, location: geocodedCity)
                self.isSignUpSuccess = true
                self.signInUser()
            }
        }
    }
    private func signUpWithLocation(_ city: String) {
        Auth.auth().createUser(withEmail: newEmail, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }
            print("User created successfully!")
            self.dataManager.addUser(userProfession: newProfession, usersName: newName, emailAdd: newEmail, location: city)
            self.isSignUpSuccess = true
            self.signInUser()
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
private func geocodeAddress(_ address: String, completion: @escaping (String) -> Void) {
    CLGeocoder().geocodeAddressString(address) { placemarks, error in
        guard let place = placemarks?.first, error == nil else {
            print("Geocoding failed: \(error?.localizedDescription ?? "No error description")")
            completion("") // Send empty string or handle error as needed
            return
        }
        let geocodedCity = place.locality ?? ""
        completion(geocodedCity)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(DataManager())
    }
}
