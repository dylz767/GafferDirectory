import SwiftUI
import Foundation

struct MainView: View {
    @State private var isSignedIn = false
    @StateObject var dataManager = DataManager()

    var body: some View {
        if isSignedIn {
            ListView() // Make sure ListView is correctly defined
                .environmentObject(dataManager)
        } else {
            SignInView(isSignedIn: $isSignedIn)
        }
    }
}
