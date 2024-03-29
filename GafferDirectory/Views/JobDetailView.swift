import SwiftUI
import CoreLocation
import MapKit
import Firebase

struct JobDetailView: View {
    @EnvironmentObject var currentJobVM: CurrentJobViewModel
    let jobPosting: JobPosting
    @EnvironmentObject var dataManager: DataManager
    @State private var isUsersViewPresented: Bool = false
    @State private var selectedProfession: String?
    @State private var filteredUsers: [Account] = []
    @Environment(\.presentationMode) var presentationMode
    @State private var showUsersListSheet = false
    @State private var isMapPresented = false
    @State private var address: String?
    @State private var selectedJob: JobPosting?
    @State private var isProfileActive = false
    @State private var isListViewActive = false
    @State private var isJobBoardViewActive = false
    @State private var isSignInViewActive = false
    @State private var isSignedIn = true


    var body: some View {
        NavigationView {
            VStack{
                ScrollView {
                    VStack {
                        Text("Company: \(jobPosting.companyName)")
                            .font(.headline)
                            .padding(.bottom, 5)
                        Text("Description: \(jobPosting.jobDescription)")
                            .font(.subheadline)
                            .padding(.bottom, 5)
                        
                        if jobPosting.requiredProfessions.isEmpty {
                            Text("No required positions found.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(jobPosting.requiredProfessions, id: \.self) { profession in
                                HStack {
                                    Text(profession)
                                    Spacer()
                                    if jobPosting.userID == dataManager.currentUserId {
                                        Button("Find \(profession)") {
                                            selectedProfession = profession
                                            fetchUsersForProfession(profession)
                                         
                                            print("Current job set to: \(jobPosting.companyName)")
                                        }
                                    }
                                    else  {
                                        Button("\(profession) Needed") {
                                            
                                            //notify the creator of the job you're interested
                                            //userID of job should be equal to a users ID
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                        
                        Text("Job Location:")
                            .font(.body)
                            .padding(.bottom, 5)
                        if let coordinates = jobPosting.coordinates {
                            Text("Location: \(coordinates.latitude), \(coordinates.longitude)")
                                .font(.subheadline)
                                .padding(.bottom, 5)
                            Text("Address: \(address ?? "Unknown")")
                                .font(.subheadline)
                                .padding(.bottom, 5)
                            
                            // Mini Map Button
                            Button(action: {
                                isMapPresented.toggle()
                            }) {
                                ZStack {
                                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                                        center: coordinates,
                                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                    )))
                                    .frame(height: 200)
                                    .cornerRadius(8)
                                    
                                    // Add a marker pin
                                    Image(systemName: "mappin")
                                        .foregroundColor(.red)
                                        .imageScale(.large)
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .fullScreenCover(isPresented: $isMapPresented) {
                                MapView(coordinates: coordinates, placemarkTitle: jobPosting.companyName, selectedJob: $selectedJob)
                            }
                            
                            Spacer()
                            
                            // System back button
                            NavigationLink("", destination: EmptyView())
                                .navigationBarHidden(true)
                                .navigationBarBackButtonHidden(true)
                        }
                    }
                    
                    .padding()
                    
                }
                .navigationBarTitle("Job Details", displayMode: .inline)
                .onChange(of: filteredUsers) { newValue in
                    if !newValue.isEmpty {
                        isUsersViewPresented = true
                        print("isUsersViewPresented changed to: \(newValue)")
                    }
                }
                CustomNavigationBar(
                    isProfileActive: $isProfileActive,
                    isListViewActive: $isListViewActive,
                    isJobBoardActive: $isJobBoardViewActive,
                    isSignInViewActive: $isSignInViewActive,
                    isSignedIn: $isSignedIn, // Pass this binding
                    listAction: {
                        // Handle User List action
                        isListViewActive = true
                    },
                    jobBoardAction: {
                        // Handle Jobs Board action
                        isJobBoardViewActive = true
                    },
                    profileAction: {
                        // Handle Profile View action
                        isProfileActive = true
                    },
                    signInAction: {
                        // Handle Sign In action
                        isSignInViewActive = true
                    }
                    
                )
                .padding(.bottom, 8)
            }
            .sheet(isPresented: $isUsersViewPresented) {
                UsersListView(users: filteredUsers)
                    .environmentObject(dataManager)
//                    .environmentObject(currentJobVM)
            }
            .background(
                        NavigationLink(destination: ProfileView(), isActive: $isProfileActive) {
                            EmptyView()
                        }
                        .hidden()
                    )
                    .background(
                        NavigationLink(destination: ListView(), isActive: $isListViewActive) {
                            EmptyView()
                        }
                        .hidden()
                    )
                    .background(
                        NavigationLink(destination: JobBoardView(), isActive: $isJobBoardViewActive) {
                            EmptyView()
                        }
                        .hidden()
                    )
                    .background(
                        NavigationLink(destination: SignInView(isSignedIn: $isSignedIn), isActive: $isSignInViewActive) {
                            EmptyView()
                        }
                        .hidden()
                    )
        }
        .navigationBarItems(leading: Button("Back") {
            presentationMode.wrappedValue.dismiss()
        })
        .navigationBarBackButtonHidden(true)
        .onAppear {
                    self.currentJobVM.currentJob = self.jobPosting
                }
        .onDisappear {
            self.currentJobVM.currentJob = nil
        }
    }
        
    private func fetchAddress() {
            guard let coordinates = jobPosting.coordinates else {
                address = "Location not provided."
                return
            }

            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Geocoding error: \(error)")
                    address = "Error fetching address."
                    return
                }
                
                if let placemark = placemarks?.first {
                    address = [
                        placemark.thoroughfare,
                        placemark.locality,
                        placemark.administrativeArea,
                        placemark.postalCode,
                        placemark.country
                    ].compactMap { $0 }.joined(separator: ", ")
                } else {
                    address = "Address not found."
                }
            }
        }
    private func fetchUsersForProfession(_ profession: String) {
        Task {
            do {
                self.filteredUsers = await dataManager.fetchUsersFilteredByProfession(professions: [profession])
                self.showUsersListSheet = !self.filteredUsers.isEmpty
            } catch {
                print("Error fetching users: \(error)")
            }
        }
    }
    private func sendInterestNotification(profession: String) {
//        guard let currentJob = currentJobVM.currentJob else {
            print("No current job found.")
            return
        }
        // Use currentJob directly without needing to fetch it again
//        dataManager.sendJobRequest(to: jobPosting.userID, for: currentJob)
    }
//}
struct MapView: View {
    var coordinates: CLLocationCoordinate2D
    var placemarkTitle: String
    @Binding var selectedJob: JobPosting?

    @State private var isPinSelected = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )), showsUserLocation: false, userTrackingMode: .none, annotationItems: [MapPinItem(coordinate: coordinates, title: placemarkTitle)]) { item in
                    MapPin(coordinate: item.coordinate, tint: .red)
                }
                .edgesIgnoringSafeArea(.all)

                Button(action: {
                    isPinSelected.toggle()
                }) {
                    Color.clear
                }
                .buttonStyle(PlainButtonStyle())
                .fullScreenCover(isPresented: $isPinSelected) {
                    Text("Selected Pin: \(placemarkTitle)")
                }
            }
            .navigationBarTitle(placemarkTitle, displayMode: .inline)
            .navigationBarItems(leading: Button("Back") {
                presentationMode.wrappedValue.dismiss()
            })
            .onDisappear {
                selectedJob = nil
            }
        }
    }
}

