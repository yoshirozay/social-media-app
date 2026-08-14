//
//  IndividualMessage.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 12/2/21.
//


import SwiftUI
import Combine
import SDWebImageSwiftUI

struct IndividualMessageCacheImageView : View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var cacheImage : CacheImage
    var diameter : CGFloat = 55
    var body: some View {
        ZStack {
            Image(uiImage: cacheImage.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: diameter, height: diameter)
                .background(Color.softWhite)
                .clipShape(Circle())
        }
    }
}
 
struct IndividualMessage: View {
    @State var message: MessageModel
    @Binding var userChatInfo : [String : UserChat]
    @Environment(\.colorScheme) var colorScheme
    var friend: Person
    var haveOngoingMessages : Bool {
//        message.status == .sending
//        userChatInfo[message.otherUserID]?.haveOngoingMessages ?? false
        userChatInfo[message.otherUserID]?.haveFailedMessages ?? false
    }
    @State var isFromAllMessages = false
    @StateObject var people : TypingIndicatorOO
    @ObservedObject var themeController: ThemeController
    var body: some View {
        HStack(spacing: 12) {
            
            ZStack {
                let cacheImage = CacheImage(photoURL: friend.profilePicLink, lightOrDark: Color.softWhite)
                IndividualMessageCacheImageView(cacheImage: cacheImage)
                
                Rectangle()
                    .frame(width: 2, height: 40)
                    .foregroundColor(message.sentBy == currentUserID ? themeController.theme.accent : Color.mainColorInverse.opacity(0.8))
                    .offset(x: -35, y: 0)
            }
            if people.openedConversation.isNotEmpty {
                TypingIndicatorController(people: people, isFromAllMessages: isFromAllMessages, currentView: .OpenedConversation, themeController: themeController)

            } else {
            VStack(alignment: .leading, spacing: 12) {
                Text(friend.name)
                    .font(.headline)
                let lastMessage = haveOngoingMessages ? "Sending..." : message.message.condensed
                if lastMessage.isEmpty {
                    ///remove it after final testing
                    HStack(spacing:3) {
                        if message.photoLink != nil {
                            Image(systemName: "photo")
                                .font(.caption)
                        }else if message.videoUrl != nil {
                            Image(systemName: "video")
                                .font(.caption)
                        } else if message.audioUrl != nil {
                            Image(systemName: "waveform")
                                .font(.caption)
                        }
                    }
                    .padding(.top, -10)
                }else if message.isGIF == true {
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
            } // VTACK
           .foregroundColor(Color.black)
            }
            Spacer(minLength: 0)
            VStack {
                Text(message.timeString) // if message was sent yesterday, should say yesterday
                    .font(.caption2)
                    .padding(.top, 12)
                    .foregroundColor(Color.black.opacity(0.5))
                Spacer()
            } // VSTACK
        }
    }
}

