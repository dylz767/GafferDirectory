//import SwiftUI
//
//struct MyView: View {
//    @EnvironmentObject var dataManager: DataManager
//
//    var body: some View {
//        // Your view content
//        .onAppear {
//            dataManager.fetchCurrentUserFavorites { favorites in
//                dataManager.currentUserFavorites = favorites
//            }
//        }
//    }
//
//    func isUserFavorite(userId: String) -> Bool {
//        dataManager.currentUserFavorites.contains(userId)
//    }
//}
