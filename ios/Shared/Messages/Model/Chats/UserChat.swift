//
//  UserChat.swift
//  speakEZ
//
//  Created by Ahmad naeem on 7/14/21.
//
   
import FirebaseFirestoreSwift

struct UserChat : Hashable { 
    private (set) var chatId : String
       var haveFailedMessages : Bool = false
//    private (set) var ongoingMessage : [MessageModel] = []
//    mutating func removeOngoingMessage(_ message : MessageModel) {
//        if let index = ongoingMessage.firstIndex(where: {$0.id == message.id}){
//            ongoingMessage.remove(at: index)
//        }
//    }
//    mutating func addOngoingMessage(_ message : MessageModel){
//        ongoingMessage.append(message)
//    }
    
//    var haveOngoingMessages : Bool {
//        ongoingMessage.count > 0
//    }
}
