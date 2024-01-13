//
//  GafferDetails.swift
//  GafferDirectory
//
//  Created by Dylon Angol on 01/01/2024.
//

import Foundation
import UIKit

//defining a structure called MenuItem to represent the individual items within our array in MenuView
//identifiable is used to create a stable notion of identity for our new data type MenuItem. Now each item in our menu is identifiable and we can use list in MenuView to display them.
//we have essentially created our own data type MenuItem which expects properties 'id, name, price and image name'
struct User: Identifiable {
    //defining the properties of each MenuItem
    //defining our id as a Universally Unique id date type UUID so our Identifiable data type MenuItem is satisfied that we have assigned a UUID to a property which is 'id' in this case.
    var id = UUID()
    var email = String()
    var password = String()
    var name: String
  //  var imageName: UIImage // Use optional String instead of UIImage
    var profession: String
    var ownKit: Bool
    var flashExp: Bool
    var beautyLights: Bool
    var externalLights: Bool
    var practicalLights: Bool
}
extension User {
    init?(fromDictionary dictionary: [String: Any]) {
        guard
         //   let email = dictionary["email"] as? String,
       //     let password = dictionary["password"] as? String,
            let name = dictionary["name"] as? String,
            let profession = dictionary["profession"] as? String,
            let ownKit = dictionary["ownKit"] as? Bool,
            let flashExp = dictionary["flashExp"] as? Bool,
            let beautyLights = dictionary["beautyLights"] as? Bool,
            let externalLights = dictionary["externalLights"] as? Bool,
            let practicalLights = dictionary["practicalLights"] as? Bool
        else {
            return nil
        }

        self.init(name: name, profession: profession, ownKit: ownKit, flashExp: flashExp, beautyLights: beautyLights, externalLights: externalLights, practicalLights: practicalLights)
    }

    func toDictionary() -> [String: Any] {
        return [
            "email": email,
            "Password": password,
            "name": name,
            "profession": profession,
            "ownKit": ownKit,
            "flashExp": flashExp,
            "beautyLights": beautyLights,
            "externalLights": externalLights,
            "practicalLights": practicalLights
        ]
    }
}

