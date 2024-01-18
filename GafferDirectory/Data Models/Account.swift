//
//  Account.swift
//  GafferDirectory
//
//  Created by Dylon Angol on 04/01/2024.
//

import SwiftUI
import CoreLocation
import Foundation

struct Account: Identifiable, Hashable {
    var id: String
    var userId: String
    var name: String
    var profession: String
    var email: String
    var coordinates: CLLocationCoordinate2D?
    var favorites: [String]? // Optional, depending on your design choice
    // Add more properties as needed

    // Ensure the struct is Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Implement Equatable for comparison
extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.id == rhs.id
    }

}
