import SwiftUI
import Firebase

struct ProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var userAccounts: [Account] = []
    @State private var userName: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var isListViewActive = false
    @State private var isJobBoardViewActive = false
    @State private var isProfileActive = true
    @State private var isSignInViewActive = false
    @State private var isJobPostingViewActive = false
    @State private var isSignInSuccess = true

    var body: some View {
        NavigationView {
            VStack {
                if userAccounts.isEmpty {
                    Text("No users found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(userAccounts, id: \.id) { account in
                        VStack(alignment: .leading) {
                            Text("Name: \(account.name)")
                                .font(.headline)
                                .padding(.bottom, 5)
                            Text("Profession: \(account.profession)")
                                .font(.subheadline)
                        }
                        .multilineTextAlignment(.leading)
                    }
                    .navigationBarBackButtonHidden(true)
                }
                NavigationLink (destination: JobPostingView(), isActive: $isJobPostingViewActive,
                 label: {
                               Text("Post a Job")
                                   .padding()
                                   .background(Color.blue)
                                   .foregroundColor(.white)
                                   .cornerRadius(10)
                           }
                                )
                           .padding(.bottom, 16)

                Spacer()

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
            }
            .navigationBarTitle("Profile View", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(trailing: Button(action: {
                do {
                    try Auth.auth().signOut()
                    presentationMode.wrappedValue.dismiss()

                    // Navigate to SignInView
                    isSignInViewActive = true  // Assuming isSignInViewActive is a @State variable

                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }
            }) {
                Text("Logout")
            })
            .background(
                NavigationLink(destination: SignInView(), isActive: $isSignInViewActive) {
                    SignInView()

                }
            )
            .onAppear {
                fetchUserData()
                fetchUserAccounts()
            }
//            .background(
//                NavigationLink(destination: ProfileView(), isActive: $isProfileActive) {
//                    if isSignInViewActive == false
//                    {
//                        EmptyView()
//                    }
//                    else
//                    if isSignInViewActive == true{
//                        SignInView()
//                    }
//                }
//                .hidden()
//            )
            .background(
                NavigationLink(destination: ListView(), isActive: $isListViewActive) {
//                    if isSignInViewActive == false
//                    {
                        EmptyView()
//                    }
//                    else
//                    if isSignInViewActive == true{
//                        SignInView()
//                    }
                }
                .hidden()
            )
            .background(
                NavigationLink(destination: JobBoardView(), isActive: $isJobBoardViewActive) {
//                    if isSignInViewActive == false
//                    {
//                        EmptyView()
//                    }
//                    else
//                    if isSignInViewActive == true{
                        SignInView()
//                    }
                }
                .hidden()
            )
        }
        .navigationBarBackButtonHidden(true)
    }

    private func fetchUserData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }

        dataManager.fetchUserData(userId: userID) { user in
            if let user = user {
                userName = user.name
            }
        }
    }

    private func fetchUserAccounts() {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }

        // Assuming your DataManager has a method to fetch user accounts
        dataManager.fetchUsersByUserId(userId: userID) { accounts in
            userAccounts = accounts
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(DataManager())
    }
}
