////
////  OSAllMessages.swift
////  speakEZ crossplatform (macOS)
////
////  Created by Carson O'Sullivan on 2/1/21.
////
//
import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth
struct OSAllMessages: View {
    @Namespace var namespace
    @State var OSOpenedChatMatchedGeometry = ""
    @State var OSNewConversationMatchedGeometry = ""
    @State var OSOpenedChatSelectedItem = 10
    @State var photo = ""
    @State var name = ""
    @StateObject var messages : AllMessagesOO
    var body: some View {
        ZStack {
            Color.mainColorInverse.opacity(0.3)
                .ignoresSafeArea(.all)
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ForEach(Array(messages.messageInfo.sorted(by: {$0.timeString > $1.timeString})), id: \.self) { item in
                        OSIndividualMessage(messages: item, id: item.otherUserID, lastMessage: item.sentBy)
                            .matchedGeometryEffect(id: UUID(), in: namespace, isSource: false)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    OSOpenedChatMatchedGeometry = item.otherUserID
                                }
                            }

                    }
                }
                .padding(.trailing, screenWidth/179.2) // 10
            }
            .blur(radius: OSNewConversationMatchedGeometry == "" ? 0 : 3)
            Spacer()
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    if OSNewConversationMatchedGeometry != "" {
                        OSNewConversationSearchBar(OSOpenedChatMatchedGeometry: $OSOpenedChatMatchedGeometry)
                    }
                OSHeaderButton(image: "plus") {
                    if OSNewConversationMatchedGeometry == "" {
                    OSNewConversationMatchedGeometry = "0"
                    } else {
                        OSNewConversationMatchedGeometry = ""
                    }
                }
                .foregroundColor(Color.purple.opacity(0.7))
                .frame(width: 56, height: 27)
                }
            }
            .padding(.bottom, 35)
            .padding(.horizontal, 6)
        }
        .opacity(OSOpenedChatMatchedGeometry == "" ? 1 : 0)

            if OSOpenedChatMatchedGeometry != "" {
                OSOpenedConversation(OSOpenedChatMatchedGeometry: $OSOpenedChatMatchedGeometry,
                                     allMessages: OpenedConversationOO(otherUserID: OSOpenedChatMatchedGeometry),
                                     id2: OSOpenedChatMatchedGeometry,
                                     OSNewConversationMatchedGeometry: $OSNewConversationMatchedGeometry)
            }
        }
        .padding(.trailing, -screenWidth/179.2) // -10

    }
}
struct OSIndividualMessage: View {
    @State var messages: MessageModel
    @State var id: String
    @State var lastMessage: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    var body: some View {

        VStack {
            HStack(spacing: 12) {
                ZStack {
                    WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())

                    Rectangle()
                        .frame(width: 1, height: 30)
                        .foregroundColor(lastMessage == Auth.auth().currentUser?.uid ? Color.purple.opacity(0.3) : Color.mainColor.opacity(0.3))
                        .offset(x: -25, y: 0)
                }
                HStack (alignment: .top){
                    VStack(alignment: .leading, spacing: 12) {
                        Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                            .font(.headline)
                        Text(messages.message)
                            .font(.caption)
                            .padding(.top, -10)
                    } // VTACK
                    Spacer()
                    Text(messages.timeString)
                        .font(.caption)
                        .padding(.horizontal, 16)
                }
                .foregroundColor(.mainColor)
            } .padding(.leading)
            Divider()
        }
    }
}
//

//
struct OSNewConversationSearchBar: View {
    @Namespace var namespace
    @Binding var OSOpenedChatMatchedGeometry: String
    @State var text = ""
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    var body: some View {
        HStack(spacing: 15) {

            TextField("New Conversation", text: self.$text)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if self.text != "" {
                   Image(systemName: "clear")
                        .font(.headline)
                    .foregroundColor(.mainColor)
                    .opacity(0.2)
                    .onTapGesture {
                        self.text = ""
                    }

            }
        }// HSTACK
        .animation(.spring())
        ForEach(friendsDictionary.friendsDictionary.values.filter{$0.name.lowercased().contains(self.text.lowercased())}) { item in
            OSNewConversationResults(id: item.id)
                .matchedGeometryEffect(id: UUID(), in: namespace, isSource: false)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.3)) {
                    OSOpenedChatMatchedGeometry = item.id

                    }
                }
        }
    }
}
//
struct OSNewConversationResults: View {
    @State var id: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    var body: some View {
        VStack{
        HStack (spacing: 12) {
          WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 35, height: 35)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 12) {
                Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                    .font(.headline)
                Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                    .font(.caption)
                    .padding(.top, -10)
            } // VSTACK
            .foregroundColor(.mainColor)
            Spacer()
        } // HSTACK
            Divider()
        }
    }
}
