//import Firebase
//import FirebaseDatabase
//import CoreLocation
//
//class FirebaseService {
//    static let shared = FirebaseService()
//
//    private let database = Database.database().reference()
//
//    func addUser(_ user: User) {
//        let userReference = database.child("users").childByAutoId()
//        userReference.setValue(user.toDictionary())
//    }
//
//    func fetchUsers(completion: @escaping ([User]) -> Void) {
//        let usersReference = database.child("users")
//        usersReference.observeSingleEvent(of: .value) { (snapshot) in
//            guard let data = snapshot.value as? [String: [String: Any]] else {
//                completion([])
//                return
//            }
//            let users = data.compactMap { User(fromDictionary: $0.value) }
//            completion(users)
//        }
//    }
//    }
