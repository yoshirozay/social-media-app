//
//  DeletePostFunctions.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 3/9/21.
//

import SwiftUI
import Firebase
import FirebaseFunctions
import SDWebImage

class DeletePostFunctions: ObservableObject ,CloudFunction {
     
    func deletePost(post: PostModel ) {
        Self.deletePost(post: post)
    }
    
    class func deletePost(post: PostModel ) {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
         
        post.deleteMediaFromCacheIfExist()
        
        let deletePostInformation : [String: Any]  = [
            "currentUser": userId,
            "postID": post.postID,
            "isThereAPhoto": post.doesHaveAPhoto,
            "isThereAVideo": post.doesHaveAVideo,
            "isThereAudio": post.doesHaveAudio,
        ]
        
        deletePostCloudFunc(deletePostInformation: deletePostInformation){error in
            if let error = error{
                print(error.localizedDescription  )
            }else{
                print("/n deletePostCloudFunc successfull /n ")
            }
        }
        
       
    }
    
    class private func deletePostCloudFunc(deletePostInformation: [String : Any],callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        Self.call(funcName: deletePostFuncName, informationDict: deletePostInformation){
            callback($0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Self.call(funcName: deletePostFuncName, informationDict: deletePostInformation)
        }
    }
    
    
    static let deletePostFuncName = "deletePost-deletePost"
}

