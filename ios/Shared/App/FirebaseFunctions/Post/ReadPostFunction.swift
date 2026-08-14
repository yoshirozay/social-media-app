//
//  ReadPostFunction.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/13/22.
//

import Foundation

class ReadPostFunction: ObservableObject ,CloudFunction {
     
    class func readPostCloudFunction(postID: String, callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        guard let userId = currentUserID else { return }
        
        let postInformation = [
            "postID": postID,
            "currentUser": userId
        ]
        Self.call(funcName: "readPost-readPost", informationDict: postInformation){
            callback($0)
        }
    }
}
