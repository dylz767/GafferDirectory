import SwiftUI
import Firebase

struct ProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var userAccounts: [Account] = []
    @State private var currentUser: Account?
    @State private var userName: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var isListViewActive = false
    @State private var isJobBoardViewActive = false
    @State private var isProfileActive = true
    @State private var isSignInViewActive = false
    @State private var isJobPostingViewActive = false
    @State private var isSignInSuccess = true
    @State private var isSignedIn = true
    var favoriteAccounts: [Account] {
        dataManager.accounts.filter { dataManager.currentUserFavorites.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let currentUser = currentUser {
                    Text("Name: \(currentUser.name)")
                        .font(.headline)
                    Text("Profession: \(currentUser.profession)")
                        .font(.subheadline)
                    // ... display other details of currentUser
                } else {
                    Text("No profile data found.")
                        .foregroundColor(.gray)
                }
                //display favourites
                if favoriteAccounts.isEmpty {
                    Text("No favorites found.")
                        .foregroundColor(.gray)
                } else {
                    List(favoriteAccounts, id: \.id) { account in
                        VStack(alignment: .leading) {
                            Text("Name: \(account.name)")
                                .font(.headline)
                            Text("Profession: \(account.profession)")
                                .font(.subheadline)
                        }
                    }
                }
                
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
            .navigationBarTitle("Profile View", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            
            .onAppear {
                fetchUserData()
                fetchUserAccounts()
            }
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
            .onAppear {
                fetchCurrentUserProfile()
                fetchUserAccounts()
                dataManager.fetchCurrentUserFavorites()
            }
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

        private func fetchCurrentUserProfile() {
            guard let userID = Auth.auth().currentUser?.uid else {
                return
            }

            dataManager.fetchUserData(userId: userID) { account in
                self.currentUser = account
            }
        }

        private func fetchUserAccounts() {
            guard let userID = Auth.auth().currentUser?.uid else {
                return
            }

            dataManager.fetchUsersByUserId(userId: userID) { accounts in
                self.userAccounts = accounts
            }
        }

        // ... rest of the ProfileView code
    }

    struct ProfileView_Previews: PreviewProvider {
        static var previews: some View {
            ProfileView()
                .environmentObject(DataManager())
        }
    }
