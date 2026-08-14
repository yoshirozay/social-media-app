//
//  ShareFriend.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/3/21.
//

import SwiftUI
import SDWebImageSwiftUI
 

struct ShareFriend: View {
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var isShowingMentions = false
    @Binding var ShareFriendMatchedGeometry: String
    @State var selectedUser = [""]
    @StateObject var keyboard = KeyboardOO()
    @EnvironmentObject var allChats : AllMessagesOO
    @StateObject var shareFriend = ShareFriendFunction()
    @State var selectedFriend = ""
    @Binding var isSharedFriendPopUpShowing: Bool
    @Environment(\.colorScheme) var colorScheme
    func shareFriendFunction() {
            shareFriend.shareFriend(friendIDs: selectedUser, sharedFriendID: selectedFriend)
            ShareFriendMatchedGeometry = ""
        }

    var body: some View {
        ZStack {
            Color.mainColorInverse.opacity(1.0)
                .edgesIgnoringSafeArea(.all)
            (colorScheme == .light ?
            Color.plumWeb.opacity(0.2) : Color.speakerPurple.opacity(0.2))
                .edgesIgnoringSafeArea(.all)
            ZStack (alignment: .bottom) {
                VStack {
                    HStack {
//#if os(macOS)
                        Button(action: {
                            withAnimation(Animation.linear.speed(0.1)){
                                ShareFriendMatchedGeometry = ""
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .padding(.leading)
                        }.buttonStyle(.borderless)
                         .foregroundColor(Color.mainColor)
                         .padding(.trailing,-5)
//#endif
                         
                        Text("\(friendsDictionary.friendsDictionary[selectedFriend]?.username ?? "")")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                          .foregroundColor(Color.mainColor)
                        Spacer()

                    }
//                    .padding(.leading, 5)
                    ScrollView(showsIndicators: false) {
                        LazyVStack {
                        ForEach(Array(friendsDictionary.friendsDictionary.values.sorted(by: ({$0.name < $1.name }))), id: \.self) { item in
                            if item.id != TristanUserID {
                            SelectFriends(id: item.id, selectedUser: $selectedUser, themeController: ThemeController())
                                .padding(.horizontal)
                            }
                        }
                        }
                        .background(Color.mainColorInverse.opacity(0.3)
                                    
                            .clipShape(RoundedRectangle(cornerRadius: 25))
            //                            .padding(.horizontal, 10)
                            .padding(.vertical, -10)
                            )
                        .padding(.top, 10 )
                        .padding(.bottom, 40)

                    }
                    Spacer()
                }
                if selectedUser != [""] {
                    VStack {

                        Button(action: {
                            shareFriendFunction()
                            withAnimation {
                            isSharedFriendPopUpShowing = true
                            }
                        }) {
                            RoundedRectangle(cornerRadius: 25.0)
                                .frame(width: screenWidth - 230, height: 50, alignment: .center)
                                .foregroundColor(Color.speakerPurple.opacity(0.5))
//                                .shadow(radius: 3, x: 0, y: 0)
                                .overlay(
                                    Text("Share")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                )
                        }.buttonStyle(.borderless)
                        .offset(y: -150)
                    }
                    .animation(.easeIn)
                    .padding(.bottom, keyboard.value)
                }

            }
            .padding(.top, 60)
        }
        //        .padding(.top, -60)
    }
}

struct SelectFriends: View {
    @State var id: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var selected = false
    @Binding var selectedUser: [String]
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController
    var body: some View {
        VStack {
            HStack {
                WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 12) {
                    Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                        .fontWeight(.bold)
                    Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                        .font(.caption)
                        .padding(.top, -10)
                } // VSTACK
         .foregroundColor(Color.black)
                Spacer()
                Button(action: {
                    if selected == false {
                        selectedUser.append(id)
                        selected = true
                    } else {
                        if  let firstIndex = selectedUser.firstIndex(of: id) {
                            selectedUser.remove(at: firstIndex)
                            selected = false
                        }
                    }
                }){
                    Circle()
                        .frame(width: 20, height: 20)
                        .padding(.trailing)
                        .foregroundColor(selected ? Color.mainColorInverse : themeController.theme.accent.opacity(0.3))
//                        .shadow(radius: 3, x: 0, y: 0)
                }.buttonStyle(.borderless)
            } // HSTACK
//            Divider()
            Rectangle()
                .frame(width: screenWidth - 40, height: 2)
                .foregroundColor(themeController.theme.accent.opacity(0.2))

        }
//        .background(Color.mainColorInverse)
        .contentShape(Rectangle())
        .onTapGesture {
            if selected == false {
                selectedUser.append(id)
                selected = true
            } else {
                if let firstIndex = selectedUser.firstIndex(of: id) {
                    selectedUser.remove(at: firstIndex)
                    selected = false
                }
            }
        }
        
    }
}


struct ShareFriendTabView: View {
    @Binding var SharePhotoMatchedGeometry: String
    @State var emptyStringBinding: String = ""
    @State var selectedTab = "likes"
    @State var selectedFriend: String
    @Binding var isSharedFriendPopUpShowing: Bool
    var body: some View {
        if selectedTab == "likes" {
            ZStack {
                let shareFriend = ShareFriend(ShareFriendMatchedGeometry: $SharePhotoMatchedGeometry, selectedFriend: selectedFriend, isSharedFriendPopUpShowing: $isSharedFriendPopUpShowing)
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    shareFriend
                         .tag("likes")
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
                
#elseif os(macOS)
                shareFriend
#endif 
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    SharePhotoMatchedGeometry = ""
                }
        }
    }
}

struct SharedPopUp: View {
    
