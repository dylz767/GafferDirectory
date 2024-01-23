//
//  NotificationListView.swift
//  GafferDirectory
//
//  Created by Dylon Angol on 23/01/2024.
//

import SwiftUI

struct NotificationListView: View {
    @ObservedObject var dataManager: DataManager

    var body: some View {
        List(dataManager.jobRequests) { jobRequest in
            // Display each job request in the list
            // Customize this part according to your UI needs
            Text(jobRequest.jobDescription)
        }
        .onAppear {
            // Fetch job requests for the current user when the view appears
            dataManager.fetchJobRequestsForCurrentUser()
        }
    }
}
