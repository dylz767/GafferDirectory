import Foundation
import CoreLocation
import Firebase

extension DataManager {
    func fetchUserProfession(userId: String, completion: @escaping (String?) -> Void) {
        let userRef = db.collection("Users").document(userId)
        userRef.getDocument { document, error in
            guard let document = document, document.exists, error == nil else {
                print("Error fetching user profession:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }
            let profession = document.get("profession") as? String
            completion(profession)
        }
    }
}

extension DataManager {
    func fetchCurrentUserJobs() {
        self.jobPostings.removeAll()
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated. Cannot fetch jobs.")
            return
        }

        let ref = db.collection("Jobs").whereField("userID", isEqualTo: currentUserId)
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print("Error fetching jobs:", error!.localizedDescription)
                return
            }

            if let snapshot = snapshot {
                self.jobPostings = snapshot.documents.compactMap { document -> JobPosting? in
                    let data = document.data()
                    let id = data["id"] as? String ?? ""
                    let userID = data["userID"] as? String ?? ""
                    let companyName = data["companyName"] as? String ?? ""
                    let jobDescription = data["jobDescription"] as? String ?? ""
                    let postcode = data["postcode"] as? String ?? ""
                    let coordinates = data["coordinates"] as? [String: Any] ?? [:]
                    let latitude = coordinates["latitude"] as? Double ?? 0.0
                    let longitude = coordinates["longitude"] as? Double ?? 0.0

                    return JobPosting(id: id, userID: userID, companyName: companyName, jobDescription: jobDescription, coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), postcode: postcode)
                }
                print("Fetched \(self.jobPostings.count) jobs for current user")
            }
        }
    }
}
extension DataManager {
    // MARK: Favorites Management
    func fetchCurrentUserFavorites() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Error: Current user is not logged in.")
            self.currentUserFavorites = Set<String>()
            return
        }

        let userRef = db.collection("Users").document(currentUserId) // Using Firebase Auth UID as the document ID

        userRef.getDocument { (document, error) in
            guard let document = document, document.exists, error == nil else {
                print("Error fetching favorites:", error?.localizedDescription ?? "Unknown error")
                self.currentUserFavorites = Set<String>()
                return
            }

            let favorites = document.get("favorites") as? [String] ?? []
            self.currentUserFavorites = Set(favorites)
        }
    }
    
//    func createUserDocument(userId: String, name: String, email: String) {
//        let userRef = db.collection("Users").document(userId)
//        userRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                print("Document already exists")
//            } else {
//                print("Creating new document for user")
//                userRef.setData(["name" : name, "email": email, "favorites": []])
//            }
//        }
//    }
    func addFavorite(favoriteId: String, completion: (() -> Void)? = nil) {
            let userRef = db.collection("Users").document(currentUserId)  // currentUserId is the document ID

            userRef.updateData([
                "favorites": FieldValue.arrayUnion([favoriteId])
            ]) { error in
                if let error = error {
                    print("Error adding favorite: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                                self.currentUserFavorites.insert(favoriteId)
                                completion?()
                            }
                }
            }
        }
    
    func removeFavorite(favoriteId: String, completion: (() -> Void)? = nil) {
        let userRef = db.collection("Users").document(currentUserId)  // currentUserId is the document ID

        userRef.updateData([
            "favorites": FieldValue.arrayRemove([favoriteId])
        ]) { error in
            if let error = error {
                print("Error removing favorite: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.currentUserFavorites.remove(favoriteId)
                    completion?()
                }
                
            }
        }
    }
}
extension DataManager {
    func fetchCurrentUserFavorites(completion: @escaping (Set<String>) -> Void) {
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                print("Error: Current user is not logged in.")
                completion([])
                return
            }

            let db = Firestore.firestore()
            let userRef = db.collection("Users").document(currentUserId)

            userRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let favorites = document.get("favorites") as? [String] ?? []
                    completion(Set(favorites))
                } else {
                    print("Document does not exist or error: \(error?.localizedDescription ?? "")")
                    completion([])
                }
            }
        }

    func toggleFavorite(_ userId: String) {
           guard let currentUserId = Auth.auth().currentUser?.uid else {
               print("Error: Current user is not logged in.")
               return
           }

           let db = Firestore.firestore()
           let userRef = db.collection("Users").document(currentUserId)

           userRef.getDocument { (document, error) in
               if let document = document, document.exists {
                   var favorites = document.get("favorites") as? [String] ?? []
                   
                   if let index = favorites.firstIndex(of: userId) {
                       // User is already a favorite, remove them
                       favorites.remove(at: index)
                   } else {
                       // User is not a favorite, add them
                       favorites.append(userId)
                   }
                   
                   // Update the database
                   userRef.updateData(["favorites": favorites]) { error in
                       if let error = error {
                           print("Error updating favorites: \(error.localizedDescription)")
                       } else {
                           print("Favorites successfully updated.")
                       }
                   }
               } else {
                   print("Document does not exist or error: \(error?.localizedDescription ?? "")")
               }
           }
       }
}
extension DataManager {
    func respondToJobRequest(_ requestId: String, accept: Bool) {
        let requestRef = db.collection("jobRequests").document(requestId)
        
        if accept {
            // Update the request's status to "accepted"
            requestRef.updateData(["status": "accepted"])
        } else {
            // Remove the request from the user's account and delete or update the request
            requestRef.updateData(["status": "declined"]) { error in
                if let error = error {
                    print("Error updating job request status: \(error.localizedDescription)")
                } else {
                    // Assuming the current user is the one responding to the request
                    let currentUserRef = self.db.collection("Users").document(self.currentUserId)
                    currentUserRef.updateData([
                        "jobRequests": FieldValue.arrayRemove([requestId])
                    ])
                }
            }
        }
    }
}
extension DataManager {
    func sendJobRequest(to receiverId: String, for job: JobPosting) {
        // Create job request document in "jobRequests" collection
        let jobRequestRef = db.collection("jobRequests").document()
        let jobRequestId = jobRequestRef.documentID
        let jobRequestData: [String: Any] = [
            "id": jobRequestId,
            "jobId": job.id,
            "senderId": currentUserId,
            "receiverId": receiverId,
            "companyName": job.companyName,
            "jobDescription": job.jobDescription,
            "status": "pending",
            "timestamp": Timestamp(date: Date()) // Use Firestore Timestamp for the current time
        ]

        jobRequestRef.setData(jobRequestData) { error in
            if let error = error {
                print("Error sending job request: \(error.localizedDescription)")
            } else {
                // Update receiver's account with the job request ID
                let receiverRef = self.db.collection("Users").document(receiverId)
                receiverRef.updateData([
                    "jobRequests": FieldValue.arrayUnion([jobRequestId])
                ]) { error in
                    if let error = error {
                        print("Error adding job request to user account: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

class DataManager: ObservableObject {
    
    
    @Published var accounts: [Account] = []
    @Published var users: [User] = []
    @Published var jobPostings: [JobPosting] = []
    @Published var geocodingResult: Result<CLLocationCoordinate2D, Error>?
    @Published var geocodedJobPostings: [GeocodedJobPosting] = []
    @Published var currentUserFavorites: Set<String> = []
    @Published var jobPostedID: String? = nil
    @Published var selectedCrewMembers: [String: String] = [:]
    @Published var jobRequests: [JobRequest] = []
    
    var currentUserId: String {
            return Auth.auth().currentUser?.uid ?? ""
        }
    
    private let geocoder = CLGeocoder()
    private var db = Firestore.firestore()

    init() {
        fetchUsers()
    }
    
    // Modify this function to only fetch job requests for the current user
    func fetchJobRequestsForCurrentUser() {
        let userId = currentUserId
        
        // Assuming you want to fetch jobRequests for job postings created by the current user
        db.collection("jobRequests")
            .whereField("receiverId", isEqualTo: userId)
            // Optionally, further filter by jobId if needed
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching job requests: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No job requests found")
                    return
                }
                
                self.jobRequests = documents.compactMap { queryDocumentSnapshot -> JobRequest? in
                    let data = queryDocumentSnapshot.data()
                    let jobId = data["jobId"] as? String ?? ""
                    // Optionally, check if jobId matches one of the user's job postings if needed
                    
                    return JobRequest(id: queryDocumentSnapshot.documentID, dictionary: data)
                }
            }
    }
    func handleJobRequestDataFromFirestore() {
        // Assuming you have retrieved job request data from Firestore
        let jobRequestData: [String: Any] = [
            "id": "request123",
            "userId": "user123",
            "jobId": "job456",
            "senderId": "sender789",
            "companyName": "Example Company",
            "jobDescription": "Sample job description",
            "status": "pending",
            "timestamp": Timestamp(date: Date())
        ]

        // Initialize a JobRequest object using the dictionary
        let jobRequest = JobRequest(id: "request123", dictionary: jobRequestData)

        // Now you can work with the jobRequest object as needed
        print("Job Request ID: \(jobRequest.id)")
        print("Job Description: \(jobRequest.jobDescription)")
        // ... perform other operations with the jobRequest object ...
    }
    func sendJobRequestNotification(_ notification: JobRequestNotification) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("jobRequests").addDocument(data: [
            "id": notification.id,
            "jobId": notification.jobId,
            "senderId": notification.senderId,
            "receiverId": notification.receiverId,
            "companyName": notification.companyName,
            "jobDescription": notification.jobDescription,
            "status": notification.status.rawValue,
            "timestamp": FieldValue.serverTimestamp()
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
   
    func updateNotificationStatus(_ notificationId: String, _ status: NotificationStatus) {
            let db = Firestore.firestore()
            db.collection("jobRequests").document(notificationId).updateData(["status": status]) { error in
                if let error = error {
                    print("Error updating notification status: \(error.localizedDescription)")
                } else {
                    print("Notification status updated successfully.")
                }
            }
        }

        // Adds a job ID to a user's approved job list
        func addUserApprovedJob(_ userId: String, _ jobId: String) {
            let db = Firestore.firestore()
            // Assuming you have a collection for users where each user document contains an approvedJobs field
            // This field should be an array of job IDs
            db.collection("users").document(userId).updateData([
                "approvedJobs": FieldValue.arrayUnion([jobId])
            ]) { error in
                if let error = error {
                    print("Error adding job to user's approved list: \(error.localizedDescription)")
                } else {
                    print("Job added to user's approved list successfully.")
                }
            }
        }
    
    func addUser(userProfessions: [String], usersName: String, emailAdd: String, location: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("User is not authenticated. Cannot add user.")
            return
        }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { placemarks, error in
            guard error == nil, let placemark = placemarks?.first, let city = placemark.locality else {
                print("Geocoding error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let userId = currentUser.uid
            let ref = self.db.collection("Users").document(userId)

            var userData: [String: Any] = [
                "name": usersName,
                "profession": userProfessions,
                "id": userId,
                "userId": userId,
                "email": emailAdd,
                "location": city // Here we use the city obtained from geocoding
            ]

            ref.setData(userData) { error in
                if let error = error {
                    print("Error adding user:", error.localizedDescription)
                } else {
                    print("User added successfully with city: \(city)")
                }
            }
        }
    }
    func fetchUsers() {
            accounts.removeAll()
            let db = Firestore.firestore()
            let ref = db.collection("Users")
            ref.getDocuments { snapshot, error in
                guard error == nil else {
                    print("Error fetching users:", error!.localizedDescription)
                    return
                }
                if let snapshot = snapshot {
                    for document in snapshot.documents {
                        let data = document.data()

                        let id = data["id"] as? String ?? ""
                        let professions = data["profession"] as? [String] ?? [] // Expect an array
                        let name = data["name"] as? String ?? ""
                        let email = data["email"] as? String ?? ""
                        let userId = data["userId"] as? String ?? ""

                        let account = Account(id: id, userId: userId, name: name, professions: professions, email: email)
                        self.accounts.append(account)
                    }
                    print("Fetched \(self.accounts.count) users")
                }
            }
        }
    
    func fetchUsersFilteredByProfession(professions: [String]) async -> [Account] {
        var filteredAccounts: [Account] = []
        let db = Firestore.firestore()
        let ref = db.collection("Users")

        do {
            let snapshot = try await ref.getDocuments()
            for document in snapshot.documents {
                let data = document.data()

                let id = data["id"] as? String ?? ""
                let userProfessions = data["profession"] as? [String] ?? []
                let name = data["name"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let userId = data["userId"] as? String ?? ""

                if !professions.isEmpty && !userProfessions.contains(where: professions.contains) {
                    continue
                }

                let account = Account(id: id, userId: userId, name: name, professions: userProfessions, email: email)
                filteredAccounts.append(account)
            }
        } catch {
            print("Error fetching users:", error.localizedDescription)
        }

        return filteredAccounts
    }

    func fetchUsersByUserId(userId: String, completion: @escaping ([Account]) -> Void) {
        accounts.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Users").whereField("userId", isEqualTo: userId)
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print("Error fetching users by userID:", error!.localizedDescription)
                completion([])
                return
            }
            if let snapshot = snapshot {
                var userAccounts: [Account] = []
                for document in snapshot.documents {
                    let data = document.data()

                    let id = data["id"] as? String ?? "" // Corrected from userId to id
                    let userProfessions = data["profession"] as? [String] ?? [] // Corrected variable name
                    let name = data["name"] as? String ?? ""
                    let email = data["email"] as? String ?? ""

                    let account = Account(id: id, userId: userId, name: name, professions: userProfessions, email: email) // Corrected variable name
                    userAccounts.append(account)
                }
                print("Fetched \(userAccounts.count) users by userID")
                completion(userAccounts)
            }
        }
    }
    func fetchUserData(userId: String, completion: @escaping (Account?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("Users").document(userId)
        ref.getDocument { document, error in
            guard error == nil else {
                print(error!.localizedDescription)
                completion(nil)
                return
            }
            if let document = document, document.exists {
                let data = document.data()

                let id = data?["id"] as? String ?? ""
                let name = data?["name"] as? String ?? ""
                let userProfessions = data?["profession"] as? [String] ?? [] // Corrected variable name
                let email = data?["email"] as? String ?? ""
                let account = Account(id: id, userId: userId, name: name, professions: userProfessions, email: email) // Corrected variable name
                completion(account)
            } else {
                completion(nil)
            }
        }
    }
    func fetchUsersWithProfession(profession: String, completion: @escaping ([Account]) -> Void) {
        accounts.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Users").whereField("profession", arrayContains: profession)
        ref.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching users: \(error?.localizedDescription ?? "unknown error")")
                completion([])
                return
            }

            let filteredUsers = documents.compactMap { doc -> Account? in
                guard let id = doc.data()["id"] as? String,
                      let name = doc.data()["name"] as? String,
                      let email = doc.data()["email"] as? String,
                      let userId = doc.data()["userId"] as? String else { return nil }

                return Account(id: id, userId: userId, name: name, professions: [profession], email: email)
            }

            completion(filteredUsers)
        }
    }
    func fetchJobs() {
        jobPostings.removeAll()
        let ref = db.collection("Jobs")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print("Error fetching jobs:", error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()

                    let id = data["id"] as? String ?? ""
                    let userID = data["userID"] as? String ?? ""
                    let companyName = data["companyName"] as? String ?? ""
                    let jobDescription = data["jobDescription"] as? String ?? ""
                    let postcode = data["postcode"] as? String ?? ""

                    // Coordinates should be a dictionary, not a string
                    let coordinates = data["coordinates"] as? [String: Any] ?? [:]
                    // Latitude and longitude should be Double, not String
                    let latitude = coordinates["latitude"] as? Double ?? 0.0
                    let longitude = coordinates["longitude"] as? Double ?? 0.0
                    let location = CLLocation(latitude: latitude, longitude: longitude)

                    // Retrieve and set requiredProfessions
                    let requiredProfessions = data["requiredProfessions"] as? [String] ?? []

                    let jobPosting = JobPosting(
                        id: id,
                        userID: userID,
                        companyName: companyName,
                        jobDescription: jobDescription,
                        coordinates: location.coordinate,
                        postcode: postcode,
                        requiredProfessions: requiredProfessions // Set this field
                    )
                    self.jobPostings.append(jobPosting)
                }
                print("Fetched \(self.jobPostings.count) jobs")
            }
        }
    }
    func fetchJobPostings(completion: @escaping ([JobPosting]) -> Void) {
        jobPostings.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Jobs")

        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print("Error fetching job postings:", error!.localizedDescription)
                completion([])
                return
            }

            if let snapshot = snapshot {
                print("Found \(snapshot.documents.count) job documents")

                let dispatchGroup = DispatchGroup()
                var geocodedJobs: [JobPosting] = []

                for document in snapshot.documents {
                    let data = document.data()

                    let id = data["id"] as? String ?? ""
                    let userID = data["userID"] as? String ?? ""
                    let companyName = data["companyName"] as? String ?? ""
                    let jobDescription = data["jobDescription"] as? String ?? ""
                    let postcode = data["postcode"] as? String ?? ""
                    let coordinates = data["coordinates"] as? [String: Any] ?? [:]
                    let latitude = coordinates["latitude"] as? Double ?? 0.0
                    let longitude = coordinates["longitude"] as? Double ?? 0.0
                    let location = CLLocation(latitude: latitude, longitude: longitude)

                    dispatchGroup.enter()

                    self.geocodeLocation(location, forJobId: id) { result in
                        switch result {
                        case .success(let placemark):
                            let jobPosting = JobPosting(
                                id: id,
                                userID: userID,
                                companyName: companyName,
                                jobDescription: jobDescription,
                                coordinates: placemark.location?.coordinate ?? CLLocationCoordinate2D(),
                                postcode: postcode
                            )
                            geocodedJobs.append(jobPosting)
                            print("Geocoded Job - ID: \(id), Company: \(companyName), Postcode: \(String(describing: placemark.postalCode))")
                        case .failure(let error):
                            print("Geocoding error: \(error.localizedDescription)")
                        }

                        dispatchGroup.leave()
                    }
                }

                dispatchGroup.notify(queue: .main) {
                    print("Geocoding of job postings completed")

                    // Now, geocodedJobs array contains all the geocoded JobPosting instances
                    print("Fetched \(geocodedJobs.count) geocoded job postings")
                    completion(geocodedJobs)
                }
            }
        }
    }
    func geocodeLocation(_ location: CLLocation, forJobId jobId: String, completion: @escaping (Result<CLPlacemark, Error>) -> Void) {
        print("Before geocoding - Job ID: \(jobId)")
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                let geocodingError = NSError(domain: "GeocodingErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Geocoding failed: \(error.localizedDescription)"])
                completion(.failure(geocodingError))
                print("Geocoding error: \(error.localizedDescription)")
                return
            }

            guard let placemark = placemarks?.first else {
                let customError = NSError(domain: "GeocodingErrorDomain", code: 2, userInfo: [NSLocalizedDescriptionKey: "No placemark found"])
                completion(.failure(customError))
                print("Geocoding error: No placemark found")
                return
            }

            completion(.success(placemark))
            print("After geocoding - Job ID: \(jobId)")
        }
    }
        
    func fetchUserNames(for userIDs: [String], completion: @escaping ([String: String]) -> Void) {
        var userNames: [String: String] = [:]
        let dispatchGroup = DispatchGroup()

        for userID in userIDs {
            dispatchGroup.enter()
            let db = Firestore.firestore()
            let ref = db.collection("Users").document(userID)

            ref.getDocument { document, error in
                defer {
                    dispatchGroup.leave()
                }

                guard error == nil else {
                    print("Error fetching user name: \(error!.localizedDescription)")
                    return
                }

                if let document = document, document.exists {
                    let data = document.data()
                    if let name = data?["name"] as? String {
                        userNames[userID] = name
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(userNames)
        }
    }

    func geocodeAddress(_ address: String, completion: @escaping (Result<(CLLocationCoordinate2D, String), Error>) -> Void) {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let location = placemarks?.first?.location?.coordinate,
                   let postcode = placemarks?.first?.postalCode {
                    let result: (CLLocationCoordinate2D, String) = (location, postcode)
                    completion(.success(result))
                } else {
                    let customError = NSError(domain: "GeocodingErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid coordinates"])
                    completion(.failure(customError))
                }
            }
        }

    func postJob(jobPosting: JobPosting, selectedRoles: [String: String], requiredProfessions: [String]) {
            let db = Firestore.firestore()
            let ref = db.collection("Jobs").document(jobPosting.id)

            var jobData: [String: Any] = [
                "id": jobPosting.id,
                "userID": jobPosting.userID,
                "companyName": jobPosting.companyName,
                "jobDescription": jobPosting.jobDescription,
                "postcode": jobPosting.postcode,
                "requiredProfessions": requiredProfessions // Adding required professions
            ]

            // Include coordinates if available
            if let coordinates = jobPosting.coordinates {
                jobData["coordinates"] = [
                    "latitude": coordinates.latitude,
                    "longitude": coordinates.longitude
                ]
            }
            
            // Include crew members for each role
            jobData["crewMembers"] = selectedRoles

            // Save the job posting to Firestore
            ref.setData(jobData) { error in
                if let error = error {
                    print("Error posting job:", error.localizedDescription)
                } else {
                    print("Job posted successfully")
                    // Update any relevant state variables here...
                }
            }
        }

    func postJobWithGeocoding(jobPosting: JobPosting, coordinates: CLLocationCoordinate2D?, selectedRoles: [String: String]) {
        guard let coordinates = coordinates else {
            print("Invalid coordinates")
            return
        }
        
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard let placemark = placemarks?.first, let location = placemark.location?.coordinate else {
                print("Geocoding error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            var updatedJobPosting = jobPosting
            updatedJobPosting.coordinates = location
            
            // Assuming you have a way to get requiredProfessions from jobPosting or elsewhere
            let requiredProfessions = updatedJobPosting.requiredProfessions // Example

            self.postJob(jobPosting: updatedJobPosting, selectedRoles: selectedRoles, requiredProfessions: requiredProfessions)
        }
    }
    func postJobWithGeocoding(jobPosting: JobPosting, address: String, selectedRoles: [String: String]) {
        let dispatchGroup = DispatchGroup()
        var geocodedLocation: CLLocationCoordinate2D?
        var geocodedPostcode: String?

        dispatchGroup.enter()
        geocodeAddress(address) { result in
            switch result {
            case .success(let (location, postcode)):
                geocodedLocation = location
                geocodedPostcode = postcode
            case .failure(let error):
                print("Geocoding error: \(error.localizedDescription)")
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            guard let geocodedLocation = geocodedLocation, let geocodedPostcode = geocodedPostcode else {
                print("Failed to geocode the address. Job not posted.")
                return
            }

            var updatedJobPosting = jobPosting
            updatedJobPosting.coordinates = geocodedLocation
            updatedJobPosting.postcode = geocodedPostcode

            // Assuming you have a way to get requiredProfessions from jobPosting or elsewhere
            let requiredProfessions = updatedJobPosting.requiredProfessions // Example

            self.postJob(jobPosting: updatedJobPosting, selectedRoles: selectedRoles, requiredProfessions: requiredProfessions)
        }
    }
    func geocodeJobPostings(completion: @escaping () -> Void) {
        // Use a dispatch group to wait for all geocoding tasks to finish
        let dispatchGroup = DispatchGroup()

        var updatedGeocodedJobPostings: [GeocodedJobPosting] = []

        for jobPosting in jobPostings {
            // Assuming 'coordinates' is a property in your JobPosting model
            guard let coordinates = jobPosting.coordinates else {
                continue // Skip geocoding if coordinates are missing
            }

            dispatchGroup.enter()

            // Create a CLLocation instance using the coordinates
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)

            geocodeLocation(location, forJobId: jobPosting.id) { result in
                switch result {
                case .success(let placemark):
                    // Assuming you have a GeocodedJobPosting initializer
                    let geocodedJob = GeocodedJobPosting(
                        jobPosting: jobPosting,
                        id: jobPosting.id,
                        userID: jobPosting.userID,
                        companyName: jobPosting.companyName,
                        jobDescription: jobPosting.jobDescription,
                        coordinates: coordinates,
                        postcode: placemark.postalCode
                    )

                    // Append the geocoded job within the context of the dispatch group
                    updatedGeocodedJobPostings.append(geocodedJob)
                case .failure(let error):
                    print("Geocoding error for Job ID \(jobPosting.id): \(error.localizedDescription)")
                }

                dispatchGroup.leave()
            }
        }

        // Notify when all geocoding tasks are finished
        dispatchGroup.notify(queue: .main) {
            // Update the geocodedJobPostings array after all tasks are done
            self.geocodedJobPostings = updatedGeocodedJobPostings

            // Call the completion block
            completion()
        }
    }
    
}
