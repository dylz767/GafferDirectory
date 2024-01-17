import SwiftUI
import Firebase
import CoreLocation

struct JobBoardView: View {
    @EnvironmentObject private var dataManager: DataManager
    @State private var selectedJob: JobPosting?
    @State private var isProfileActive = false
    @State private var isListViewActive = false
    @State private var isJobBoardViewActive = false
    @State private var isSignInViewActive = false
    @State private var isSignedIn = true


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
                .navigationBarItems(leading: NavigationLink(destination: JobPostingView()) {
                    Text("Post a Job")
                }
                )
//                .navigationBarBackButtonHidden(true)
                .navigationBarBackButtonHidden(true)
                
                Spacer()
                
                CustomNavigationBar(
                                isProfileActive: $isProfileActive,
                                isListViewActive: $isListViewActive,
                                isJobBoardActive: $isJobBoardViewActive,
                                isSignInViewActive: $isSignInViewActive,
                                isSignedIn: $isSignedIn, // Pass this binding
                                listAction: {
                                    // Handle User List action
                                    isListViewActive = true
                                },
                                jobBoardAction: {
                                    // Handle Jobs Board action
                                    isJobBoardViewActive = true
                                },
                                profileAction: {
                                    // Handle Profile View action
                                    isProfileActive = true
                                },
                                signInAction: {
                                    // Handle Sign In action
                                    isSignInViewActive = true
                                }
                            )
                .padding(.bottom, 8)
                }

            
            .fullScreenCover(item: $selectedJob) { job in
                JobDetailView(jobPosting: job)
            }
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
                    .background(
                        NavigationLink(destination: JobBoardView(), isActive: $isJobBoardViewActive) {
                            EmptyView()
                        }
                        .hidden()
                    )
                    .background(
                        NavigationLink(destination: SignInView(isSignedIn: $isSignedIn), isActive: $isSignInViewActive) {
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
