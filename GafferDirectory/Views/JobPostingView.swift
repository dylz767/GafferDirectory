import SwiftUI
import Firebase
import CoreLocation

struct JobPostingView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var companyName: String = ""
    @State private var jobDescription: String = ""
    @State private var isProfileActive = false
    @State private var isListViewActive = false
    @State private var isJobBoardViewActive = false
    @State private var isSignInViewActive = false
    @State private var isSignedIn = true
    @State private var address: String = ""
    @State private var postedJob: JobPosting?
    @State private var navigateToJobDetails = false
    @State private var selectedRoles: [Profession] = [] // For storing selected roles
    @State private var selectedCrewMembers: [String: String] = [:] // Role: UserID
    @State private var showingJobPostingView = false
    @State private var showingJobDetailsView = false
    @State private var postedJobID: String? = nil
    @State private var isLocationValid: Bool? = nil

    @Environment(\.presentationMode) var presentationMode
    

    // All professions
    let allRoles: [Profession] = [.dp, .gaffer, .spark, .producer, .artDepartment, .hmua, .editor, .colourGrade, .runner, .director, .photographer, .photographerAssistant]

    var body: some View {
        NavigationView {
            VStack {
                TextField("Company Name", text: $companyName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Description", text: $jobDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Address", text: $address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Roles Picker
                Text("Select Roles:")
                               List {
                                   ForEach(allRoles, id: \.self) { role in
                                       MultipleSelectionRow(title: role.rawValue, isSelected: self.selectedRoles.contains(role)) {
                                           if self.selectedRoles.contains(role) {
                                               self.selectedRoles.removeAll { $0 == role }
                                           } else {
                                               self.selectedRoles.append(role)
                                           }
                                       }
                                   }
                               }

                if isLocationValid == false {
                    Text("Enter valid location")
                }
                else
                {
                    
                }
                Button("Post Job") {
                    postJob()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Post a Job", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                           // Action to dismiss the current view and go "Back"
                           self.presentationMode.wrappedValue.dismiss()
                       }) {
                           Text("Back")
                       })
            .navigationBarBackButtonHidden(true)
            .background(
                VStack {
                    if let postedJob = postedJob{
                        NavigationLink(
                            destination: JustPostedJobDetailView(jobPosting: postedJob),
                            isActive: $navigateToJobDetails
                        ) {
                            EmptyView()
                        }
                        .hidden()
                    }
                    Spacer()
                    
                    .padding(.bottom, 8)
                }
            )
        }
        
        .navigationBarBackButtonHidden(true)
    }
    
    private func postJob() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User ID is nil")
            return
        }

        var newJobPosting = JobPosting(
            id: UUID().uuidString,
            userID: userID,
            companyName: companyName,
            jobDescription: jobDescription,
            coordinates: nil, // This will be set after geocoding
            postcode: "",
            requiredProfessions: selectedRoles.map { $0.rawValue }
        )

        // Assuming `geocodeAddresses` is a function that geocodes the address and updates the job posting
        geocodeAddresses([address]) { result in
            switch result {
                case .success(let geocodingResults):
                    if let firstResult = geocodingResults.first {
                        let (coordinates, postcode) = firstResult
                        newJobPosting.coordinates = coordinates // Update the coordinates
                        newJobPosting.postcode = postcode // Update the postcode if necessary

                        // Proceed with posting the job using dataManager
                        self.dataManager.postJobWithGeocoding(jobPosting: newJobPosting, address: self.address, selectedRoles: self.selectedCrewMembers)

                        // Update state to trigger navigation
                        self.postedJob = newJobPosting
                        self.navigateToJobDetails = true
                    }
                case .failure(let error):
                    print("Geocoding failed: \(error.localizedDescription)")
                    // Handle the error appropriately
                
                DispatchQueue.main.async {
                        // Step 1: Dismiss the current view
                        self.presentationMode.wrappedValue.dismiss()

                        // Step 2: Optionally delay the navigation to ensure the view is dismissed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.postedJob = newJobPosting // Assuming this triggers the navigation
                            self.navigateToJobDetails = true
                        }
                    }
            }
        }
    }
    func geocodeAddresses(_ addresses: [String], completion: @escaping (Result<[(CLLocationCoordinate2D, String)], Error>) -> Void) {
            let geocoder = CLGeocoder()
            var geocodingResults: [(CLLocationCoordinate2D, String)] = []
            var errors: [Error] = []

            let dispatchGroup = DispatchGroup()

            for address in addresses {
                dispatchGroup.enter()

                geocoder.geocodeAddressString(address) { (placemarks, error) in
                    defer {
                        dispatchGroup.leave()
                    }

                    if let error = error {
                        errors.append(error)
                        return
                    }

                    if let location = placemarks?.first?.location?.coordinate, let postcode = placemarks?.first?.postalCode {
                        geocodingResults.append((location, postcode))
                    } else {
                        let customError = NSError(domain: "GeocodingErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid coordinates for address: \(address)"])
                        errors.append(customError)
                    }
                }
            }
        dispatchGroup.notify(queue: .main) {
                   if errors.isEmpty {
                       completion(.success(geocodingResults))
                   } else {
                       completion(.failure(errors.first ?? NSError(domain: "GeocodingErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                   }
               }
           }

}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

// Enum for professions
enum Profession: String, CaseIterable {
    case dp = "DP"
    case gaffer = "Gaffer"
    case spark = "Spark"
    case producer = "Producer"
    case artDepartment = "Art Department"
    case hmua = "HMUA"
    case editor = "Editor"
    case colourGrade = "Colour Grade"
    case runner = "Runner"
    case director = "Director"
    case photographer = "Photographer"
    case photographerAssistant = "Photographer Assistant"
}

