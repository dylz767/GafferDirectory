import SwiftUI

struct CustomNavigationBar: View {
    @Binding var isProfileActive: Bool
    @Binding var isListViewActive: Bool
    @Binding var isJobBoardActive: Bool
    @State private var isSignInSuccess = true

    var listAction: () -> Void
    var jobBoardAction: () -> Void
    var profileAction: () -> Void

    var body: some View {
        HStack {
            
            Spacer(minLength: 25)
            Button(action: {
                profileAction()
            }) {
                Image(systemName: "person.crop.circle.fill")
            }

            Spacer(minLength: 100)

            Button(action: {
                listAction()
            }) {
                Image(systemName: "person.3")
            }

            Spacer(minLength: 100)

            Button(action: {
                jobBoardAction()
            }) {
                Image(systemName: "briefcase.fill")
            }
            Spacer(minLength: 25)
        }
        .padding()
        .background(Color.gray)
        .foregroundColor(.white)
        .font(.headline)
    }
}
