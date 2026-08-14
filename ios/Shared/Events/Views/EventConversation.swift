//
//  EventConversation.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 8/4/22.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct EventConversationController: View {
    @ObservedObject var eventModel: EventModelOO
    @ObservedObject var functions: EventFunctions
    @ObservedObject var individualEvent: IndividualEventOO
    @State var event: EventModel
    @ObservedObject var friendsDictionary: FriendsDictionary
    @Binding var OpenedEventMatchedGeometry: String
    @Binding var EditEventMatchedGeometry: String
    @ObservedObject var themeController: ThemeController
    var body: some View {
        EventConversation(eventModel: eventModel, functions: functions, individualEvent: individualEvent, event: event, friendsDictionary: friendsDictionary, messages: IndividualEventConversationOO(eventID: event.id, conversationID: individualEvent.eventConversationID), OpenedEventMatchedGeometry: $OpenedEventMatchedGeometry, EditEventMatchedGeometry: $EditEventMatchedGeometry, themeController: themeController)
    }
}

struct EventConversation: View {
    @ObservedObject var eventModel: EventModelOO
    @ObservedObject var functions: EventFunctions
    @ObservedObject var individualEvent: IndividualEventOO
    @State var event: EventModel
    @ObservedObject var friendsDictionary: FriendsDictionary
    @StateObject var messages = IndividualEventConversationOO(eventID: "", conversationID: "")
    @State var selectedMedia : SelectedMedia?
    @State var message = ""
    @StateObject var soundManager = SoundManager()
    @State var gifURL: String = ""
    @StateObject var keyboard = KeyboardViewModel(showDismissAnimation: false)
    @State var OpenedPhotoSelectedItem: URL?
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var OpenedGIFMatchedGeometry: String = ""
    @State var CommentLikesMatchedGeometry: String = ""
    @State var message2 = EventMessageModel(id: "", time: Timestamp(), message: "", timeString: "", messageID: "", isGIF: false)
    @Binding var OpenedEventMatchedGeometry: String
    @State var FriendProfileMatchedGeometry = ""
    @State var StrangerProfileSelectedUser = Person(id: "")
    @Binding var EditEventMatchedGeometry: String
    @ObservedObject var themeController: ThemeController
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            Color.mainColorInverse
                .edgesIgnoringSafeArea(.all)
//            Color.softWhite
//            .edgesIgnoringSafeArea(.all)
            VStack {
                OpenedEventHeader(eventModel: eventModel, functions: functions, individualEvent: individualEvent, friendsDictionary: friendsDictionary, event: event, isFromConversation: false, EditEventMatchedGeometry: $EditEventMatchedGeometry, NavigationMatchedGeomtry: $OpenedEventMatchedGeometry, themeController: themeController)
                Spacer()
                ZStack (alignment: .topLeading) {
                    themeController.theme.messageList
                        .edgesIgnoringSafeArea(.all)
                    ConversationMessages(messages: messages, OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry, conversationID: individualEvent.eventConversationID, eventID: event.id, functions: functions, message2: $message2, CommentLikesMatchedGeometry: $CommentLikesMatchedGeometry, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, StrangerProfileSelectedUser: $StrangerProfileSelectedUser)
                }
                .padding(.top, 11)
                .padding(.top, iOS15 ? 0 : 48)
                ZStack (alignment: .bottom) {
                    VStack() {
                        ConversationAudioView(selectedMedia: $selectedMedia, soundManager: soundManager)
                        ConversationMediaView(selectedMedia: $selectedMedia)
                        ConversationTextField(selectedMedia: $selectedMedia, message: $message, soundManager: soundManager, gifURL: $gifURL, keyboard: keyboard, placeHolderText: "Message", friendsDictionary: friendsDictionary, functions: functions, event: event, conversationID: individualEvent.eventConversationID, individualEventConversation: messages, attendingFriendTokens: individualEvent.attendingFriendTokens)
                    }

                    HStack {
                        Spacer()
                        if selectedMedia?.newMedia == nil {
                            RecordNewAudioView(soundManager: soundManager, selectedMedia: $selectedMedia, isFromMessages: false, audioCommentAlert: .constant(false), buttonAlertType: .constant(.none), themeController: themeController)
                            .offset(x: message != "" || selectedMedia != nil ? 14 : 0)
                            .padding(.trailing, 3)
                        }
                        if selectedMedia?.audioUrl == nil && !soundManager.isRecording {
                            ConversationGifButton(gifURL: $gifURL)
                            .offset(x: message != "" || selectedMedia?.image != nil ? 14 : 0)
                        ConversationSendPhotoButton(selectedMedia: $selectedMedia, message: $message)
                            .offset(x: message != "" || selectedMedia?.image != nil ? 14 : 0)
                        }
                    }
                    .padding(.bottom, keyboard.bottomPadding)
                    .offset(x: -16, y: -120 + keyboard.value)
                    .offset(y: iOS15 ? 0 : -screenHeight/13.5)
                    .offset(y: keyboard.value > 0 ? -keyboard.value : 0)
                    .offset(y: -30)
                }
            }
            .padding(.top, iOS15 ? 0 : 16)
            if OpenedPhotoMatchedGeometry != "" {
                OpenPhotoTabView(OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, photo: OpenedPhotoSelectedItem, isFromTimeline: true)
  
            }
            if OpenedGIFMatchedGeometry != "" {
                 OpenedGIFTabView(OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry)
            }
            if CommentLikesMatchedGeometry != "" {
                EventMessageLikesTabView(LikesMatchedGeometry: $CommentLikesMatchedGeometry, likes: EventMessageLikesOO(id: message2.id, eventID: event.id, conversationID: individualEvent.eventConversationID, messageID: message2.messageID) , individualConversation: messages, message: message2, friendsDictionary: friendsDictionary)
            }
            if FriendProfileMatchedGeometry != "" {
                if friendsDictionary.friendsDictionary[FriendProfileMatchedGeometry] != nil {
                    if FriendProfileMatchedGeometry != currentUserID {
                    FriendProfileHomeTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry, isFromOpenedPost: false, themeController: themeController)
                    } else {
                        CurrentUserProfileTabView(ProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: currentUserID ?? "",  signOut: .constant(false), friendsDictionary: friendsDictionary)
                    }
                } else {
                    StrangerProfileTabView(ProfileMatchedGeometry: $FriendProfileMatchedGeometry, person: StrangerProfileSelectedUser , id: FriendProfileMatchedGeometry)
                }
            }
        }
    }
}


