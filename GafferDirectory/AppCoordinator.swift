////
////  AppCoordinator.swift
////  GafferDirectory
////
////  Created by Dylon Angol on 08/01/2024.
////
//
//import SwiftUI
//import Firebase
//
//class AppCoordinator: ObservableObject {
//    @Published var isUserAuthenticated = false
//    
//
//    func checkUserAuthentication() {
//        if Auth.auth().currentUser != nil {
//            // User is signed in
//            isUserAuthenticated = true
//        } else {
//            // User is not signed in
//            isUserAuthenticated = false
//        }
//    }
//
//    func navigateToSignInView() {
//        // Implement your navigation logic to go to SignInView
//        // For example:
//        print("Navigate to SignInView")
//        // You can use a navigation stack or a coordinator to handle navigation in your app
//        NavigationView {
//            SignInView()
//                .navigationBarBackButtonHidden(true)
//        }
//        
//    }
//}
