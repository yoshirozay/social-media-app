//
//  SuggestedFriend.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/8/21.
//

import Foundation
 //FIXME: - change it t model
struct SuggestedFriend  {
    var id : String = UUID().uuidString
    var user : Person
    var contact: Contact? = nil
    var isFromContacts : Bool{
        contact != nil
    }
    var isFromMutual : Bool {
        contact == nil
    }
    var name : String{
        contact?.firstName ?? user.name
    } 
}

extension SuggestedFriend : Identifiable, Hashable,Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: SuggestedFriend, rhs: SuggestedFriend) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Array where Element == SuggestedFriend {
    var getUserIDs : Set<String>{
        self.map({$0.user.id}).getSet()
    }
}