struct ConversationTextField: View {
    @Binding var selectedMedia : SelectedMedia?
    @Binding var message: String
    @ObservedObject var soundManager: SoundManager
    @State var textViewMaxHeight: CGFloat = screenHeight*0.3 - 150
    @Binding var gifURL: String
    @ObservedObject var keyboard: KeyboardViewModel
    @State var placeHolderText: String
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var functions: EventFunctions
    @State var event: EventModel
    @State var conversationID: String
    @ObservedObject var individualEventConversation: IndividualEventConversationOO
    @State var attendingFriendTokens: [String]
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
//            if selectedMedia == nil{
//            Rectangle()
//                   .frame(width: screenWidth, height: 1)
//                   .foregroundColor(Color.mainColorInverse)
//            }
            ZStack {
             
                HStack(alignment: .bottom, spacing: 0) {
                HStack(spacing: 15) {
                    ZStack {
                    HStack  {
                        ZStack {
                            if message.isEmpty {

                                TextField(placeHolderText, text : $message)
                                    .foregroundColor(Color.gray)
                                    .padding(.leading,12)
                                    .animation(.none)
                                    .opacity(soundManager.isRecording ? 0 : 1)
                            }
                        ExpandingTextView(text: $message, maxHeight: $textViewMaxHeight, isFirstResponder: false )
                            .background(Color.clear)
                            .opacity(soundManager.isRecording ? 0 : 1)
                        .padding(.leading, 8)
                        .padding(.vertical, 10)
                    }
                    .background(Color.mainColorInverse.opacity(0.6))
                    }
                        if soundManager.isRecording {
                            Audio(soundManager: soundManager)
                                    .frame(width: screenWidth - 21, height: 58)
                                    .background(Color.mainColorInverse.opacity(0.6))
                        }
                }
                } // HSTACK
                .clipShape(ChatBubbleShape(direction: .right))
                .padding(.trailing, 16)
                .padding(.leading, 5)

                    if  soundManager.isRecording == false, message.isNotEmpty || selectedMedia != nil  {

                        Button(action: {
                            let currentUserID = Auth.auth().currentUser?.uid ?? ""
                            
                            let messageID = UUID().uuidString
                            

                            functions.sendEventMessage(eventID: event.id, selectedMedia: selectedMedia, message: message, nameOfCurrentUser: friendsDictionary.friendsDictionary[currentUserID]?.name ?? "", eventConversationID: conversationID, isGIF: false, messageID: messageID, eventName: event.eventName, attendingFriendTokens: attendingFriendTokens)
                            
                            individualEventConversation.buildDummyMessage(EventMessageModel(id: currentUserID, time: Timestamp(), message: message, timeString: "Now", messageID: messageID, status: .sending, isGIF: false, tempImage: selectedMedia?.image))
                            message = ""
                            selectedMedia = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                hideKeyboard()

                            }
                        }){
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color.mainColor)
                            // Rotating paperplane
                            .rotationEffect(.init(degrees: 45))
                            // Padding Shape
                            .padding(.vertical, 10)
                            .padding(.leading, 12)
                            .padding(.trailing, 17)
                            .background(Color.mainColorInverse.opacity(0.6))
                            .clipShape(Circle())
                    } // BUTTON
                    .padding(.leading, -18)
                }
            } // HSTACK
            .ignoresSafeArea(.keyboard)
            .padding(.bottom,  keyboard.bottomPadding )
            }
            .padding(.top, 15)
            .padding(.bottom, iOS15 ? 0 : 60)
