import SwiftUI

struct UserProfileView: View {
    let user: Account
    @State private var isListViewActive = false
    @State private var isProfileActive = false
    @State private var isJobBoardViewActive = false
    @State private var isSignInViewActive = false
    @State private var isSignedIn = true
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Text("Name: \(user.name)")
                    .padding(.bottom, 10)

                Text("Profession: \(user.professions.joined(separator: ", "))")
                    .padding(.bottom, 10)

                // Add more details as needed

                Spacer()
//start of custom nav bar code
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
                .navigationBarTitle("\(user.name)'s Profile", displayMode: .inline)
                .navigationBarItems(leading: EmptyView())
            }
            // Ensure JobBoardView is within NavigationView
            .navigationBarItems(leading: Button("Back") {
                presentationMode.wrappedValue.dismiss()
            })
            .onDisappear {
    //            selectedJob = nil
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
            //end of custom nav bar code
            }
            .navigationBarBackButtonHidden(true)
            }
        }
