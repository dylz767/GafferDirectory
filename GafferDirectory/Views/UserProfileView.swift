import SwiftUI

struct UserProfileView: View {
    let user: Account
    @State private var isListViewActive = false
    @State private var isProfileActive = false
    @State private var isJobBoardViewActive = false
    @State private var isSignInViewActive = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Name: \(user.name)")
                    .padding(.bottom, 10)

                Text("Profession: \(user.profession)")
                    .padding(.bottom, 10)

                // Add more details as needed

                Spacer()
//start of custom nav bar code
                CustomNavigationBar(
                    isProfileActive: $isProfileActive,
                    isListViewActive: $isListViewActive,
                    isJobBoardActive: $isJobBoardViewActive,
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
                    }
                )
                .padding(.bottom, 8)
                .navigationBarTitle("\(user.name)'s Profile", displayMode: .inline)
                .navigationBarItems(leading: EmptyView())
            }
            // Ensure JobBoardView is within NavigationView
            .navigationBarBackButtonHidden(true)
            .background(
                NavigationLink(destination: ProfileView(), isActive: $isProfileActive) {
                    if isSignInViewActive == false
                    {
                        EmptyView()
                    }
                    else
                    if isSignInViewActive == true{
                        SignInView()
                    }
                }
                .hidden()
            )
            .background(
                NavigationLink(destination: ListView(), isActive: $isListViewActive) {
                    if isSignInViewActive == false
                    {
                        EmptyView()
                    }
                    else
                    if isSignInViewActive == true{
                        SignInView()
                    }
                }
                .hidden()
            )
            .background(
                NavigationLink(destination: JobBoardView(), isActive: $isJobBoardViewActive) {
                    if isSignInViewActive == false
                    {
                        EmptyView()
                    }
                    else
                    if isSignInViewActive == true{
                        SignInView()
                    }
                }
                .hidden()
            )
            //end of custom nav bar code
            }
            .navigationBarBackButtonHidden(true)
            }
        }
