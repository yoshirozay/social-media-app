//
//  StrangerProfileFromNotifications.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/6/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct StrangerProfileFromNotificationsTabView: View {
    @Binding var ProfileMatchedGeometry: String
    @StateObject var person = ProfileOO(id: "")
    @State var id: String
    @State var selectedTab = "FriendRequest"
    var body: some View {
        if selectedTab == "FriendRequest" {
            ZStack {
                let strangerProfile = StrangerProfileFromNotifications(person: person, friendshipStatus: StrangerProfileOO(id: id),ProfileMatchedGeometry : $ProfileMatchedGeometry)
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    strangerProfile
                        .tag("FriendRequest")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
                
#elseif os(macOS)
                strangerProfile
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
              EmptyView()
                .onAppear() {
                    ProfileMatchedGeometry = ""
                }
        }
    }
}

struct StrangerProfileFromNotifications: View {
    @ObservedObject var person = ProfileOO(id: "")
    @StateObject var friendshipStatus : StrangerProfileOO//(id: "")
    @StateObject var functions = FriendRequestsFunctions()
    @StateObject var friendRequest = FriendRequestsOO()
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var alert : AlertOO
    @State private var showingFullFriendsListAlert = false
    @State private var showOtherUserFriendsListAlert = false
    @Binding var ProfileMatchedGeometry: String
    var body: some View {
        ZStack {
            Color.supportingColor.opacity(0.7)
                .ignoresSafeArea(.all)
            WebImage(url: person.person.profilePicLink)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: screenWidth, height: screenHeight)
                .cornerRadius(1)
                .ignoresSafeArea()
                
                .overlay(
                    VStack {
                        Text(person.person.name.uppercased())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.4))
#if os(iOS)
                        let singleButtonWidth : CGFloat = screenWidth - 100
#elseif os(macOS)
                        let singleButtonWidth : CGFloat = screenWidth * 0.5
#endif
                        Group {
                            
                            if friendshipStatus.didISendAFriendRequest == false && friendshipStatus.doIHaveAFriendRequest == false && friendsDictionary.friendsDictionary[person.person.id] == nil && friendshipStatus.areWeFriends == false {
                                
                                Button(action: {
                                    
                                    guard let userId = Auth.auth().currentUser?.uid else{ return }
                                    
                                    if friendsDictionary.friendsDictionary.count < 152 {
                                        functions.addFriend(id: person.person.id, nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "", token: person.person.token)
                                        friendshipStatus.sendFriendRequest()
                                    } else {
                                        showingFullFriendsListAlert = true
                                    }
              
                                }) {
                                    Text("ADD FRIEND")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(.vertical)
                                        .frame(width: singleButtonWidth)
                                        .foregroundColor(.white)
                                     
                                }.buttonStyle(.borderless)
                                 .background(
                                    LinearGradient(gradient: .init(colors: [Color.purple.opacity(1), Color.purple.opacity(0.3)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(10).shadow(radius: 20)
                                .background(Color.white.cornerRadius(10))
                            }
                            
                            if friendshipStatus.doIHaveAFriendRequest == true  && friendsDictionary.friendsDictionary[person.person.id] == nil  {
                                
#if os(iOS)
                                let spacing : CGFloat = 20
                                let buttonWidth : CGFloat = screenWidth - 250
#elseif os(macOS)
                                let spacing : CGFloat = screenWidth*0.1
                                let buttonWidth : CGFloat = screenWidth*0.3
#endif
                                HStack (spacing: spacing) {
                                    Button(action: {
                                        
                                        guard let userId = Auth.auth().currentUser?.uid else{ return }
                                        if friendsDictionary.friendsDictionary.count < 152 {
                                            friendshipStatus.acceptFriendRequest(personId: person.person.id) { canAccecpt, error in
                                                if canAccecpt {
                                                    functions.acceptFriendRequest(id: person.person.id, nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "", token: person.person.token)
                                                    friendRequest.handleModifiedRequest(person.person.id)
                                                }else{
                                                    if let _ = error{
                                                        alert.alertDetail = "Something went wrong, try again"
                                                    }else{
                                                        showOtherUserFriendsListAlert = true
                                                    }
                                                }
                                            }
                                        } else {
                                            showingFullFriendsListAlert = true
                                        }
                                        
                                    } ) {
                                        Text("CONFIRM")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .padding(.vertical)
                                            .frame(width: buttonWidth)
                                            .foregroundColor(.white)
                                        
                                        
                                    } .background(
                                        LinearGradient(gradient: .init(colors: [Color.purple.opacity(1), Color.purple.opacity(0.3)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(10).shadow(radius: 20)
                                    .background(Color.white.cornerRadius(10))
                                    
                                    Button(action: {
                                        functions.declineFriendRequest(id: person.person.id)
                                        friendshipStatus.declineFriendRequest()
                                        friendRequest.handleModifiedRequest(person.person.id)
                                    }) {
                                        Text("DECLINE")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .padding(.vertical)
                                            .frame(width: buttonWidth)
                                            .foregroundColor(.white)
                                        
                                        
                                    }.buttonStyle(.borderless)
                                     .background(
                                        LinearGradient(gradient: .init(colors: [Color.purple.opacity(0.3), Color.purple.opacity(1)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(10).shadow(radius: 20)
                                    .background(Color.white.cornerRadius(10))
                                }
                            }
                         
                            if friendsDictionary.friendsDictionary[person.person.id] != nil || friendshipStatus.areWeFriends == true {
                                
                                Button(action: {
                                    
                                }) {
                                    Text("FRIENDS")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(.vertical)
                                        .frame(width: singleButtonWidth)
                                        .foregroundColor(.white)
                                     
                                }.buttonStyle(.borderless)
                                 .background(
                                    LinearGradient(gradient: .init(colors: [Color.purple.opacity(1), Color.purple.opacity(0.3)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(10).shadow(radius: 20)
                                .background(Color.white.cornerRadius(10))
                            } else if friendshipStatus.didISendAFriendRequest == true {
                                
                                Button(action: {
                                    functions.deleteFriendRequest(id: person.person.id)
                                    friendshipStatus.cancelFriendRequest()
                                    friendshipStatus.declineFriendRequest()
                                }) {
                                    Text("CANCEL REQUEST")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(.vertical)
                                        .frame(width: singleButtonWidth)
                                        .foregroundColor(.white)
                                     
                                }.buttonStyle(.borderless)
                                 .background(
                                    LinearGradient(gradient: .init(colors: [Color.purple.opacity(1), Color.purple.opacity(0.3)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(10).shadow(radius: 20)
                                .background(Color.white.cornerRadius(10))
                            }
                        }
                    }
                )
            
#if os(macOS)
            VStack () {
                HStack {
                    Button(action: {
                        ProfileMatchedGeometry = ""
                    }) {
                        ZStack {
                            Color.white.opacity(0.2)
                        Image(systemName: "chevron.left")
                            .font(.largeTitle)

                            .foregroundColor(.speakerPurple)
                            .padding(.horizontal, 5)
                        }
                        .frame(width: 20, height: 20)
                        .padding(.leading)
                        
                    }.buttonStyle(.borderless)
                    .padding(.top, 140)
                    Spacer()
                }
                .padding()
                Spacer()
            }
#endif
            ZStack{}
                .alert(isPresented: $showingFullFriendsListAlert) {
                    Alert(
                        title: Text("Your friends list is full "),
                        message: Text("150/150"))
                }
            ZStack{}
                .alert(isPresented: $showOtherUserFriendsListAlert) {
                    Alert(
                        title: Text("The other User's friends list is full "),
                        message: Text("150/150"))
                }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
