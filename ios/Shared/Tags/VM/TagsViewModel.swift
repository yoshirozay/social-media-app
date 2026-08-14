//
//  AllFriendsViewModel.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/19/21.
//

import SwiftUI
import Combine

class TagsObservable: ObservableObject {
    @Published var rows = [[String]]()
    @Published var myTags : MyTagsOO
    var cancelSet: Set<AnyCancellable> = []
   
    init(tagsDictionary : MyTagsOO) {
        self.myTags = tagsDictionary
        tagsDictionary.$tags.didSet.sink { [weak self] newTags in
                    self?.updateRows(tags: newTags)
        }.store(in: &cancelSet)
        
        NotificationCenter.default.publisher(for: TagModel2.tagNotification)
            .compactMap{$0.object as? TagModel2}
            .sink() {  [weak self] tag in
                DispatchQueue.main.async {
                    self?.handleDummyTag(tag)
                }
            }
            .store(in: &cancelSet)
        
        NotificationCenter.default.publisher(for: TagModel2.tagFailedNotification)
            .compactMap{$0.object as? String}
            .sink() {[weak self] tagId in
                DispatchQueue.main.async {
                    self?.removeFailedDummyTag(tagId: tagId)
                }
            }
            .store(in: &cancelSet)
    }
    
     
    private func updateRows(tags: [String : TagModel2]) {
        DispatchQueue.main.async  {
            
            var tags = tags
            if Self.dummyTags.isNotEmpty {
                Self.dummyTags.removeAll { dummyTag in
                    return tags.contains(where: {$0.value.id == dummyTag.id})
                }
                Self.dummyTags.forEach { dummyTag in
                    tags[dummyTag.id] = dummyTag
                }
            }
            
            var count = 1
            var people = [String]()
            self.rows = []
            for i in  tags.keys {
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
                if count-1 ==  tags.count && !people.isEmpty {
                    self.rows.append(people)
                    people.removeAll()
                    
                }
            }
        }
    }
    
    func removeFailedDummyTag(tagId : String) {
        Self.dummyTags.removeAll(where: {$0.id == tagId})
        updateRows(tags: myTags.tags)
    }
    
    func handleDummyTag(_ dummyTag: TagModel2) {
        Self.dummyTags.append(dummyTag)
        updateRows(tags: myTags.tags)
    }
    
     func getTagInfo(rowIdx : Int,columnIdx : Int) -> (String,TagModel2?){
         var tag: TagModel2?
         let tagId = rows[rowIdx][columnIdx]
         if let tagModel = myTags.tags[tagId]{
             tag = tagModel
         }else if let dummyTag = Self.dummyTags.first(where: {$0.id == tagId}){
             tag = dummyTag
         }
         return(tagId,tag)
     }
    
    deinit {
        cancelSet.cancelAll()
    }
    static var dummyTags : [TagModel2] = []
}
