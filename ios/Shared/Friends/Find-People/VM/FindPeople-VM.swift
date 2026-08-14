//
//  FindPeople-VM.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//
import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import Combine

class FindPeopleOO: ObservableObject {
   @Published var people = [Person]()
   @Published var isSearching : Bool = false
   
   func search(username: String) {
       guard username.isNotEmpty else { return }
       var username2 = username
       if username2.first == "@" {
           username2.removeFirst()
   }
       people.removeAll()
       isSearching = true
       Firestore.firestore()
           .collection("UserInfo")
           .whereField("username", isEqualTo: "@"+username2.lowercased())
           .getDocuments {[weak self] (snap, err) in
               guard let self = self,
                     let documents = snap?.documents,
                     err == nil else { return }
               for doc in documents {
                   Person.getPersonFromUserInfo(userId: doc.documentID, documentData: doc.data()) {[weak self] person, error in
                       if let person = person {
                           self?.add(person : person)
                       }else{
                           print(error?.localizedDescription ?? "")
                       }
                   }
               }
               self.isSearching = false
           }
   }
   
   func add(person : Person) {
//        if !people.contains(where: {$0.id == person.id}){
           people.append(person)
//        }
   }
    func clearPerson() {
        people.removeAll()
    }
}
