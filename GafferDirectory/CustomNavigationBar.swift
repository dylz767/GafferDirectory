import SwiftUI
import Firebase

struct CustomNavigationBar: View {
    @Binding var isProfileActive: Bool
    @Binding var isListViewActive: Bool
    @Binding var isJobBoardActive: Bool
    @Binding var isSignInViewActive: Bool
    @Binding var isSignedIn: Bool  // Add this line
    @Environment(\.presentationMode) var presentationMode
    
    var listAction: () -> Void
    var jobBoardAction: () -> Void
    var profileAction: () -> Void
    var signInAction: () -> Void
    
    var body: some View {
        ZStack{}
            .navigationBarItems(trailing: Button(action: {
                do {
                    signInAction()
                    try Auth.auth().signOut()
                    presentationMode.wrappedValue.dismiss()
                    
                    // Navigate to SignInView
                    isSignInViewActive = true  // Assuming isSignInViewActive is a @State variable
                    
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }
            }) {
                Text("Logout")
            })
            .background(NavigationLink(destination: SignInView(isSignedIn: $isSignedIn), isActive: $isSignInViewActive) {
                                EmptyView()
                }
            )
        
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
