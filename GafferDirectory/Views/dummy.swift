//import SwiftUI
//import Firebase
//
//struct JoobsBoardView: View {
//    @EnvironmentObject var dataManager: DataManager
//    @State private var selectedJob: JobPosting?
//    @State private var isProfileActive = false
//    @State private var isListViewActive = false
//    @State private var isJobBoardViewActive = false
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                List(dataManager.jobPostings, id: \.id) { jobPosting in
//                    VStack(alignment: .leading) {
//                        Text("Company: \(jobPosting.companyName)")
//                            .font(.headline)
//                            .padding(.bottom, 5)
//                        Text("Description: \(jobPosting.jobDescription)")
//                            .font(.subheadline)
//                            .padding(.bottom, 5)
//                        if let postcode = jobPosting.postcode {
//                            Text("Location: \(postcode)")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        
//                    }
//                        
//                    }
//                    multilineTextAlignment(.leading)
//                    .buttonStyle(PlainButtonStyle())
//                }
//                .onAppear {
//                    dataManager.fetchJobPostings(completion: <#T##([JobPosting]) -> Void#>)
//                }
//                .navigationTitle("Jobs")
//                .navigationBarItems(leading: EmptyView())
//                .navigationBarBackButtonHidden(true)
//
//                Spacer()
//
//                CustomNavigationBar(
//                    isProfileActive: $isProfileActive,
//                    isListViewActive: $isListViewActive,
//                    isJobBoardActive: $isJobBoardViewActive,
//                    listAction: {
//                        // Handle User List action
//                        isListViewActive = true
//                    },
//                    jobBoardAction: {
//                        // Handle Jobs Board action
//                        isJobBoardViewActive = true
//                    },
//                    profileAction: {
//                        // Handle Profile View action
//                        isProfileActive = true
//                    }
//                )
//                .padding(.bottom, 8)
//            }
//            .navigationBarBackButtonHidden(true)
//            .background(
//                NavigationLink(destination: ProfileView(), isActive: $isProfileActive) {
//                    EmptyView()
//                }
//                .hidden()
//            )
//            .background(
//                NavigationLink(destination: JobBoardView(), isActive: $isJobBoardViewActive) {
//                    EmptyView()
//                }
//                .hidden()
//            )
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//}
//
