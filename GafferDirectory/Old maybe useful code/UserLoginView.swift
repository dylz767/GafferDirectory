//
//  UserLoginView.swift
//  GafferDirectory
//
//  Created by Dylon Angol on 04/01/2024.
//

import SwiftUI
import Firebase

struct UserLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userName = ""
    @State private var userProfession = ""
    @State private var userOwnKit = false
    @State private var userFlashExp = false
    @State private var userBeautyLights = false
    @State private var userExternalLights = false
    @State private var userPracticalLights = false
    
    // Binding to the array of gaffers
    @Binding var gaffers: [User]
    @State private var isUserSignedUp = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sign Up Information")) {
                    TextField("Email", text: $email)
                        .foregroundColor(email.isEmpty ? Color.gray : Color.black)
                    SecureField("Password", text: $password)
                        .foregroundColor(password.isEmpty ? Color.gray : Color.black)
                }
            }
        }
    }
    
    
    
    
    
    
    
}
