//import Foundation
//import CoreLocation
//
//class JobBoardViewModel: ObservableObject {
//    @Published var geocodedJobs: [Job] = []
//
//    func fetchAndGeocodeJobs() {
//        let jobs = fetchJobs()
//
//        let dispatchGroup = DispatchGroup()
//
//        for job in jobs {
//            if let coordinates = job.coordinates {
//                let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
//
//                dispatchGroup.enter()
//
//                geocodeLocation(location, forJobId: job.id) { result in
//                    switch result {
//                    case .success(let placemark):
//                        var updatedJob = job
//                        updatedJob.postcode = placemark.postalCode
//
//                        DispatchQueue.main.async {
//                            self.geocodedJobs.append(updatedJob)
//                        }
//
//                        print("Geocoded location for Job ID \(job.id): \(placemark)")
//                    case .failure(let error):
//                        print("Geocoding error for Job ID \(job.id): \(error.localizedDescription)")
//                    }
//
//                    dispatchGroup.leave()
//                }
//            }
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            print("Geocoding of all jobs completed")
//        }
//    }
//
//    private func fetchJobs() -> [Job] {
//        // Placeholder method to fetch jobs (update based on your implementation)
//        // Example: Fetch jobs from Firestore or another API
//        // ...
//
//        // For now, returning a dummy array
//        return [
//            Job(id: "1", companyName: "Company A", coordinates: Coordinates(latitude: 37.7749, longitude: -122.4194)),
//            Job(id: "2", companyName: "Company B", coordinates: Coordinates(latitude: 34.0522, longitude: -118.2437))
//            // Add more jobs as needed
//        ]
//    }
//
//    private func geocodeLocation(_ location: CLLocation, forJobId jobId: String, completion: @escaping (Result<CLPlacemark, Error>) -> Void) {
//        // Placeholder method for geocoding (update based on your geocoding logic)
//        // Example: Use CLGeocoder to reverse geocode the location
//        // ...
//
//        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
//            if let error = error {
//                let geocodingError = NSError(domain: "GeocodingErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Geocoding failed: \(error.localizedDescription)"])
//                completion(.failure(geocodingError))
//                print("Geocoding error: \(error.localizedDescription)")
//                return
//            }
//
//            guard let placemark = placemarks?.first else {
//                let customError = NSError(domain: "GeocodingErrorDomain", code: 2, userInfo: [NSLocalizedDescriptionKey: "No placemark found"])
//                completion(.failure(customError))
//                print("Geocoding error: No placemark found")
//                return
//            }
//
//            completion(.success(placemark))
//            print("Geocoded location for Job ID \(jobId): \(placemark)")
//        }
//    }
//}
