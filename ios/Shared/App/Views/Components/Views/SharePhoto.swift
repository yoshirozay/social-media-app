//
//  SharePhoto.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 5/28/21.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth
/*
 we should pass down the VM to the share photo and call send multiple message from there.
 now that way we can also add array of [user : sendingrequestCount] dict. so that we it will also be updated. and on the individual view we can just update that
 */
struct SharePhoto: View {
    @State var isShowingMentions = false
    @State var selectedUser : [String] = [ ]
    @State var selectedGroupIds : [SelectedChat] = [ ]
    
    @Binding var media: NewMedia?
    @Binding var presentationMode : PresentationMode
    @StateObject var keyboard = KeyboardOO()
    @EnvironmentObject var allChats : AllMessagesOO
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var isFromSharedFriend: Bool = false
    @StateObject var shareFriend = ShareFriendFunction()
    @State var selectedFriend = ""
    func sendMessage() {
        if isFromSharedFriend != true {
            guard let selectedMedia = media else {
                return
            }
//            let _ = print(" isViewOnce.toggle() \(isViewOnce)")
            allChats.sendMessagesTo(selectedUser: selectedUser,
                                    selectedChatGroup: selectedGroupIds,
                                    friendsDict: friendsDictionary.friendsDictionary, 
                                    media: selectedMedia,
                                    isViewOnce : isViewOnce)
        } else {
            shareFriend.shareFriend(friendIDs: selectedUser, sharedFriendID: selectedFriend) 
        }
#if os(iOS)
        presentationMode.dismiss()
#endif
        media = nil
    }
    @State private var showSaveButton = true
    @State private var isViewOnce = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            Color.mainColorInverse.ignoresSafeArea(.all)
            ZStack (alignment: .bottom) {
                VStack {
 
                    HStack (spacing: 16) {
                        Button(action: {
                            withAnimation(Animation.linear.speed(0.1)){
                                media = nil
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.bold))
                                .padding(.leading)
                        }.buttonStyle(.borderless)
                            .foregroundColor(Color.mainColor)
                        
                        Text(isFromSharedFriend ? "Share To" : "Private Message")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                          .foregroundColor(Color.mainColor)
                        Spacer()
                        Button(action: {
                            withAnimation(Animation.linear.speed(0.1)){
                                isViewOnce.toggle()
                            }
                        }) {
                            let imageSystemName = isViewOnce ? "eye.slash.fill" : "eye.fill"
                            Image(systemName: imageSystemName)
                                .font(.title3)
                                .padding(.trailing)
                        }.buttonStyle(.borderless)
                          .foregroundColor(Color.mainColor)
                            .padding(.trailing, 10)
                    }
                    
                    ScrollView() {
                        LazyVStack {
                            //here we will add chatGroups as well
                            ForEach(friendsDictionary.allFriendsSortedByName, id: \.self) { item in
                                SelectFriends(id: item.id, selectedUser: $selectedUser, themeController: themeController)
                                    .padding(.horizontal)
                                    .animation(.none)
                            }
//                            }
                        }.animation(.none)
                        
                    }
                    Spacer()
                }
                if selectedUser != [""] {
                    VStack {
                        
                        Button(action: {
                            sendMessage()
                        }) {
                            RoundedRectangle(cornerRadius: 25.0)
                                .frame(width: screenWidth - 200, height: 50, alignment: .center)
                                .foregroundColor(themeController.theme.accent)
                                .shadow(radius: 3, x: 0, y: 0)
                                .overlay(
                                    Text("Send")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                )
                        }.buttonStyle(.borderless)
                        .offset(y: -40)
                    }
                    .padding(.bottom, keyboard.value)
                }
                
            }
            .padding(.top, 10)
            .onChange(of: isViewOnce) { isViewOnce in
                if isViewOnce {
                    selectedGroupIds = []
                }
            }
        }
    }
}

