//
//  PostModel.swift
//  Clix(No Firebase)
//
//  Created by Carson O'Sullivan on 11/15/20.
//

import SwiftUI

struct PostModel: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let username: String
    let time: String
    let post: String
    let photo: String
    
}

struct CommentModel: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let username: String
    let time: String
    let comment: String
    let photo: String
    
}
