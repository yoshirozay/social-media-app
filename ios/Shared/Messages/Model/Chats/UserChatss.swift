//
//  UserChatss.swift
//  speakEZ
//
//  Created by Ahmad naeem on 8/15/21.
//
 
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct ChatGroup : Decodable {
    var groupChat : Bool
    var users : [String]
    var usersWhoLeft : [String]? = nil
    var name : String
}
/*
 UserChatss is a collection of docs. each doc represent a chat between users
 */
struct UserChatss : Decodable {
    let documentId : String
    let newMessage : Bool
    let user : String
    let time : Date
    var type: DocumentChangeType = .added
    var chatGroup : ChatGroup? = nil
    var isGroupChat : Bool{
        chatGroup?.groupChat == true
    }
    
    enum CodingKeys: String, CodingKey {
        case newMessage
        case user
        case time
    }
    static var dateFormatter : DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        return format
    }() 
   //2020-12-29 03:36:08 +0000
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        newMessage = try container.decodeIfPresent(Bool.self, forKey: .newMessage) ?? false
        if let chatGroup = try? ChatGroup(from: decoder){
            self.chatGroup = chatGroup
            self.user = ""
        }else{
            user = try container.decode(String.self, forKey: .user)
        }
   
        documentId = try FirestoreDocumentID(from: decoder).documentId
        
   
        if let time = try? container.decode(String.self, forKey: .time),
               let datetime = Self.dateFormatter.date(from: time) {
            self.time = datetime
//         print("datetime string", self.time)
        }else if let timestamp = try? container.decode(Timestamp.self, forKey: .time){
            self.time = timestamp.dateValue()
//            print("datetime timestamp",self.time)
        }else{
            
            throw NSError.getWith(description: "was not able to parse time")
        }
//        do {
//         let chatGroup = try ChatGroup(from: decoder)
//            self.chatGroup = chatGroup
//
//        }catch let error{
//            print("error \(error.localizedDescription)")
//        }
    }
    
    static func doesUserChatssExist(chatUID : String,userId : String,callback : @escaping (_ success : Bool,  _  error : Error?) -> Void){
        getUserChatsRef(currentUserId: userId)
            .document(chatUID.nonEmpty)
            .getDocument(source: .server){docSnapshot,error in
                callback(docSnapshot?.exists == true,error)
        }
    }
    
    static func getUserChatsQuery(currentUserId: String, otherUserID: String) ->  Query{
      getUserChatsRef(currentUserId: currentUserId).whereField(CodingKeys.user(), isEqualTo: otherUserID)
    }
    
    static func getUserChatsRef(currentUserId : String) -> CollectionReference{
        Firestore.firestore()
            .collection(Constant.UserChats())
            .document(currentUserId.nonEmpty)
            .collection(Constant.UserChatss())
    }
    
    static func getUserChatsQuery(currentUserId : String) -> Query{
        getUserChatsRef(currentUserId : currentUserId)
            .order(by: Constant.time(), descending: false)
    }
    
    
    static func decodeChatsFrom(chatsDocChange : [DocumentChange]) -> (userChats: [UserChatss], userChatGroups: [UserChatss]) {
        var userChatGroups: [UserChatss] =  []
        var userChats: [UserChatss] = []
        chatsDocChange.forEach { docChange in
            do{
                if var userChat = try docChange.document.data(as: UserChatss.self) {
                      userChat.type = docChange.type
                     if userChat.isGroupChat {
                        userChatGroups.append(userChat)
                    }else{
                        userChats.append(userChat)
                    }
                }else{
                    print(" Error doc.data(as: UserChatss.self) ")
                }
            }catch let error{
                print("doc.data(as: UserChatss.self) \(error.localizedDescription)")
            }
        }
        return (userChats: userChats.uniqueSorted, userChatGroups: userChatGroups)
    }
 
    static func decodeChatsFrom(chatsDoc : [QueryDocumentSnapshot]) -> (userChats: [UserChatss], userChatGroups: [UserChatss]) {
        var userChatGroups: [UserChatss] =  []
        var userChats: [UserChatss] = []
        chatsDoc.forEach { doc in
            do{
                if let userChat = try doc.data(as: UserChatss.self) {
                     if userChat.isGroupChat {
                        userChatGroups.append(userChat)
                    }else{
                        userChats.append(userChat)
                    }
                }else{
                    print(" Error doc.data(as: UserChatss.self) ")
                }
            }catch let error{
                print("doc.data(as: UserChatss.self) \(error.localizedDescription)")
            }
        }
        return (userChats: userChats.uniqueSorted, userChatGroups: userChatGroups)
    }
    
    enum Constant : String {
        case UserChats
        case UserChatss
        case time
        
    }
    
}
//need to update it for group chat
extension Array where Element == UserChatss{
    ///will remove older duplicate UserChatss
    var uniqueSorted : [UserChatss] {
        guard self.count > 1 else { return self }
        let userChatss = self.sorted() { $0.user > $1.user  }
        var uniqueUserChatss = [UserChatss]()
        var temp2 : UserChatss = userChatss.first!
        
        for i in 1...userChatss.count-1{
            if temp2.user == userChatss[i].user{
                if  temp2.time > userChatss[i].time{
                    temp2 = userChatss[i]
                }
            }else{
                  uniqueUserChatss.append(temp2)
                temp2 =  userChatss[i]
            }
        }
        
        let lastChat = userChatss.last!
        if temp2.user == lastChat.user {
                uniqueUserChatss.append(temp2)
        }else{
            uniqueUserChatss.append(lastChat)
        }
        return uniqueUserChatss
    }
}

/*
 so we will not use allMessages but instead a allChats array that will hold chat object with all property above mentioned. it will interact for single chat with OpenedConversation just like before. we will also get Friend and non Friend group chat users  and add them in the relevant chat object. to fetch non friend users we will use cache then network and for friend we will get them from friendDictionary
 
 For AllMessages we need to know:
 1. chatUID
 2. isAGroupChat
 3. var members : [Person]
 4. lastMessageSent
 5. timestamp
 + whatever else is required to create "IndividualMessage"
 I'm sure I am missing some
 */

 
