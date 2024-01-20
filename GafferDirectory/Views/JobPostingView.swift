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
                    if let postedJob = postedJob{
                        NavigationLink(
                            destination: JobDetailView(jobPosting: postedJob),
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
        .navigationBarBackButtonHidden(false)
    }
    
    private func postJob() {
        guard let userID = Auth.auth().currentUser?.uid else {
                print("User ID is nil")
                return
            }
        let newJobPosting = JobPosting(
            id: UUID().uuidString,
            userID: userID,
            companyName: companyName,
            jobDescription: jobDescription,
            coordinates: nil, // Coordinates need to be set if available
            postcode: "", // Set the postcode if available
            requiredProfessions: selectedRoles.map { $0.rawValue } // Map selected roles to their raw values
            
        )

        // Here, handle the geocoding if necessary and post the job using dataManager
        dataManager.postJobWithGeocoding(jobPosting: newJobPosting, address: address, selectedRoles: selectedCrewMembers)
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

