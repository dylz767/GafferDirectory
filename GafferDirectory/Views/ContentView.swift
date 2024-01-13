import SwiftUI

//struct ContentView: View {
//
//    @Binding var gaffers: [User]
//
//    var body: some View {
//        Section{
//            NavigationView {
//                
//                VStack {
//                    Spacer(minLength:50)
//                    Text("The Gaffer Directory")
//                        .font(.title)
//                        .fontWeight(.bold)
//                        Spacer(minLength: 30)
//                    Text("Join The Roster")
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                    Spacer(minLength: 350)
//                    // Pass the binding to the UserSignUpView
//                    Spacer()
//                        .font(.headline)
//                        .fontWeight(.semibold)
//                    NavigationLink(destination: UserSignUpView(gaffers: $gaffers)) {
//                        VStack{
//                            Text("Sign Up")
//                                .font(.title)
//                                .fontWeight(.bold)
//                                .foregroundColor(.white)
//                                .padding()
//                                .ignoresSafeArea()
//                                .background(.blue)
//                                .cornerRadius(10)
//                        }
//                    }
//                    
//                    .padding()
//                 Spacer(minLength: 150)
//                    // Display the GafferList with the array of gaffers
//                    //   GafferList(gaffers: gaffers)
//                }
//                //   .navigationBarTitle("Gaffer Directory")
//            }
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(gaffers: .constant([]))  // Placeholder binding to an empty array
//    }
//}
