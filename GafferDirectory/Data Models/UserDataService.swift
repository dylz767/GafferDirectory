//import Firebase
//import CoreLocation
//
//class UserDataService {
//    static let shared = UserDataService() // Singleton instance if needed
//    private var db = Firestore.firestore() // Firestore instance
//    
//    // This method adds a user to Firestore
//    func addUser(userProfessions: [String], usersName: String, emailAdd: String, location: String) {
//        guard let currentUser = Auth.auth().currentUser else {
//            print("User is not authenticated. Cannot add user.")
//            return
//        }
//        
//        let geocoder = CLGeocoder()
//        geocoder.geocodeAddressString(location) { placemarks, error in
//            guard error == nil, let placemark = placemarks?.first, let city = placemark.locality else {
//                print("Geocoding error: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            
//            let userId = currentUser.uid
//            let ref = self.db.collection("Users").document(userId)
//            
//            var userData: [String: Any] = [
//                "name": usersName,
//                "profession": userProfessions,
//                "id": userId,
//                "userId": userId,
//                "email": emailAdd,
//                "location": city // Here we use the city obtained from geocoding
//            ]
//            
//            ref.setData(userData) { error in
//                if let error = error {
//                    print("Error adding user:", error.localizedDescription)
//                } else {
//                    print("User added successfully with city: \(city)")
//                }
//            }
//        }
//    }
//}
