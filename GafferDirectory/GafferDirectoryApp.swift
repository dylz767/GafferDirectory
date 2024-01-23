// GafferDirectoryApp.swift
import SwiftUI
import Firebase

@main
struct GafferDirectoryApp: App {
    @StateObject var dataManager = DataManager()
//    @StateObject var currentJobVM = CurrentJobViewModel()
    
    init() {
        FirebaseApp.configure()

    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(dataManager)
//                .environmentObject(currentJobVM) 
        }
    }
}
