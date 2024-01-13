import SwiftUI
import Firebase
import CoreLocation

struct JobBoardView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var selectedJob: JobPosting?
    @State private var isProfileActive = false
    @State private var isListViewActive = false
    @State private var isJobBoardViewActive = false
    @State private var isSignInSuccess = true
    

    var body: some View {
        NavigationView {
            VStack {
                List(dataManager.jobPostings, id: \.id) { jobPosting in
                    NavigationLink(destination: JobDetailView(jobPosting: jobPosting)) {
                        VStack(alignment: .leading) {
                            Text("Job Title: \(jobPosting.companyName)")
                                .font(.headline)
                                .padding(.bottom, 5)
                            Text("Description: \(jobPosting.jobDescription)")
                                .font(.subheadline)
                                .padding(.bottom, 5)
                            Text("postcode: \(jobPosting.postcode)")
                                .font(.subheadline)
                                .padding(.bottom, 5)
                        }
                        .multilineTextAlignment(.leading)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .navigationBarTitle("Job Board", displayMode: .inline)
                .navigationBarItems(leading: EmptyView())
                .navigationBarBackButtonHidden(true)

                Spacer()

                CustomNavigationBar(
                    isProfileActive: $isProfileActive,
                    isListViewActive: $isListViewActive,
                    isJobBoardActive: $isJobBoardViewActive,
                    listAction: {
                        isListViewActive = true
                    },
                    jobBoardAction: {
                        isJobBoardViewActive = true
                    },
                    profileAction: {
                        isProfileActive = true
                    }
                )
                .padding(.bottom, 8)
            }
            .fullScreenCover(item: $selectedJob) { job in
                JobDetailView(jobPosting: job)
            }
            .navigationBarBackButtonHidden(true)
            .background(
                NavigationLink(destination: ProfileView(), isActive: $isProfileActive) {
                    EmptyView()
                }
                .hidden()
            )
            .background(
                NavigationLink(destination: ListView(), isActive: $isListViewActive) {
                    EmptyView()
                }
                .hidden()
            )
        }
        .navigationBarBackButtonHidden(true)
        .environmentObject(dataManager)
        .onAppear {
            fetchJobPostings()
        }
    }

    private func fetchJobPostings() {
        dataManager.fetchJobs()
    }
}
