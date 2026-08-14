//
//  NotificationsOO.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/22/21.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class NotificationsOO: ObservableObject {
    @Published var newNotifications = [String: Notification]()
    @Published var notifications = [String: Notification]()
    @Published var cloudNotifications = [[String:String]]()
    private func buildNotifications(querySnapshot: QuerySnapshot){
        
      
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let collectionRef = Firestore.firestore().collection("Notifications").document(userId.nonEmpty).collection("MyNotifications")
        for document in querySnapshot.documentChanges {
            if document.type == .added {
                collectionRef.document(document.document.documentID.nonEmpty).getDocument { (doc, err) in
                    guard let user = doc else { return }
                    if user.data()?["resourceID"] != nil,
                       let createdAt = user.data()?["createdAt"] as? Timestamp,
                       createdAt.dateValue() < Date(){
                        let id = document.document.documentID
                        let resource = (user.data()?["resourceID"] as? String ?? "")
                        
                        
                        let resourceType = (user.data()?["resourceID"] as? String ?? "").components(separatedBy: ":")[0]
                        let resourceID = (user.data()?["resourceID"] as? String ?? "").components(separatedBy: ":")[1]
                        let sentFromUser = user.data()?["sentFromUser"] as? String ?? ""
                        let originalAuthor = user.data()?["originalAuthor"] as? String ?? ""
//                        guard let createdAt = user.data()?["createdAt"] as? Timestamp else { return }
                        
                        let format = DateFormatter()
                        let accurateTimeString = format.string(from: createdAt.dateValue())
                        if resourceType == "likedComment" || resourceType == "commentReply" {
                            let nameOfSendingUser = user.data()?["nameOfSendingUser"] as? String ?? ""
                            let webLink = URL(string: user.data()?["webLink"] as? String ?? "")
                            
                            guard let webLink = webLink else { return  }
                            
                            self.newNotifications[id] = (Notification(id: id, resourceType: resourceType, resourceID: resourceID, sentFromUser: sentFromUser, createdAt: createdAt, timeString: self.getTimeString(createdAt: createdAt), accurateTimeString: accurateTimeString, newNotification: true, nameOfSendingUser: nameOfSendingUser, webLink: webLink, originalAuthor: originalAuthor))
                            
                            self.notifications[id] = (Notification(id: id, resourceType: resourceType, resourceID: resourceID, sentFromUser: sentFromUser, createdAt: createdAt, timeString: self.getTimeString(createdAt: createdAt), accurateTimeString: accurateTimeString, newNotification: true, nameOfSendingUser: nameOfSendingUser, webLink: webLink, originalAuthor: originalAuthor))

                            format.dateFormat =  "YYYY/MM/d HH:mm:ssZ"
                            let newTime =  format.string(from: createdAt.dateValue())
                            
                            self.cloudNotifications.append(["id": id, "resourceID": resource, "sentFromUser": sentFromUser, "nameOfSendingUser": nameOfSendingUser, "webLink": "\(webLink)", "createdTime": newTime, "currentUser": userId, "originalAuthor": originalAuthor])
                        } else if resourceType == "sharedF"{
                            let nameOfSharedFriend  = user.data()?["nameOfSharedFriend"] as? String ?? ""
                            let webLink = URL(string: user.data()?["webLink"] as? String ?? "")
                            guard let webLink = webLink else { return  }
                            self.newNotifications[id] = (Notification(id: id, resourceType: resourceType, resourceID: resourceID, sentFromUser: sentFromUser, createdAt: createdAt, timeString: self.getTimeString(createdAt: createdAt), accurateTimeString: accurateTimeString, newNotification: true, webLink: webLink, nameOfSharedFriend: nameOfSharedFriend, originalAuthor: originalAuthor))
                            
                            self.notifications[id] = (Notification(id: id, resourceType: resourceType, resourceID: resourceID, sentFromUser: sentFromUser, createdAt: createdAt, timeString: self.getTimeString(createdAt: createdAt), accurateTimeString: accurateTimeString, newNotification: true, webLink: webLink, nameOfSharedFriend: nameOfSharedFriend, originalAuthor: originalAuthor))

                            format.dateFormat =  "YYYY/MM/d HH:mm:ssZ"
                            let newTime =  format.string(from: createdAt.dateValue())
                            
                            self.cloudNotifications.append(["id": id, "resourceID": resource, "sentFromUser": sentFromUser, "nameOfSharedFriend": nameOfSharedFriend, "webLink": "\(webLink)", "createdTime": newTime, "currentUser": userId, "originalAuthor": originalAuthor])
                        
                        } else {
                            
                            self.newNotifications[id] = (Notification(id: id, resourceType: resourceType, resourceID: resourceID, sentFromUser: sentFromUser, createdAt: createdAt, timeString: self.getTimeString(createdAt: createdAt), accurateTimeString: accurateTimeString, newNotification: true, originalAuthor: originalAuthor))
                            
                            self.notifications[id] = (Notification(id: id, resourceType: resourceType, resourceID: resourceID, sentFromUser: sentFromUser, createdAt: createdAt, timeString: self.getTimeString(createdAt: createdAt), accurateTimeString: accurateTimeString, newNotification: true, originalAuthor: originalAuthor))
                            
                            format.dateFormat =  "YYYY/MM/d HH:mm:ssZ"
                            let newTime =  format.string(from: createdAt.dateValue())
                            
                            self.cloudNotifications.append(["id": id, "resourceID": resource, "sentFromUser": sentFromUser, "createdTime": newTime, "currentUser": userId, "originalAuthor": originalAuthor])
                        }
                    }
                }
            }
        }
    }
    var listener3: ListenerRegistration?
    
    private func buildOldNotifcations(querySnapshot: QuerySnapshot){
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let docRef = Firestore.firestore().collection("Notifications").document(userId.nonEmpty).collection("OldNotifications").order(by: "createdAt", descending: true).limit(to: 69)
       listener3 = docRef.addSnapshotListener { [weak self]  (document, error) in
            if error != nil{
                print(error as Any)
                return
            }
            
            let currentDate = Date()
            for document in querySnapshot.documentChanges {
                if document.type == .added,
                   let createdAt = document.document.get("createdAt") as? Timestamp,
                   createdAt.dateValue() < currentDate{
                    //                docRef.document(document.document.documentID).getDocument { (doc, err) in
                    //                    guard let user = document else { return }
                    let id = document.document.documentID
                    let resourceType = (document.document.get("resourceID") as? String ?? "").components(separatedBy: ":")[0]
                    let resourceID = (document.document.get("resourceID") as? String ?? "").components(separatedBy: ":")[1]
                    let sentFromUser = (document.document.get("sentFromUser") as? String ?? "")
                    let originalAuthor = (document.document.get("originalAuthor") as? String)
//                    let createdAt : Timestamp
//                    if let createdAtTimestamp = document.document.get("createdAt") as? Timestamp  {
//                        createdAt = createdAtTimestamp
//                    }else{
//                        continue
//                    }
                    
                    guard let self = self else { return }
                    
                    let format = DateFormatter()
                    format.dateFormat = "MMM d, h:mm:ss a"
                    let accurateTimeString = format.string(from: createdAt.dateValue())
                    
                    if resourceType != "likedComment" && resourceType != "commentReply" {
                    if self.notifications.values.firstIndex(where: { $0.id == id }) != nil {
                        let firstIndexMatchingDocId = self.notifications.values.firstIndex(where: { $0.id == id })
                        guard let currentNotificationIndex = firstIndexMatchingDocId else { return }
                        self.notifications.values[currentNotificationIndex] = Notification(id: id, resourceType: resourceType, resourceID: resourceID, sentFromUser: sentFromUser, createdAt: createdAt, timeString: self.getTimeString(createdAt: createdAt), accurateTimeString: accurateTimeString, newNotification: false, originalAuthor: originalAuthor)
                        self.newNotifications.removeAll()
                        
                    } else {
                        self.notifications[id] = (Notification(id: id, resourceType: resourceType, resourceID: resourceID, sentFromUser: sentFromUser, createdAt: createdAt, timeString: self.getTimeString(createdAt: createdAt), accurateTimeString: accurateTimeString, newNotification: false, originalAuthor: originalAuthor))
                        self.newNotifications.removeAll()
                        
                    }
                    } else {
                        let nameOfSendingUser = (document.document.get("nameOfSendingUser") as? String ?? "")
                        let webLink = URL(string: (document.document.get("webLink") as? String ?? ""))
                        if self.notifications.values.firstIndex(where: { $0.id == id }) != nil {
                            let firstIndexMatchingDocId = self.notifications.values.firstIndex(where: { $0.id == id })
                            guard let currentNotificationIndex = firstIndexMatchingDocId else { return }
                            self.notifications.values[currentNotificationIndex] = Notification(id: id, resourceType: resourceType, resourceID: resourceID, sentFromUser: sentFromUser, createdAt: createdAt, timeString: self.getTimeString(createdAt: createdAt), accurateTimeString: accurateTimeString, newNotification: false, nameOfSendingUser: nameOfSendingUser, webLink: webLink, originalAuthor: originalAuthor)
                            self.newNotifications.removeAll()
                            
                        } else {
                            self.notifications[id] = (Notification(id: id, resourceType: resourceType, resourceID: resourceID, sentFromUser: sentFromUser, createdAt: createdAt, timeString: self.getTimeString(createdAt: createdAt), accurateTimeString: accurateTimeString, newNotification: false, nameOfSendingUser: nameOfSendingUser, webLink: webLink, originalAuthor: originalAuthor))
                            self.newNotifications.removeAll()
                            
                        }
                    }
                }
            }
        }
    }
    private func getTimeString(createdAt: Timestamp) -> String {
        var timeString = ""
        if Calendar.current.isDateInToday(createdAt.dateValue()) == true {
            let format = DateFormatter()
            format.dateFormat = "h:mm a"
            timeString = format.string(from: createdAt.dateValue())
        }
        if Calendar.current.isDateInYesterday(createdAt.dateValue()) == true {
            
            timeString = "Yesterday"
        }
        if Calendar.current.isDateInToday(createdAt.dateValue()) == false &&  Calendar.current.isDateInYesterday(createdAt.dateValue()) == false {
            let startOfNow = Calendar.current.startOfDay(for: Date())
            let startOfTimeStamp = Calendar.current.startOfDay(for: createdAt.dateValue())
            let components = Calendar.current.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
            if let day = components.day , day < 1 {
                timeString = "\(-day) days ago"
            }
        }
        return timeString
    }
    var listener2: ListenerRegistration?
    
    init(){
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let collectionRef = Firestore.firestore().collection("Notifications").document(userId.nonEmpty).collection("MyNotifications")
      listener2 =  collectionRef.addSnapshotListener{[weak self] (querySnapshot, error) in
            if error != nil{
                print("there's an error PostViewModel.swift")
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "" )")
                return
            }
//            if querySnapshot!.isEmpty{
//            }
            if let querySnapshot =  querySnapshot   {
                self?.buildNotifications(querySnapshot: querySnapshot)
            }
            let docRef = Firestore.firestore().collection("Notifications").document(userId.nonEmpty).collection("OldNotifications").order(by: "createdAt", descending: true).limit(to: 69)
          self?.listener =  docRef.addSnapshotListener{[weak self] (querySnapshot, error) in
                if error != nil{
                    print("error = \(error)")
                    return
                }
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "" )")
                    return
                }
//                if querySnapshot!.isEmpty{
//                }
                if let querySnapshot = querySnapshot{
                    self?.buildOldNotifcations(querySnapshot: querySnapshot)
                }
            }
        }
    }
    
    func fetchPost(postID: String, friendId: String?, callback: @escaping ((PostModel?, String?) -> Void)){
        print("friendId = ",friendId)
        if let friendId =  friendId {
            //Unfortunately, this post is locked
            PostModel.fetchPostFromCacheOrNetwork(postID: postID, friendId:  friendId){ post,error in
                callback(post,error?.localizedDescription)
            }
        }else{
            callback(nil,nil)
        }
    }
    
    func readNotification(){
        if notifications.isNotEmpty {
            ReadNotificationFunction.readNotification(notificationInformation: cloudNotifications)
        }
    }
    var listener: ListenerRegistration?
    deinit {
        listener?.remove()
        listener2?.remove()
        listener3?.remove()
    }
    
}

