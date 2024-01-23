import SwiftUI
import CoreLocation
import Foundation
import Firebase

struct JobRequestNotification: Identifiable, Hashable {
    var id: String
    var jobId: String
    var senderId: String // Job creator's user ID
    var receiverId: String // Professional's user ID
    var companyName: String
    var jobDescription: String
    var status: NotificationStatus = .pending // Initial status
    var timestamp: Date
}

enum NotificationStatus: String {
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
}


