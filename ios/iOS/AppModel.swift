//
//  AppModel.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/15/21.
//

import SwiftUI

let phoneWidth = UIScreen.main.bounds.size.width
let phoneHeight = UIScreen.main.bounds.size.height

struct Person: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let username: String
    let description: String
    let friends: String
    let firstname: String
    let photo: String    
}
