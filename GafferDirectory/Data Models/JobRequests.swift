import FirebaseFirestore

struct JobRequest: Identifiable, Hashable, Decodable { 
    var id: String
    var userId: String
    var jobId: String
    var senderId: String
    var companyName: String
    var jobDescription: String
    var status: String
    var timestamp: Date

    
    
    init(id: String, dictionary: [String: Any]) {
        self.id = id
        self.userId = dictionary["userId"] as? String ?? ""
        self.jobId = dictionary["jobId"] as? String ?? ""
        self.senderId = dictionary["senderId"] as? String ?? ""
        self.companyName = dictionary["companyName"] as? String ?? ""
        self.jobDescription = dictionary["jobDescription"] as? String ?? ""
        self.status = dictionary["status"] as? String ?? ""
        self.timestamp = (dictionary["timestamp"] as? Timestamp)?.dateValue() ?? Date()
    }
     
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension JobRequest: Equatable {
    static func == (lhs: JobRequest, rhs: JobRequest) -> Bool {
        return lhs.id == rhs.id
    }
}
