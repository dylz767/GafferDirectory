import Firebase

extension JobRequestsViewModel {
    func updateJobRequestStatus(requestId: String, newStatus: NotificationStatus) {
            let requestRef = db.collection("jobRequests").document(requestId)
            requestRef.updateData([
                "status": newStatus.rawValue
            ]) { error in
                if let error = error {
                    print("Error updating status: \(error.localizedDescription)")
                } else {
                    print("Status updated to \(newStatus.rawValue)")
                    // Optionally refresh the job requests list here
                    self.fetchJobRequests(userId: Auth.auth().currentUser?.uid ?? "", status: "Pending") { result in
                        switch result {
                        case .success(let jobRequests):
                            // Handle the retrieved job requests here
                            self.jobRequests = jobRequests
                        case .failure(let error):
                            print("Error fetching job requests: \(error.localizedDescription)")
                            // Handle the error appropriately
                        }
                    }
                }
            }
        }
}

class JobRequestsViewModel: ObservableObject {
    @Published var jobRequests: [JobRequest] = []

    private var db = Firestore.firestore()

    func fetchJobRequests(userId: String, status: String, completion: @escaping (Result<[JobRequest], Error>) -> Void) {
        db.collection("jobRequests")
            .whereField("userId", isEqualTo: userId)
            .whereField("status", isEqualTo: status)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    // Handle the error and pass it to the completion handler
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents else {
                    // Handle the case where there are no documents
                    completion(.success([])) // Return an empty array
                    return
                }

                // Parse the documents and create an array of JobRequest objects
                let jobRequests = documents.compactMap { JobRequest(id: $0.documentID, dictionary: $0.data()) }

                // Pass the jobRequests array to the completion handler
                completion(.success(jobRequests))
            }
    }
}
