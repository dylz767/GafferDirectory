import Combine
import SwiftUI
import Firebase

class ConsoleObserver: ObservableObject {
    static let shared = ConsoleObserver()

    private var cancellables: Set<AnyCancellable> = []

    init() {
        observeSignInViewActive()
    }

    private func observeSignInViewActive() {
        // Replace "YourApp" with the actual module name of your app
        NotificationCenter.default.publisher(for: Notification.Name("YourApp.ProfileView.SignInViewActive"))
            .sink { _ in
                // Perform actions when isSignInViewActive becomes true
                print("isSignInViewActive is true. Closing all windows and opening SignInView.")
            }
            .store(in: &cancellables)
    }
}
