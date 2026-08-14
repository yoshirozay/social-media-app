//
//  UpdateIntroVideoSeenStatusFunction.swift
//  speakEZ
//
//  Created by Ahmad naeem on 11/25/21.
//

import Foundation

class IntroSeenStatusFuncs: ObservableObject, CloudFunction {
    class func hasWatchedMainVideo(userId: String, callback: @escaping (Error?) -> Void = {_ in }) {
        let newVideoInformation = ["userID" : userId]
        Self.call(funcName: "hasWatchedMainVideo-hasWatchedMainVideo", informationDict: newVideoInformation, callback: callback)
    }
    
    class func hasDoneIntroduction(userId: String, callback: @escaping (Error?) -> Void = {_ in }) {
        let newVideoInformation = ["userID" : userId]
        Self.call(funcName: "hasDoneIntroduction-hasDoneIntroduction", informationDict: newVideoInformation, callback: callback)
    }
} 
