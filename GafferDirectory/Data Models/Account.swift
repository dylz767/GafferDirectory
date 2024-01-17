//
//  Account.swift
//  GafferDirectory
//
//  Created by Dylon Angol on 04/01/2024.
//

import SwiftUI

struct Account: Identifiable, Equatable {
        var id: String
        var userId: String  // Add user ID field
        var name: String
        var profession: String
        var email: String
}