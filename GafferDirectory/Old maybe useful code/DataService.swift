//
//  DataService.swift
//  GafferDirectory
//
//  Created by Dylon Angol on 01/01/2024.
//

import Foundation

struct DataService {
    
    func getData() -> [User]
    {
        return [User(name: "Tom",  profession: "Gaffer", ownKit: true, flashExp: true, beautyLights: false, externalLights: false, practicalLights: true),
                User(name: "Femi",  profession: "Gaffer", ownKit: false, flashExp: true, beautyLights: false, externalLights: false, practicalLights: true),
                User(name: "Gbenga",  profession: "Gaffer", ownKit: true, flashExp: true, beautyLights: false, externalLights: false, practicalLights: true),
                User(name: "Glody", profession: "Gaffer", ownKit: false, flashExp: true, beautyLights: false, externalLights: true, practicalLights: true),
                User(name: "Ngalula",  profession: "Gaffer", ownKit: true, flashExp: true, beautyLights: false, externalLights: true, practicalLights: true),
                User(name: "Tolu",  profession: "Gaffer", ownKit: true, flashExp: true, beautyLights: false, externalLights: false, practicalLights: true),
                User(name: "Temi",  profession: "Gaffer", ownKit: true, flashExp: true, beautyLights: false, externalLights: true, practicalLights: true),
                User(name: "Holly", profession: "Gaffer", ownKit: true, flashExp: true, beautyLights: false, externalLights: true, practicalLights: true),
                User(name: "Timmy", profession: "Gaffer", ownKit: true, flashExp: true, beautyLights: false, externalLights: false, practicalLights: true),
                User(name: "Tarja",  profession: "Gaffer", ownKit: false, flashExp: true, beautyLights: false, externalLights: true, practicalLights: true),
                User(name: "Hendon",  profession: "Gaffer", ownKit: true, flashExp: true, beautyLights: false, externalLights: true, practicalLights: true),]
    }
    
}
