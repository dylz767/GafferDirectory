import SwiftUI
import Firebase

struct ListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedUser: Account?
    @State private var isProfileActive = false
    @State private var isListViewActive = false
    @State private var isJobBoardViewActive = false
    @State private var isSignInViewActive = false
    @State private var favorites: Set<String> = []
    @State private var isSignedIn = true

    var body: some View {
        NavigationView {
            VStack {
                List(dataManager.accounts, id: \.id) { account in
                    HStack {
                        Button(action: {
                            self.selectedUser = account
                        }) {
                            VStack(alignment: .leading) {
                                Text("Name: \(account.name)")
                                Text("Profession: \(account.profession)")
                            }
                        }
                        
                        Spacer()
                        
                        FavoriteButton(isFavorite: favorites.contains(account.id)) {
                            if favorites.contains(account.id) {
                                dataManager.removeFavorite(for: dataManager.currentUserId, favoriteId: account.id)
                                favorites.remove(account.id)
                            } else {
                                dataManager.addFavorite(for: dataManager.currentUserId, favoriteId: account.id)
                                favorites.insert(account.id)
                            }
                        }
                    }
                }
                .onAppear {
                                   fetchData() // Fetch data when the view appears
                               }
                .onAppear {
                    dataManager.fetchCurrentUserFavorites { fetchedFavorites in
                        self.favorites = fetchedFavorites
                    }}
                
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
            
            .navigationBarTitle("Users", displayMode: .inline)
            .navigationBarItems(leading: NavigationLink(destination: ChatView()) {
                Text("robot")
            })
        
        .fullScreenCover(item: $selectedUser) { user in
            UserProfileView(user: user)
        }
        
            .background(
                NavigationLink(destination: ProfileView(), isActive: $isProfileActive) {
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
}


struct FavoriteButton: View {
    var isFavorite: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundColor(isFavorite ? .yellow : .gray)
        }
    }
}