struct PhotoMessage: View {
    @State var isShowingMentions = false
    @State var selectedUser : [String] = [ ]
    @State var selectedGroupIds : [SelectedChat] = [ ]
    
    @Binding var media: NewMedia?
    @Binding var presentationMode : PresentationMode
    @StateObject var keyboard = KeyboardOO()
    @EnvironmentObject var allChats : AllMessagesOO
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var isFromSharedFriend: Bool = false
    @StateObject var shareFriend = ShareFriendFunction()
    @State var selectedFriend = ""
    func sendMessage() {
        if isFromSharedFriend != true {
            guard let selectedMedia = media else {
                return
            }
//            let _ = print(" isViewOnce.toggle() \(isViewOnce)")
            allChats.sendMessagesTo(selectedUser: selectedUser,
                                    selectedChatGroup: selectedGroupIds,
                                    friendsDict: friendsDictionary.friendsDictionary,
                                    media: selectedMedia,
                                    isViewOnce : isViewOnce)
        } else {
            shareFriend.shareFriend(friendIDs: selectedUser, sharedFriendID: selectedFriend)
        }
#if os(iOS)
        presentationMode.dismiss()
#endif
        media = nil
    }
    @State private var showSaveButton = true
    @State private var isViewOnce = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.primary
                .edgesIgnoringSafeArea(.all)
 
                VStack {
                    HStack (spacing: 16) {
                        Button(action: {
                            withAnimation(Animation.linear.speed(0.1)){
                                                          media = nil
                                                      }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.bold))
                                .padding(.leading)
                        }
                        HStack {

                                Text("Private Message")
                                    .fontWeight(.bold)
                                    .font(.title)

                        }
                        .frame(height: 40)
                        Spacer()
                        Button(action: {
                            sendMessage()
                        }) {
                            Image(systemName: "paperplane")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .padding(.top, 3)
                                .padding(.trailing, 3)
                            
                        }
                        .padding(.trailing, 28)
                        .disabled(selectedUser.count < 1 ? true : false)
                        .opacity(selectedUser.count < 1 ? 0.0 : 1.0)
                    }
                    .foregroundColor(Color.black)
                    .animation(.easeInOut(duration: 0.3))
                    .padding(.bottom, 20)

                    ScrollView(showsIndicators: false) {
                        VStack (spacing: 15) {
                            //here we will add chatGroups as well
                            
                             HStack (alignment: .top) {
                           
                             Text("VIEW ONCE")
                                 .font(.headline)
                                 .padding(.leading, 16)
                                 .foregroundColor(.black)
                                 Spacer()
              
                                 Button(action: {
                                     isViewOnce.toggle()
                                 }){
                                     Circle()
                                         .frame(width: 20, height: 20)
                                         .padding(.trailing, 32)
                                         .foregroundColor(isViewOnce ? themeController.theme.accent : themeController.theme.accent.opacity(0.4))
                                 }

                             }
                             .offset(y: 2)
                             Rectangle()
                                 .frame(width: screenWidth - 10, height: 2)
                                 .foregroundColor(themeController.theme.accent.opacity(0.2))
                            ForEach(friendsDictionary.allFriendsSortedByName, id: \.self) { item in
                                SelectFriends(id: item.id, selectedUser: $selectedUser, themeController: themeController)
                                    .padding(.horizontal)
                                    .animation(.none)
                            }
//                            }
                        } .background(Color.mainColorInverse.opacity(0.6)
                                      
                            .clipShape(RoundedRectangle(cornerRadius: 25))
    //                            .padding(.horizontal, 10)
                            .padding(.vertical, -10)
                            )
                        .padding(.top, 20)
                    }
                    .padding(.top, -20)
                    Spacer()
                }
                            .padding(.top, 10)
            .onChange(of: isViewOnce) { isViewOnce in
                if isViewOnce {
                    selectedGroupIds = []
                }
            }
            .padding(.top, 50)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
