//
//  UserDetail.swift
//  speakEZ
//
//  Created by Ahmad naeem on 11/25/21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct UserDetail : Decodable {
    
    let hasWatchedMainVideo: Bool
    let hasDoneIntroduction: Bool
    
    enum CodingKeys: String, CodingKey {
        case hasWatchedMainVideo
        case hasDoneIntroduction
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hasWatchedMainVideo = (try? container.decodeIfPresent(Bool.self, forKey: .hasWatchedMainVideo)) ?? true
        hasDoneIntroduction = (try? container.decodeIfPresent(Bool.self, forKey: .hasDoneIntroduction)) ?? false
    }
    
    static func getUserDetail(userId : String, source: FirestoreSource = .default, callback: @escaping (UserDetail?, Error?) -> Void) {
        
        fetchUserDetail(userId: userId, source: .cache) { userDetail, error in
            if let userDetail = userDetail,
               userDetail.hasWatchedMainVideo == true,
               userDetail.hasDoneIntroduction == true {
                callback(userDetail,error)
            }else{
                fetchUserDetail(userId: userId, source: .server) { latestUserDetail, error in
                    if let _ = error{
                        callback(userDetail,error)
                    }else{
                        callback(latestUserDetail,error)
                    }
                }
            }
        }
    }
    
    static private func fetchUserDetail(userId : String, source: FirestoreSource = .default, callback: @escaping (UserDetail?, Error?) -> Void) {
        let docRef = Firestore.firestore().collection(Constant.UserDetail()).document(userId.nonEmpty)
        docRef.getDocument(source: source) { (document, error) in
             let userDetail = try? document?.data(as: UserDetail.self)
                callback(userDetail,error)
        }
    }
    
    enum Constant: String {
    case UserDetail
    }
}
