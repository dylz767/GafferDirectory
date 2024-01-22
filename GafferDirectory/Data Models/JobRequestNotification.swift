import SwiftUI
import CoreLocation
import Foundation

struct JobNotification: Identifiable, Hashable {
    var id: String
    var type: NotificationType // e.g., jobRequest, jobApplication
    var senderId: String // User who sent the notification
    var receiverId: String // User who receives the notification
    var jobPostingId: String // Associated job posting
    var message: String // Custom message if needed
    var status: NotificationStatus // e.g., pending, accepted, declined
    var timestamp: Date // When the notification was created
}

enum NotificationType: String {
    case jobRequest
    case jobApplication
}

enum NotificationStatus: String {
    case pending
    case accepted
    case declined
}
