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
    @State private var isNavigatingToProfile = false
    @State private var selectedProfessionFilter: String?
    
    var filteredAccounts: [Account] {
        if let filter = selectedProfessionFilter {
            return dataManager.accounts.filter { $0.professions.contains(filter) }
        }
        return dataManager.accounts
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(filteredAccounts, id: \.id) { account in
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
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedUser = account
                                isNavigatingToProfile = true
                            }
                        }
                        
                        Button(action: {
                            toggleFavorite(for: account.id)
                        }) {
                            Image(systemName: favorites.contains(account.id) ? "star.fill" : "star")
                                .foregroundColor(favorites.contains(account.id) ? .yellow : .gray)
                        }
                        .padding(.trailing, 16)
                    }
                }
                .onAppear {
                    fetchData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        print("First few account professions:")
                        for account in dataManager.accounts.prefix(3) {
                            print("\(account.name): \(account.professions)")
                        }
                    }

                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu("Profession: None") {
                            ForEach(["DP", "Gaffer", "Spark", "Producer", "Art Department", "HMUA", "Editor", "Colour Grade", "Runner", "Director", "Photographer", "Photographer Assistant"], id: \.self) { profession in
                                Button(profession) {
                                    selectedProfessionFilter = profession
                                }
                            }
                            Button("Clear Filter") {
                                selectedProfessionFilter = nil
                            }
                        }
                    }
                }
                
                Spacer()
                CustomNavigationBar(
                    isProfileActive: $isProfileActive,
                    isListViewActive: $isListViewActive,
                    isJobBoardActive: $isJobBoardViewActive,
                    isSignInViewActive: $isSignInViewActive,
                    isSignedIn: $isSignedIn,
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
            .navigationBarTitle("Users", displayMode: .inline)
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
        .onChange(of: selectedProfessionFilter) { _ in
            fetchData()
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
        if favorites.contains(id) {
            dataManager.removeFavorite(favoriteId: id)
            favorites.remove(id)
        } else {
            dataManager.addFavorite(favoriteId: id)
            favorites.insert(id)
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