//            .padding(.bottom, keyboard.value > 0 ? 0 : 60)
            .background(colorScheme == .light ? Color.backgroundColor.ignoresSafeArea(.all) : Color.accent.ignoresSafeArea(.all))
              
        }
        .onChange(of: gifURL, perform: { value in
            let currentUserID = Auth.auth().currentUser?.uid ?? ""
            let messageID = UUID().uuidString

            functions.sendEventMessage(eventID: event.id, selectedMedia: selectedMedia, message: gifURL, nameOfCurrentUser: friendsDictionary.friendsDictionary[currentUserID]?.name ?? "", eventConversationID: conversationID, isGIF: true, messageID: messageID, eventName: event.eventName, attendingFriendTokens: attendingFriendTokens)
        })
    }
}

struct ConversationMediaView: View {
    @Binding var selectedMedia : SelectedMedia?
    var body: some View {
        (selectedMedia?.image).map  { image in
            HStack {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 105, height: 120)
                        .shadow(radius: 5, x: 0, y: -1)
                        .shadow(radius: 5, x: 0, y: 1)
                        .clipShape(Rectangle())
                        .cornerRadius(10)
                        .padding(.leading)
                    Button(action: {
                        selectedMedia?.deleteCacheOfSelectedMediaIfAny()
                        selectedMedia = nil
                    }) {
                        Image(systemName: "clear")
                            .foregroundColor(Color.speakerPink.opacity(1))
                    }  .buttonStyle(.borderless)
                        .padding(.leading, 95)
                        .padding(.bottom, 95)
                }
                Spacer()
            }
            .frame(height: 125)
            .background(Color.speakerPurple.opacity(0.1))
        }
    }
}

