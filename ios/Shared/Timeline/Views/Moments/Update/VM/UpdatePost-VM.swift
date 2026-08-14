//
//  UpdatePost-VM.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import Foundation
import SwiftUI

class UpdatePostVM : ObservableObject {
    let post : PostModel
    init(post : PostModel) {
        self.post = post
    }
    @Published var text : String = ""
    func updatePost(){
        
        guard let userId = currentUserID,userId == post.id else { return }
        
        if text.trimWhitespacesAndNewlines().isNotEmpty{
            NewPostFunctions.edit(postID: post.postID, author: userId, content: text) { error in
                print("123^ UpdatePostVM \(error?.localizedDescription ?? "successfull")")
            }
        }
    }
    
}

