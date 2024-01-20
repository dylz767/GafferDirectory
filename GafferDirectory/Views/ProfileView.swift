import SwiftUI
import Firebase

struct ProfileView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var currentUser: Account?
    @State private var favoriteAccounts: [Account] = []
    @State private var isListViewActive = false
    @State private var isJobBoardViewActive = false
    @State private var isProfileActive = false
    @State private var isSignInViewActive = false
    @State private var isSignedIn = true
    @State private var selectedUser: Account?
    @State private var isNavigatingToProfile = false
    @State private var favorites: Set<String> = []
 
    var body: some View {
        NavigationView {
            VStack {
                if let currentUser = currentUser {
                    Text("Name: \(currentUser.name)")
                        .font(.headline)
                    Text("Profession: \(currentUser.professions.joined(separator: ", "))")
                        .font(.subheadline)
                } else {
                    Text("No profile data found.")
                        .foregroundColor(.gray)
                }

                if favoriteAccounts.isEmpty {
                    Text("No favorites found.")
                        .foregroundColor(.gray)
                } else {
                    List(favoriteAccounts, id: \.id) { account in
                        HStack {
                            ZStack {
                                VStack(alignment: .leading) {
                                    Text("Name: \(account.name)")
                                        .font(.headline)
                                        .padding(.bottom, 5)
                                    Text("Profession: \(account.professions.joined(separator: ", "))")
                                        .font(.subheadline)
                                        .padding(.bottom, 5)
                                }
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle()) // Makes the entire VStack tappable
                                .onTapGesture {
                                    selectedUser = account
                                    isNavigatingToProfile = true
                                }
                            }
                            
                            Button(action: {
                                toggleFavorite(for: account.id)
                            }) {
                                Image(systemName: favorites.contains(account.id) ? "star" : "star.fill" )
                                    .foregroundColor(favorites.contains(account.id) ? .gray : .yellow )
                            }
                            .padding(.trailing, 16)
                        }
                    }
                    .onAppear {
                        // Refresh the favorites when the view appears
                        dataManager.fetchCurrentUserFavorites()
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
                        isListViewActive = true
                    },
                    jobBoardAction: {
                        isJobBoardViewActive = true
                    },
                    profileAction: {
                        isProfileActive = true
                    },
                    signInAction: {
                        isSignInViewActive = true
                    }
                )
                .padding(.bottom, 8)
            }
            .navigationBarTitle("Profile View", displayMode: .inline)
            .navigationBarItems(leading: NavigationLink(destination: ChatView()) {
                Text("robot")
            })
            .navigationBarBackButtonHidden(true)
            .onAppear {
                setupView()
            }
            .fullScreenCover(item: $selectedUser) { user in
                UserProfileView(user: user)
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
        }
        .navigationBarBackButtonHidden(true)
        
    }
    
    private func fetchData() {
        dataManager.fetchUsers()
        dataManager.fetchCurrentUserFavorites { fetchedFavorites in
            self.favorites = fetchedFavorites
        }
    }
    private func toggleFavorite(for id: String) {

        dataManager.removeFavorite(favoriteId: id) {
            // This will be called after the favorite is removed
            // Update the local state to refresh the view
            fetchFavoriteAccounts()
            DispatchQueue.main.async {
                self.favorites.remove(id)
            }
        }
  
    }


    private func setupView() {
        fetchCurrentUserProfile()
        fetchFavoriteAccounts()
    }

    private func fetchCurrentUserProfile() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        dataManager.fetchUserData(userId: userID) { account in
            self.currentUser = account
        }
    }

    private func fetchFavoriteAccounts() {
        guard let id = Auth.auth().currentUser?.uid else { return }

        dataManager.fetchCurrentUserFavorites { favoritesSet in
            self.favoriteAccounts = dataManager.accounts.filter { favoritesSet.contains($0.id) }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(DataManager())
    }
}
