import SwiftUI
import Firebase

@main
struct GafferDirectoryApp: App {
    // Register app delegate for Firebase setup
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var dataManager = DataManager()
    
    init (){
        FirebaseApp.configure()
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            //    NavigationView {
            
            SignUpView()
                .environmentObject(dataManager)
                .navigationBarBackButtonHidden(true)
            //  .onAppear {
            //            FirebaseApp.configure()
            //   print("Configured Firebase!")
            //            NavigationView {
            //                            // Your initial view here
            //                        }
            //                        .navigationBarBackButtonHidden(true) // Hide back button globally
            //                    }
//            NavigationView {
//                            // Your initial view here
//                        }
//                        .navigationBarBackButtonHidden(true)
            
            //     }
        }
        // }
        
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication,
                         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            
            return true
        }
    }
}