struct ConversationAudioView: View {
    @Binding var selectedMedia : SelectedMedia?
    @StateObject var audioPlayerVM = RecordedAudioPlayerVM()
    @ObservedObject var soundManager: SoundManager
    var body: some View {
        selectedMedia?.audioUrl.map {_ in
        HStack {
            ZStack {
                Rectangle()
                    .frame(width: 105, height: 120)
                    .foregroundColor(Color.mainColorInverse.opacity(0.4))
                    .clipShape(Rectangle())
                    .cornerRadius(10)
                Button(action: {
                    audioPlayerVM.playRecordingIfNotPlaying(audioUrl: selectedMedia?.audioUrl)
                }){
                    ZStack {
                        if audioPlayerVM.playRecording {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color.backgroundColor)
                                AnimatedWaveformView(color: Color.white, renderingMode: .hierarchical, animated: true, doesHaveOutterRing: false)
                                .frame(width: 60, height: 60)
                                .scaledToFit()
                            }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color.backgroundColor)
                                AnimatedWaveformView(color: Color.white, renderingMode: .hierarchical, animated: false, doesHaveOutterRing: false)
                                .frame(width: 60, height: 60)
                                .scaledToFit()
                            }
                        }
                    }
                }.disabled(soundManager.isRecording)
                Button(action: {
                    withAnimation {
                    audioPlayerVM.stopAndDelete(audioDirURL:  selectedMedia?.audioUrl)
                    selectedMedia = nil
                    }
                }) {
                    Image(systemName: "clear")
                        .foregroundColor(Color.speakerPurple.opacity(1))
                }  .buttonStyle(.borderless)
                    .padding(.leading, 90)
                    .padding(.bottom, 100)
            }
            .padding(.leading)
            Spacer()
        }
        .frame(height: 125)
        .background(Color.speakerPurple.opacity(0.1))
        .onAppear() {
            audioPlayerVM.playRecordingIfNotPlaying(audioUrl: selectedMedia?.audioUrl)
        }
        }
    }
}

struct ConversationGifButton: View {
    @State var isShowingGIFkeyboard: Bool = false
    @Binding var gifURL: String
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Image(colorScheme == .light ? "gifSticker" : "gifStickerWhite")
            .resizable()
            .frame(width: 30, height: 30)
          .foregroundColor(Color.mainColor)
            .padding(.vertical, 9)
            .padding(.leading, 9)
            .padding(.trailing, 9)
            .background(colorScheme == .light ? Color.mainColorInverse.opacity(0.2) : Color.mainColorInverse.opacity(0.6))
            .clipShape(Circle())
            .onTapGesture {
                isShowingGIFkeyboard = true
            }
            .popover(isPresented: $isShowingGIFkeyboard, content: {
                GIFController(url: $gifURL, present: $isShowingGIFkeyboard)
                    .offset(y: 35)
            })
    }
}

struct ConversationSendPhotoButton: View {
    @State var ShowPhotoImagePicker: Bool = false
    @Binding var selectedMedia : SelectedMedia?
    @Binding var message: String
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            Image(systemName: "photo")
                .font(.system(size: 22))
              .foregroundColor(Color.mainColor)
                .padding(.vertical, 12)
                .padding(.leading, 12)
                .padding(.trailing, 12)
                .background(colorScheme == .light ? Color.mainColorInverse.opacity(0.2) : Color.mainColorInverse.opacity(0.6))
                .clipShape(Circle())
                .onTapGesture {
                    ShowPhotoImagePicker = true
                }
                .presentMediaPicker(isPresented: $ShowPhotoImagePicker, selectedMedia: $selectedMedia,text: $message, parentView: .message)
        }
    }
}

