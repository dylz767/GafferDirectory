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
    @State private var address: String = "" // New state for address
    
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
            .navigationBarBackButtonHidden(true)
            .background(
                VStack {
                    List {
                        // Your list content here
                    }
                    .onAppear {
                        // Your list onAppear logic here
                    }
                    .navigationTitle("Post a Job")
                    .navigationBarItems(leading: EmptyView())
                    .navigationBarBackButtonHidden(true)
                    
                    Spacer()
                    
                    CustomNavigationBar(
                        isProfileActive: $isProfileActive,
                        isListViewActive: $isListViewActive,
                        isJobBoardActive: $isJobBoardViewActive,
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
                        }
                    )
                    .padding(.bottom, 8)
                }
                .background(
                    NavigationLink(destination: ProfileView(), isActive: $isProfileActive) {
                        if isSignInViewActive == false
                        {
                            EmptyView()
                        }
                        else
                        if isSignInViewActive == true{
                            SignInView()
                        }
                    }
                    .hidden()
                )
                .background(
                    NavigationLink(destination: ListView(), isActive: $isListViewActive) {
                        if isSignInViewActive == false
                        {
                            EmptyView()
                        }
                        else
                        if isSignInViewActive == true{
                            SignInView()
                        }
                    }
                    .hidden()
                )
                .background(
                    NavigationLink(destination: JobBoardView(), isActive: $isJobBoardViewActive) {
                        if isSignInViewActive == false
                        {
                            EmptyView()
                        }
                        else
                        if isSignInViewActive == true{
                            SignInView()
                        }
                    }
                    .hidden()
                )
            )
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func postJob() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User ID is nil")
            return
        }

        dataManager.geocodeAddress(address) { result in
            switch result {
            case .success(let (geocodedCoordinates, postcode)):
                let jobPosting = JobPosting(
                    id: UUID().uuidString,
                    userID: userID,
                    companyName: companyName,
                    jobDescription: jobDescription,
                    coordinates: geocodedCoordinates,
                    postcode: postcode
                )

                // Save the job posting to Firestore
                print("Posting job:", jobPosting)
                dataManager.postJob(jobPosting: jobPosting)

                // Clear the input fields after posting
                companyName = ""
                jobDescription = ""

            case .failure(let error):
                // Handle the geocoding error here
                print("Geocoding error: \(error.localizedDescription)")
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
