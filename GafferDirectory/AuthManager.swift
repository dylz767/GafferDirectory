//import SwiftUI
//import Firebase
//
//class AuthManager: ObservableObject {
//    @Published var isUserAuthenticated = false
//    var coordinator: AppCoordinator?
//
//    init(coordinator: AppCoordinator? = nil) {
//        self.coordinator = coordinator
//        // Call this function to check if the user is authenticated
//        checkUserAuthentication()
//    }
//
//    func signIn() {
//        // Implement your sign-in logic here
//        // Set isUserAuthenticated to true upon successful sign-in
//        // For demonstration purposes, I'm setting it to true directly
//        isUserAuthenticated = true
//    }
//
//    func signOut() {
//        // Implement your sign-out logic here
//        // Set isUserAuthenticated to false upon successful sign-out
//        // For demonstration purposes, I'm setting it to false directly
//        isUserAuthenticated = false
//    }
//
//    func checkUserAuthentication() {
//        if Auth.auth().currentUser != nil {
//            // User is signed in
//            isUserAuthenticated = true
//        } else {
//            // User is not signed in, navigate to SignInView
//            isUserAuthenticated = false
//            navigateToSignInView()
//        }
//    }
//
//    private func navigateToSignInView() {
//        // Implement your navigation logic to go to SignInView
//        // For demonstration purposes, I'm printing a message
//        print("Navigate to SignInView")
//        coordinator?.navigateToSignInView()
//        // You can use a navigation stack or a coordinator to handle navigation in your app
//    }
//}
