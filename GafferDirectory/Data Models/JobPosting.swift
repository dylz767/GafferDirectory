import Foundation
import CoreLocation

struct JobPosting: Identifiable, Hashable {
    var id: String
    var userID: String
    var companyName: String
    var jobDescription: String
    var coordinates: CLLocationCoordinate2D?
    var postcode: String
    var requiredProfessions: [String] = []

    // Add more properties as needed

    // Ensure the struct is Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Implement Equatable for comparison
extension JobPosting: Equatable {
    static func == (lhs: JobPosting, rhs: JobPosting) -> Bool {
        return lhs.id == rhs.id
    }
}
