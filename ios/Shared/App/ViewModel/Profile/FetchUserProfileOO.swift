//
//  FetchUserProfileOO.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 6/28/21.
//

import Foundation
import SwiftUI
import Firebase

class ProfileOO: ObservableObject {
    @Published var person = Person(id: "")
    init(id: String)  {
        guard id.isNotEmpty else { return  }
        Person.fetchFriend(id: id) {[weak self] person, error in
            if let friend = person {
                self?.person = friend
            }else{
                print(error?.localizedDescription ?? "")
            }
        }
    }
}

class FriendProfileOO: ObservableObject {
    @Published var person : Person?
     
    func fetchFriend(id : String) {
        guard id.isNotEmpty else { return  }
        Person.fetchFriend(id: id) {[weak self] person, error in
            if let friend = person {
                withAnimation(.easeOut(duration: 0.3)){
                    self?.person = friend
                } 
            }else{
               print(error?.localizedDescription ?? "")
            }
        }
    }
    func refresh(){
        person = nil
    }
}
