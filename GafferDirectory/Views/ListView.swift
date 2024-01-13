import SwiftUI
import Firebase

struct ListView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedUser: Account?
    @State private var isProfileActive = false
    @State private var isListViewActive = true
    @State private var isJobBoardViewActive = false
    @State private var isSignInSuccess = true
    @State private var isSignInViewActive = false

    var body: some View {
        NavigationView {
            VStack {
                List(dataManager.accounts, id: \.id) { account in
                    Button(action: {
                        selectedUser = account
                    }) {
                        VStack(alignment: .leading) {
                            Text("Name: \(account.name)")
                                .font(.headline)
                                .padding(.bottom, 5)
                            Text("Profession: \(account.profession)")
                                .font(.subheadline)
                                .padding(.bottom, 5)
                        }
                        .multilineTextAlignment(.leading)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .onAppear {
                    if dataManager.accounts.isEmpty {
                        dataManager.fetchUsers()
                    } else {
                        print("fetchUsers function is not implemented")
                    }
                }
                .navigationBarTitle("Users", displayMode: .inline)
                .navigationBarItems(leading: EmptyView())
                .navigationBarBackButtonHidden(true)

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
            .fullScreenCover(item: $selectedUser) { user in
                UserProfileView(user: user)
            }
            .navigationBarBackButtonHidden(true)
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
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
            .environmentObject(DataManager())
    }
}
