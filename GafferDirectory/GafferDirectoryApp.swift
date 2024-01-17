// GafferDirectoryApp.swift
import SwiftUI
import Firebase

@main
struct GafferDirectoryApp: App {
    @StateObject var dataManager = DataManager()

    init() {
        FirebaseApp.configure()

    }

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