    @Binding var isShowingPopUp: Bool
    var body: some View {
        ZStack {
            
            HStack {
                ZStack {
                    LinearGradient(gradient: .init(colors: [Color.speakerPurple.opacity(1), Color.speakerPink.opacity(0.3)]), startPoint: .leading, endPoint: .trailing)
                    VStack (alignment: .center) {
                        
                        Text("Shared")
                            .foregroundColor(.mainColorInverse)
                            .fontWeight(.bold)
                        
                    }
                }
            }
            .frame(width: screenWidth/1.5, height: 50)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15)))
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
            isShowingPopUp = false
            }
           }
       }
    }
}

struct SelectChatGroups: View {
    @State var chatModel: ChatModel
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var selected = false 
    @Binding var selectedGroupIds: [SelectedChat]
    @Binding var isViewOnce : Bool
    @ObservedObject var themeController: ThemeController
    var body: some View {
        VStack {
            HStack {
                GroupProfileImage(chatModel: chatModel, themeController: themeController)
                VStack(alignment: .leading, spacing: 12) {
                    Text(chatModel.groupName)
                        .fontWeight(.bold)
                }
                Spacer()
                Button(action:  onTap){
                    Circle()
                        .frame(width: 20, height: 20)
                        .padding(.trailing)
                        .foregroundColor(selected ? Color.speakerPurple : Color.speakerPink.opacity(0.1))
                        .shadow(radius: 3, x: 0, y: 0)
                }.buttonStyle(.borderless)
            }
            Divider()
        } .background(Color.mainColorInverse)
        .contentShape(Rectangle())
        .onTapGesture( perform: onTap)
        .onChange(of: isViewOnce) { isViewOnce in
            if isViewOnce {
                selected = false
            }
        } 
    }
    
    func onTap(){
        if selected == false {
            selectedGroupIds.append(chatModel.selectedGroup)
            selected = true
        } else if let firstIndex = selectedGroupIds.firstIndex(where: {$0.chatId == chatModel.chatUID }){
                selectedGroupIds.remove(at: firstIndex)
                selected = false 
        }
    }
}
