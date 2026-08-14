//
//  GroupMessage.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/17/21.
//
import SwiftUI

   struct GroupMessage : View {
       let chatModel: ChatModel
       @Environment(\.colorScheme) var colorScheme
       @Binding var groupChatInfo : [String : UserChat]
       var haveOngoingMessages : Bool { groupChatInfo[chatModel.id]?.haveFailedMessages ?? false }
       @State var isFromAllMessages = false
       @StateObject var people : TypingIndicatorOO
       @ObservedObject var themeController: ThemeController
       var body: some View {
           HStack(spacing: 10) {
               HStack {  
                   ZStack {
                       GroupProfileImage(chatModel: chatModel, themeController: themeController)
                           .padding(.vertical, 5)
                       
                       Rectangle()
                           .frame(width: 2, height: 40)
                           .foregroundColor(chatModel.lastMessage?.sentBy == currentUserID ? themeController.theme.accent : Color.mainColorInverse.opacity(0.8))
                           .offset(x: -35, y: 0)
                   }
                   if people.openedConversation.isNotEmpty {
                       TypingIndicatorController(people: people, isFromAllMessages: isFromAllMessages, currentView: .OpenedConversation, themeController: themeController)

                   } else {

                   VStack(alignment: .leading, spacing: 12){
                       Text(chatModel.groupName)
                           .font(.headline)
                      
                       if let lastMessage = haveOngoingMessages ? "Sending..." : chatModel.lastMessage?.message.condensed {
                            
                           if lastMessage.isEmpty, let message = chatModel.lastMessage {
                               ///remove it after final testing
                               HStack(spacing:3) {
                                   if message.photoLink != nil {
                                       Image(systemName: "photo")
                                           .font(.caption)
                                   }else if message.videoUrl != nil {
                                       Image(systemName: "video.fill")
                                           .font(.caption)
                                   }
                               }
                               .padding(.top, -10)
                           }else if chatModel.lastMessage?.isGIF == true {
                               Text("GIF")
                                   .font(.caption)
                                   .padding(.top, -10)
                           } else {
                               Text(lastMessage)
                                   .font(.caption)
                                   .padding(.top, -10)
                                   .lineLimit(1)
                                   .multilineTextAlignment(.leading)
                           }
                       }else{
                           Text("")
                               .font(.headline)
                               .padding(.top, -10)
                               .lineLimit(1)
                               .multilineTextAlignment(.leading)
                       }
                   }.foregroundColor(Color.black)
               }
                       Spacer(minLength: 0)
                      chatModel.lastMessage.map({ message in
                       VStack {
                           Text(message.timeString) // if message was sent yesterday, should say yesterday
                               .font(.caption)
                               .padding(.top, 12)
                               .foregroundColor(Color.black.opacity(0.5))
                           Spacer()
                       }
                   })
               }
           }
           .padding(.horizontal)
       }
     
   }