struct MapPinItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}

extension CLPlacemark {
    var formattedAddress: String {
        let addressComponents: [String?] = [
            thoroughfare,
            subLocality,
            locality,
            administrativeArea,
            postalCode,
            country
        ]

        let nonNilComponents = addressComponents.compactMap { $0 }
        return nonNilComponents.joined(separator: ", ")
    }
}
class CurrentJobViewModel: ObservableObject {
    @Published var currentJob: JobPosting?
}

//a page to send job requests to a list of users matching the required profession
struct UsersListView: View {
    var users: [Account]
    @EnvironmentObject var currentJobVM: CurrentJobViewModel
    @EnvironmentObject var dataManager: DataManager
    @State private var requestsSent = Set<String>()

    var body: some View {
        VStack {
            List(users, id: \.id) { user in
                HStack {
                    ZStack {
                        VStack(alignment: .leading) {
                            Text(user.name).bold()
                                .font(.headline)
                                .padding(.bottom, 5)
                            Text(user.email)
                                .font(.subheadline)
                                .padding(.bottom, 5)
                            Text("Professions: \(user.professions.joined(separator: ", "))")
                        }
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        Spacer()
                    }
                    if requestsSent.contains(user.id) {
                        Text("Request Sent")
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    } else {
                        Button("Send Request") {
                            if let currentJob = currentJobVM.currentJob {
                                print("Current job found, sending request to \(user.name).")
                                // Assuming you have a method in DataManager to send a job request
                                // You might need to adjust parameters according to your method signature
                                dataManager.sendJobRequest(to: user.id, for: currentJob)
                                // Mark this user as having a request sent
                                requestsSent.insert(user.id)
                            } else {
                                print("No current job found.")
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .navigationBarTitle("Candidates", displayMode: .inline)
        .onAppear {
            print("UsersListView appeared with \(users.count) users")
        }
    }
}
