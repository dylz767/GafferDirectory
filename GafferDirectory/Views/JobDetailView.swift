import SwiftUI
import CoreLocation
import MapKit

struct JobDetailView: View {
    let jobPosting: JobPosting
    @State private var address: String?
    @State private var isMapPresented = false
    @State private var isProfileActive = false
    @State private var isListViewActive = false
    @State private var isJobBoardViewActive = false
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedJob: JobPosting?
    @State private var isSignInSuccess = true
    @State private var isSignInViewActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Company: \(jobPosting.companyName)")
                    .font(.headline)
                    .padding(.bottom, 5)
                Text("Description: \(jobPosting.jobDescription)")
                    .font(.subheadline)
                    .padding(.bottom, 5)
                Text("Job Location:")
                    .font(.body)
                    .padding(.bottom, 5)
                if let coordinates = jobPosting.coordinates {
//                    Text("Location: \(coordinates.latitude), \(coordinates.longitude)")
//                        .font(.subheadline)
//                        .padding(.bottom, 5)
                    
                    if let address = address {
//                        Text("Address: \(address)")
//                            .font(.subheadline)
//                            .padding(.bottom, 5)
                    } else {
//                        Button("Fetch Address") {
//                            fetchAddress()
//                        }
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                        .padding(.bottom, 10)
                    }
                    
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
        .navigationBarTitle("Jobs Board")
        
        
                       }
                       
                       private func fetchAddress() {
                           guard let coordinates = jobPosting.coordinates else {
                               return
                           }

                           let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                           CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                               if let placemark = placemarks?.first {
                                   address = placemark.formattedAddress
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
