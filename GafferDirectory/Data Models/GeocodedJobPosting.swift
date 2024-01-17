//
//  GeocodedJobPosting.swift
//  GafferDirectory
//
//  Created by Dylon Angol on 10/01/2024.
//

import SwiftUI
import CoreLocation
import Foundation


struct GeocodedJobPosting: Identifiable, Equatable, Hashable {
    let jobPosting: JobPosting
    var id: String
    var userID: String
    var companyName: String
    var jobDescription: String
    var coordinates: CLLocationCoordinate2D
    var postcode: String?
    
    static func == (lhs: GeocodedJobPosting, rhs: GeocodedJobPosting) -> Bool {
        // Implement the equality check based on your requirements
        return lhs.id == rhs.id
        // Add other properties if needed
    }
    
    func hash(into hasher: inout Hasher) {
           hasher.combine(id)
       }
}