struct ConversationMessages: View {
    @ObservedObject var messages: IndividualEventConversationOO
    @Binding var OpenedPhotoSelectedItem: URL?
    @Binding var OpenedPhotoMatchedGeometry: String
    @Binding var OpenedGIFMatchedGeometry: String
    @State var list: UITableView?
    @State var conversationID: String
    @State var eventID: String
    @ObservedObject var functions: EventFunctions
    @Binding var message2: EventMessageModel
    @Binding var CommentLikesMatchedGeometry: String
    @Binding var FriendProfileMatchedGeometry: String
    @Binding var StrangerProfileSelectedUser: Person
    var body: some View {
        VStack {
        List() {
            ForEach(messages.sortedMessages.reversed(), id: \.self) { item in
                ConversationMessage(individualEvent: messages, userID: item.id, message: item, OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry, conversationID: conversationID, eventID: eventID, functions: functions, messageLikes: EventMessageLikesOO(id: item.id, eventID: eventID, conversationID: conversationID, messageID: item.messageID), message2: $message2, CommentLikesMatchedGeometry: $CommentLikesMatchedGeometry, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, StrangerProfileSelectedUser: $StrangerProfileSelectedUser)
                    .id(item.messageID)
                    .listRowInsets(EdgeInsets(top: -20, leading: 15, bottom: 0, trailing: 0))
                    .scaleEffect(x: 1, y: -1, anchor: .center)
            }
            .padding(.top, 30)
            .padding(.leading, -10)
        }
        .padding(.leading,-15)
        .scaleEffect(x: 1, y: -1, anchor: .center)
        .listStyle(SidebarListStyle())
        .introspectTableView(customize: { list in
            if self.list == nil {
                self.list = list
#if os(iOS)
                list.allowsSelection = false
                list.selectionFollowsFocus = false
                list.keyboardDismissMode = .interactive
#endif
            }
        })
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if  messages.sortedMessages.isNotEmpty == true {
                    self.list?.scrollToBottom()
                }
            }
        }
        .onChange(of: messages.goToBottom) { (value) in
                DispatchQueue.main.async {
                if  messages.sortedMessages.isNotEmpty == true {
                    self.list?.scrollToBottom()
                }
            }
        }
    }
    }
}
struct ConversationMessage: View {
    @ObservedObject var individualEvent: IndividualEventConversationOO
    @State var userID: String
    @State var message: EventMessageModel
    @Binding var OpenedPhotoSelectedItem: URL?
    @Binding var OpenedPhotoMatchedGeometry: String
    @Binding var OpenedGIFMatchedGeometry: String
    @State var conversationID: String
    @State var eventID: String
    @ObservedObject var functions: EventFunctions
    @StateObject var messageLikes = EventMessageLikesOO(id: "", eventID: "", conversationID: "", messageID: "")
    @State var bottomPadding: Double = 0
    @Binding var message2: EventMessageModel
    @Binding var CommentLikesMatchedGeometry: String
    @Binding var FriendProfileMatchedGeometry: String
    @Binding var StrangerProfileSelectedUser: Person
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack (alignment: .bottomLeading) {
        VStack {
        ZStack (alignment: .leading) {
            Color.softWhite

        VStack (alignment: .leading) {
        HStack {
            HStack {
                WebImage(url: individualEvent.personDict[userID]?.profilePicLink)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .scaledToFill()
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .onTapGesture {
                        FriendProfileMatchedGeometry = userID
                        StrangerProfileSelectedUser = individualEvent.personDict[userID] ?? Person(id: "")
                    }
                Text (individualEvent.personDict[userID]?.name ?? "")
                    .font(.headline)
                    .foregroundColor(Color.mainColor)
            }
          
            Spacer()
            Text(message.timeString)
                .font(.caption2)
                .foregroundColor(Color.mainColor.opacity(0.3))
                .offset(y: 3)
                .padding(.trailing, 16)
        }
        .padding(.leading, 5)
            if message.isGIF == true {
               gifView

            } else {
               Text(message.message)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.body)
                    .foregroundColor(Color.mainColor)
                    .padding(.leading, 10)
                    .multilineTextAlignment(.leading)
                    .offset(x: -3, y: -5)
                    .padding(.trailing, 10)
                    .padding(.bottom, message.photoLink != nil || message.thumbnailUrl != nil ? -4 : -2)
                mediaView
  
            }
        }
        .offset(x: 5, y: 2)
        }
        .clipShape(ChatBubbleShape(direction: .left))
    }
            likeCapsule
                .onTapGesture {
                    CommentLikesMatchedGeometry = "0"
                    message2 = message
                }
                .animation(Animation.linear.speed(0.6))
                .onChange(of: messageLikes.messageLikes.isEmpty) { isEmpty in
                    withAnimation(Animation.linear.speed(0.6)) {
                        bottomPadding = 15
                    }
                    if !isEmpty,bottomPadding == 0{
                        withAnimation(Animation.linear.speed(0.6)) {
                            bottomPadding = 15
                        }
                    }
                }
            
}
        .onCustomTapGesture(count : 2,perform: doubleTapped)
        .padding(.bottom, 0 + bottomPadding)
        .onAppear() {
            if messageLikes.messageLikes.isNotEmpty {
//                withAnimation(Animation.linear.speed(0.6)) {
                    bottomPadding = 15
//                }
            }
        }
