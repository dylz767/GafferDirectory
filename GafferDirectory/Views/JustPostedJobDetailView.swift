import SwiftUI
import CoreLocation
import MapKit

struct JustPostedJobDetailView: View {
    let jobPosting: JobPosting
    @EnvironmentObject var currentJobVM: CurrentJobViewModel
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

    
    @State private var region: MKCoordinateRegion

        init(jobPosting: JobPosting) {
            self.jobPosting = jobPosting
            self._region = State(initialValue: MKCoordinateRegion(
                center: jobPosting.coordinates ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
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
    private func sendInterestNotification(profession: String) {
//        guard let currentJob = currentJobVM.currentJob else {
            print("No current job found.")
            return
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
}


