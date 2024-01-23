import SwiftUI
import Foundation

struct MainView: View {
    @State private var isSignedIn = false
    @StateObject var dataManager = DataManager()
    @Environment(\.presentationMode) var presentationMode
    @StateObject var currentJobVM = CurrentJobViewModel()

    var body: some View {
        if isSignedIn {
            ListView() // Make sure ListView is correctly defined
                .environmentObject(dataManager)
                .environmentObject(currentJobVM)
        } else {
            SignInView(isSignedIn: $isSignedIn)
        }
    }
}
