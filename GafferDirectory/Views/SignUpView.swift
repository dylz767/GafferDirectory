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
    @State private var selectedProfessions: [String] = []
    @State private var isLocationValid: Bool? = nil
    let allProfessions = ["DP", "Gaffer", "Spark", "Producer", "Art Department", "HMUA", "Editor", "Colour Grade", "Runner", "Director", "Photographer", "Photographer Assistant"]


    
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
                
                Menu(professionSelectionText()) {
                        ForEach(allProfessions, id: \.self) { profession in
                            Button(profession) {
                                toggleProfession(profession)
                            }.disabled(selectedProfessions.count >= 3 && !selectedProfessions.contains(profession))
                        }
                        Button("Clear Selection") {
                            selectedProfessions.removeAll()
                        }
                    }
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
                if isLocationValid == false {
                    Text("Enter valid location")
                }
                else
                {
                    
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
               if geocodedCity.isEmpty {
                   isLocationValid = false
               } else {
                   isLocationValid = true
                   Auth.auth().createUser(withEmail: newEmail, password: password) { authResult, error in
                       // User creation logic
                       if let error = error as NSError? {
                           if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                               emailInvalid = true
                           } else {
                               print("Error creating user: \(error.localizedDescription)")
                           }
                           return
                       }
                       dataManager.addUser(userProfessions: selectedProfessions, usersName: newName, emailAdd: newEmail, location: geocodedCity)
                       isSignUpSuccess = true
                       signInUser()
                   }
               }
           }
       }
    private func professionPicker() -> some View {
            Menu {
                ForEach(allProfessions, id: \.self) { profession in
                    Button(profession) {
                        if selectedProfessions.contains(profession) {
                            selectedProfessions.removeAll { $0 == profession }
                        } else if selectedProfessions.count < 3 {
                            selectedProfessions.append(profession)
                        }
                    }
                }
            } label: {
                Text("Select Profession(s)")
                    .foregroundColor(.blue)
            }
        }
    private func toggleProfession(_ profession: String) {
        if selectedProfessions.contains(profession) {
            selectedProfessions.removeAll { $0 == profession }
        } else if selectedProfessions.count < 3 {
            selectedProfessions.append(profession)
        }
    }

    private func professionSelectionText() -> String {
        if selectedProfessions.isEmpty {
            return "Select Profession(s)"
        } else {
            return selectedProfessions.joined(separator: ", ")
        }
    }
    private func signUpWithLocation(_ city: String) {
        Auth.auth().createUser(withEmail: newEmail, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }
            print("User created successfully!")

            // Ensure selectedProfessions is an array of selected profession strings
            self.dataManager.addUser(userProfessions: selectedProfessions, usersName: newName, emailAdd: newEmail, location: city)

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