//        .padding(.bottom, (message.photoLink != nil || message.thumbnailUrl != nil || message.isGIF == true) && messageLikes.messageLikes.isNotEmpty ? 15 : 0)
    }
    var gifView: some View {
        HStack{
            ZStack(alignment: .center) {
                    AnimatedImage(url: URL(string: message.message))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .onCustomTapGesture(count : 2, perform: doubleTapped)
                        .onCustomTapGesture {
                            OpenedGIFMatchedGeometry = message.message
                            hideKeyboard()
                        }
            }
            .frame(width: screenHeight/5, height: screenHeight/5)
            .background(Color.mainColor.opacity(0.1))
            .clipShape(ChatBubbleShape(direction: .left))
            if let _ = message.tempImage{
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.speakerPurple))
                .padding(.leading,10)
        }
            Spacer()
        }
        .padding(.top, -6)
        .padding(.bottom, 8)
    }
    var mediaView : some View {
        ZStack{
            if let audioUrl = message.audioUrl{
                CacheAudioPlayer(audioUrl: audioUrl, isDummy: false, color: Color.white, backgroundColor: Color.mainColorInverse.opacity(0.2))
//                    .padding(.leading, 5)
                    .padding(.bottom, 10)
                    .padding(.top, message.message == "" ? -10 : -5)
            }else{
//                message.kind.map { _ in
                if message.photoLink != nil || message.thumbnailUrl != nil {
                    HStack{
                        ZStack(alignment: .center) {
                            if let photoURL = message.photoLink  {
                                WebImage(url: photoURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .onCustomTapGesture(count : 2,perform: doubleTapped)
                                    .onCustomTapGesture {
                                        OpenedPhotoSelectedItem = photoURL
                                        OpenedPhotoMatchedGeometry = "0"
                                        hideKeyboard()
                                    }
                            }
                            else if let image = message.tempImage {
                                ZStack{
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                    if message.videoUrl != nil {
                                        VideoPlayButtonView(size: 50)
                                    }
                                }
                            }
                            
                            if let videoUrl =  message.videoUrl,
                               let thumbnailUrl = message.thumbnailUrl {
                                ZStack(alignment: .center) {
                                    WebImage(url: thumbnailUrl)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .overlay( VideoThumbnailView(videoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl )
                                                                     , doubleTapAction : doubleTapped
                                                                    )
                                        )
                                }
                            }
                        }
                        .frame(width: screenHeight/5, height: screenHeight/5)
                        .background(Color.mainColor.opacity(0.1))
                        .clipShape(ChatBubbleShape(direction: .left))
                        if let _ = message.tempImage{
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.speakerPurple))
                                .padding(.leading,10)
                        }
//                        Spacer()
                    }
                    //            .padding([.bottom,.trailing])
                }
            }
        }
    }
    var likeCapsule: some View {
        ZStack {
            if messageLikes.messageLikes.count < 11 {
                if messageLikes.messageLikes.count != 0 {
                ZStack {
                    Capsule()
                        .frame(width: 32 + CGFloat((messageLikes.messageLikes.count * 17)), height: 24)
                        .foregroundColor(Color.mainColorInverse.opacity(1))
                    Capsule()
                        .frame(width: 30 + CGFloat((messageLikes.messageLikes.count * 17)), height: 22)
                    
                        .foregroundColor(Color.speakerPurple.opacity(0.18))
                        .overlay (
  
                            HStack (spacing: 1) {
                                Text("💜")
                                    .font(.caption2)
                                    .padding(.leading, 3)
                                ForEach(messageLikes.messageLikes, id: \.self) { item in
                                    ZStack {
                                        Circle()
                                            .frame(width: 17, height: 17)
                                            .foregroundColor(Color.white)
                                            .clipShape(Circle())
                                    WebImage(url: item.profilePicLink)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 16, height: 16)
                                        .clipShape(Circle())
                                    }
                                }
                                
                                Spacer()
                            }
                        )
                }
                .offset(x: 10, y: 17)
            }
            } else {
                ZStack {
                    Capsule()
                        .frame(width: 59 + CGFloat((messageLikes.firstTenLikes.count * 17)), height: 24)
                        .foregroundColor(Color.mainColorInverse.opacity(1))
                    Capsule()
                        .frame(width: 56 + CGFloat((messageLikes.firstTenLikes.count * 17)), height: 22)
                    
                        .foregroundColor(Color.speakerPurple.opacity(0.18))
                        .overlay (
                            HStack (spacing: 1) {
                                Text("💜")
                                    .font(.caption2)
                                    .padding(.leading, 3)
                                ForEach(messageLikes.firstTenLikes, id: \.self) { item in
                                    ZStack {
                                        Circle()
                                            .frame(width: 17, height: 17)
                                            .foregroundColor(Color.white)
                                            .clipShape(Circle())
                                    WebImage(url: item.profilePicLink)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 16, height: 16)
                                        .clipShape(Circle())
                                    }
                                }
                                ZStack {
                                    Circle()
                                        .frame(width: 17, height: 17)
                                        .foregroundColor(Color.mainColorInverse)
                                    Circle()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(Color.backgroundColor)
                                    Text("+\(messageLikes.messageLikes.count - 3)")
                                        .font(.footnote)
                                        .foregroundColor(Color.white)
                                }
                                Spacer()
                            }
                        )
                }
                .offset(x: 10, y: 17)
            }
        }
    }
    
    func doubleTapped(){
          print(" doubleTapped")
        functions.likeEventMessage(eventID: eventID, nameOfCurrentUser: "", conversationID: conversationID, messageID: message.messageID)

#if os(iOS)
            let impactLight = UIImpactFeedbackGenerator(style: .heavy)
            impactLight.impactOccurred()
#endif
        
    }
}

