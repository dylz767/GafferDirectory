import SwiftUI
import CoreLocation
import MapKit

struct JobDetailView: View {
    let jobPosting: JobPosting
    @EnvironmentObject var dataManager: DataManager
    @State private var isUsersViewPresented: Bool = false
    @State private var selectedProfession: String?
    @State private var filteredUsers: [Account] = []
    @Environment(\.presentationMode) var presentationMode
    @State private var showUsersListSheet = false

    var body: some View {
        NavigationView {
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
                }
                .padding()
            }
            .navigationBarTitle("Job Details", displayMode: .inline)
            .onChange(of: filteredUsers) { newValue in
                if !newValue.isEmpty {
                    isUsersViewPresented = true
                }
            }
            .sheet(isPresented: $isUsersViewPresented) {
                UsersListView(users: filteredUsers)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button("Back") {
            presentationMode.wrappedValue.dismiss()
        })
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
struct UsersListView: View {
    var users: [Account]
    

    var body: some View {
        List(users, id: \.id) { user in
            VStack(alignment: .leading) {
                Text(user.name).bold()
                Text(user.email)
                Text("Professions: \(user.professions.joined(separator: ", "))")
            }
        }
        .navigationBarTitle("Candidates", displayMode: .inline)
        .onAppear {
            print("UsersListView appeared with \(users.count) users")
        }
    }
}
