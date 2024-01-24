import SwiftUI
import Firebase

struct NotificationListView: View {
    @ObservedObject var dataManager: DataManager

    var body: some View {
        NavigationView {
            List(dataManager.jobRequests) { jobRequest in
                VStack(alignment: .leading) {
                    Text(jobRequest.companyName)
                        .font(.headline)
                        .padding(.bottom, 2)
                    Text(jobRequest.jobDescription)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        print("Decline tapped")
                        dataManager.updateJobRequestStatus(requestId: jobRequest.id, newStatus: .declined)
                    } label: {
                        Label("Decline", systemImage: "xmark.circle")
                    }
                    .tint(.red)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        print("Accept tapped")
                        dataManager.updateJobRequestStatus(requestId: jobRequest.id, newStatus: .accepted)
                    } label: {
                        Label("Accept", systemImage: "checkmark.circle")
                    }
                    .tint(.green)
                }
            }
            .navigationBarTitle("Notifications", displayMode: .inline)
            .onAppear {
                dataManager.fetchJobRequestsForCurrentUser()
            }
        }
    }
}