struct EventLikedComment: View {
    @State var message: EventMessageModel
    @ObservedObject var messages : IndividualEventConversationOO
    @Binding var OpenProfileMatchedGeometry: String
    var body: some View {
        ZStack (alignment: .bottomLeading) {
            ZStack (alignment: .leading) {
                Color.mainColorInverse.opacity(0.5)
                VStack (alignment: .leading) {
                    
                    HStack {
                        WebImage(url: messages.personDict[message.id]?.profilePicLink)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 35, height: 35)
                            .scaledToFill()
                            .clipShape(Circle())
                            .onTapGesture {
                                OpenProfileMatchedGeometry = message.id
                            }
                        Text (messages.personDict[message.id]?.name ?? "")
                            .font(.headline)
                            .foregroundColor(Color.mainColor)
                        //                        .rotationEffect(.degrees(180.0))
                        Spacer()
                        Text(message.timeString)
                            .font(.caption2)
                            .foregroundColor(Color.mainColor.opacity(0.3))
//                                                    .offset(y: 3)
                            .padding(.trailing, 16)
                    }
                    
                    .padding(.leading, 5)
                    
                    if message.isGIF ?? false {
                        gifView
                    } else {
                    Text(message.message)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(4)
                        .font(.title3)
                        .foregroundColor(Color.mainColor)
                        .padding(.leading, 10)
                        .multilineTextAlignment(.leading)
                        .offset(x: -3, y: -5)
                        .padding(.trailing, 5)
                        .padding(.bottom, 8)
                    }
                    
                }
                .offset(x: 5, y: 2)
                //            .offset(x: -10, y: -30)
            }
            .clipShape(ChatBubbleShape(direction: .left))

        }

    }
    var gifView: some View {
        HStack{
            ZStack(alignment: .center) {
                    AnimatedImage(url: URL(string: message.message))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
            }
            .frame(width: screenHeight/8, height: screenHeight/8)
            .background(Color.mainColor.opacity(0.1))
            .clipShape(ChatBubbleShape(direction: .left))
            Spacer()
        }
        .padding(.top, -6)
        .padding(.bottom, 8)
    }
}

