//
//  ProfilePostsOO.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 1/24/21.
//

import SwiftUI
import Firebase
import FirebaseStorage

class ProfilePostsOO: ObservableObject {
    @Published var postInfo = [PostModel]()
    @Published var myTagIDs = [String]()
    var listener: ListenerRegistration?
    init() {
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        getMyTagsAccessIDs()
        let collectionRef = Firestore.firestore().collection("Posts").document(userId.nonEmpty).collection("UserPosts")
         listener = collectionRef.addSnapshotListener{[weak self] (querySnapshot, error) in
            if error != nil{
                print("there's an error PostViewModel.swift")
                return
            }
            guard let documentChanges = querySnapshot?.documentChanges else {
                print("Error fetching documents: \(error?.localizedDescription ?? "" )")
                return
            }
//            if querySnapshot!.isEmpty{
//            }
            for document in documentChanges {
                if document.type == .added {
                    collectionRef.document(document.document.documentID.nonEmpty).getDocument { (doc, err) in
                        guard let user = doc else { return }
                        
                        
                        var doesPostHaveATag = false
                        var doesCurrentUserHaveAccess = false
                        var tagNames = [String]()
                        
                        if let tags = user.data()?["tags"] as? [String] {
                            doesPostHaveATag = true
                            for item in tags {
                                if self?.myTagIDs.firstIndex(of: item) != nil {
                                    doesCurrentUserHaveAccess = true
                                    tagNames.append(item)
                                }
                            }
                        }
                        if doesPostHaveATag == false || doesPostHaveATag == true && doesCurrentUserHaveAccess == true {
                        
                        let sentBy = user.data()?["sentBy"] as? String ?? ""
                        let content = user.data()?["content"] as? String ?? ""
                            let time = user.data()?["time"] as? Timestamp ?? Timestamp()
                            let updatedAt = user.data()?["updatedAt"] as? Timestamp ?? Timestamp()
                        let postID = document.document.documentID
                       
                       let photoLink = (user.data()?["photoLink"] as? String)?.possibleURL
                       let thumbnailUrl : URL? = (user.data()?["thumbnailUrl"] as? String)?.possibleURL
                       let videoUrl : URL? = (user.data()?["videoUrl"] as?  String)?.possibleURL
//
                        let newTime = time.dateValue()
                        let format = DateFormatter()
                        format.dateFormat = "MMM d, h:mm a"
                        let timeString = format.string(from: newTime)
                            self?.postInfo.append(PostModel(id: sentBy,
                                                  time: time,
                                                  content: content,
                                                  photoLink: photoLink,
                                                  postID: postID,
                                                  timeString: timeString,
                                                  tags: tagNames,
                                                  thumbnailUrl: thumbnailUrl,
                                                  videoUrl: videoUrl,
                                                  updatedAt: updatedAt))
                        
                        }
                    }
                }
            }
        }
    }
    func getMyTagsAccessIDs(){
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let docRef = Firestore.firestore().collection("MyTagsAccess").document(userId.nonEmpty)
        docRef.getDocument { (document, error)  in
            if error != nil{
                print("there's an error getMyTagIDs")
                return
            }
            if let dict = document?.data(){
                let fetchedTags : [String] =  dict.compactMap{  ($0.value as? String ) == nil ? nil : $0.key }
//                for item in fetchedTags {
//                    self.myTagIDs.append(item)
//                }
                self.myTagIDs = fetchedTags
            }
        }
    }
    deinit {
        listener?.remove()
    }
}

