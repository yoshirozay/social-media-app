//
//  AllFriendsViewModel.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/19/21.
//

import SwiftUI
import Combine

class TagInvitationsObservable: ObservableObject {

    @Published var tagsDictionary = MyTagInvitationsOO()
    @Published var rows = [[String]]()
    var anyCancellable: AnyCancellable? = nil
    init() {
        anyCancellable = tagsDictionary.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
        var count = 1
        var people = [String]()
                
        guard let self = self else { return  }
                
                for i in self.tagsDictionary.tags.keys { 
            people.append(i)
            // checking and creating rows
            if people.count == 2 {
                if let last = self.rows.last {
                    if last.count == 3 {
                        self.rows.append(people)
                        people.removeAll()
                    }
                }
                // for first time no data
                
                if self.rows.isEmpty {
                    self.rows.append(people)
                    people.removeAll()
                }
                
            }
            if people.count == 3 {
                if let last = self.rows.last {
                    if last.count == 2 {
                        self.rows.append(people)
                        people.removeAll()
                    }
                }
            }
            
            
            count += 1
            // for exhaust data or single data
                    if count-1 == self.tagsDictionary.tags.count && !people.isEmpty {
                        self.rows.append(people)
                people.removeAll()
                
            }
        }
            }
        }
    }
}