struct EventMessageLikes: View {
    @Binding var LikesMatchedGeometry: String
    @ObservedObject var likes: EventMessageLikesOO
    @Environment(\.colorScheme) var colorScheme
    @State var OpenProfileMatchedGeometry: String = ""
    @ObservedObject var messages : IndividualEventConversationOO
    @State var message: EventMessageModel
    @State var StrangerProfileSelectedUser: Person?
    @ObservedObject var friendsDictionary: FriendsDictionary
    var body: some View {
    ZStack {
        Color.backgroundColor.edgesIgnoringSafeArea(.all)
        VStack  {
//            Spacer()
            EventLikedComment(message: message, messages: messages, OpenProfileMatchedGeometry: $OpenProfileMatchedGeometry)
                .frame(height: 100)
                .padding(.horizontal, 5)

            VStack {
                HStack {
                    Button(action: {
                        LikesMatchedGeometry = ""
                    }){
                        ZStack {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(Color.white)
                        }
                        .frame(width: 40, height: 40)

                    }
                    .padding(.leading, 5)
                    HStack {

                    Text("LIKES")
                        .font(.headline)
                      .foregroundColor(Color.mainColor)
                    }
                    .padding(.leading, 5)
                    Spacer()
                }

                Rectangle()
                    .frame(width: screenWidth, height: 2)
                    .foregroundColor(Color.white)
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(likes.messageLikes, id: \.self) { i in
                            HStack {
                                WebImage(url: i.profilePicLink)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(i.name)
                                        .font(.headline)
                                    Text(i.username)
                                        .font(.caption)
                                        .padding(.top, -10)
                                } // VSTACK
                                Spacer()
                            }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    OpenProfileMatchedGeometry = i.id
                                    StrangerProfileSelectedUser = i
                                }
                                .padding(.horizontal, 10)
                            Rectangle()
                                .foregroundColor(Color.white.opacity(0.7))
                                .frame(width: screenWidth / 1.05 , height: 1)
                            
                        }
                    }
                    .onAppear() {
                        print("MESSAGE LIKE COUNT = \(likes.messageLikes.count)")
                        print("MESSAGE LIKEs = \(likes.messageLikes)")
                    }
                }
            }
            .padding(.top, 20)
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.top, 20)
        .padding(.top, iOS15 ? 0 : 120)
        
        if OpenProfileMatchedGeometry != "" {
            if friendsDictionary.friendsDictionary[OpenProfileMatchedGeometry] != nil {
            FriendProfileHomeTabView(FriendProfileMatchedGeometry: $OpenProfileMatchedGeometry, id: OpenProfileMatchedGeometry, isFromOpenedPost: true, themeController: ThemeController())
            } else {
                StrangerProfileTabView(ProfileMatchedGeometry: $OpenProfileMatchedGeometry, person: StrangerProfileSelectedUser ?? Person(id: ""), id: OpenProfileMatchedGeometry)

            }

        }
    } .edgesIgnoringSafeArea(.bottom)
    }
}

struct EventMessageLikesTabView: View {
    @Binding var LikesMatchedGeometry: String
    @StateObject var likes = EventMessageLikesOO(id: "", eventID: "", conversationID: "", messageID: "")
    @ObservedObject var individualConversation : IndividualEventConversationOO
    @State var message: EventMessageModel
    @State var selectedTab = "likes"
    @ObservedObject var friendsDictionary: FriendsDictionary
    var body: some View {
        if selectedTab == "likes" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    EventMessageLikes(LikesMatchedGeometry: $LikesMatchedGeometry, likes: likes, messages: individualConversation, message: message, friendsDictionary: friendsDictionary)
                        .tag("likes")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    LikesMatchedGeometry = ""
                }
        }
    }
}
