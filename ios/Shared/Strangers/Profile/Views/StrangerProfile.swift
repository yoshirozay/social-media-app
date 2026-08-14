//
//  StrangerProfile.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 1/27/21.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFunctions
import Firebase

struct StrangerProfile: View {
    @Binding var ProfileMatchedGeometry: String
    @State var person: Person
    @StateObject var friendshipStatus : StrangerProfileOO//(id: "")
    @StateObject var functions = FriendRequestsFunctions()
    @StateObject var friendRequest = FriendRequestsOO()
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var alert : AlertOO
    @State private var showingFullFriendsListAlert = false
    @State private var showOtherUserFriendsListAlert = false
    @State var isShowingMutuals = false
    @ObservedObject var mutualFriends: MutualFriendsOO
    @State var isLoading = true
    @AppStorage("friendRequestAlert") var friendRequestAlert : Bool = false
    @State var buttonAlertType: ButtonAlertType = .none
    @StateObject var themeController = ThemeController()
    var body: some View {
        ZStack {
            themeController.theme.primary
                .ignoresSafeArea(.all)
            WebImage(url: person.profilePicLink)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: screenWidth, height: screenHeight-66, alignment: .top)
                .cornerRadius(1)
                .ignoresSafeArea()
                .overlay(
                    VStack {
                        Text(person.name.uppercased())
                            .font(.largeTitle.weight(.semibold))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.4))
                            .offset(y: -13)
                        
#if os(macOS)
                            .padding(.bottom,40)
#endif
                        
#if os(iOS)
                        let singleButtonWidth : CGFloat = screenWidth - 100
#elseif os(macOS)
                        let singleButtonWidth : CGFloat = screenWidth * 0.5
#endif
                        
                        Group {
                            
                            if friendshipStatus.didISendAFriendRequest == false && friendshipStatus.doIHaveAFriendRequest == false && friendsDictionary.friendsDictionary[person.id] == nil && friendshipStatus.areWeFriends == false {
                                
                                Button(action: {
                                    
                                    guard let userId = Auth.auth().currentUser?.uid else { return }
                                    if friendRequestAlert == false {
                                        withAnimation() {
                                            buttonAlertType = .friendRequests
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                friendRequestAlert = true
                                            }
                                        }
                                    } else  {
                                        if friendsDictionary.friendsDictionary.count < 152 {
                                            functions.addFriend(id: person.id, nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "", token: person.token)
                                            friendshipStatus.sendFriendRequest()
                                        } else {
                                            showingFullFriendsListAlert = true
                                        }
                                    }
                                }) {
                                    Text("ADD FRIEND")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(.vertical)
                                        .frame(width: singleButtonWidth)
                                        .foregroundColor(.white)
                                    
                                } .buttonStyle(.borderless)
                                    .background(
                                        themeController.theme.primary
                                    ).cornerRadius(10).shadow(radius: 20)
//                                    .background(Color.white.cornerRadius(10))
                            }
                            
                            if friendshipStatus.doIHaveAFriendRequest == true  && friendsDictionary.friendsDictionary[person.id] == nil  {
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
                                        if friendRequestAlert == false {
                                            withAnimation() {
                                                buttonAlertType = .friendRequests
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    friendRequestAlert = true
                                                }
                                            }
                                        } else  {
                                            if friendsDictionary.friendsDictionary.count < 152 {
                                                friendshipStatus.acceptFriendRequest(personId: person.id) { canAccecpt, error in
                                                    if canAccecpt {
                                                        functions.acceptFriendRequest(id: person.id, nameOfSendingUser: friendsDictionary.friendsDictionary[userId]?.name ?? "", token: person.token)
                                                        friendRequest.handleModifiedRequest(person.id)
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
                                        }
                                    }) {
                                        Text("CONFIRM")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .padding(.vertical)
                                            .frame(width: buttonWidth)
                                            .foregroundColor(.white)
                                        
                                        
                                    }.buttonStyle(.borderless)
                                        .background(
                                            themeController.theme.primary
                                        ).cornerRadius(10).shadow(radius: 20)
//                                        .background(Color.white.cornerRadius(10))
                                    
                                    Button(action: {
                                        functions.declineFriendRequest(id: person.id)
                                        friendshipStatus.declineFriendRequest()
                                        friendRequest.handleModifiedRequest(person.id)
                                    }) {
                                        Text("DELETE")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .padding(.vertical)
                                            .frame(width: buttonWidth)
                                            .foregroundColor(.white)
                                        
                                        
                                    }.buttonStyle(.borderless)
                                        .background(
                                            themeController.theme.primary
                                        ).cornerRadius(10).shadow(radius: 20)
//                                        .background(Color.white.cornerRadius(10))
                                }
                            }
                            
                            if friendsDictionary.friendsDictionary[person.id] != nil || friendshipStatus.areWeFriends == true {
                                
                                Button(action: {
                                    
                                }) {
                                    Text("FRIENDS")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(.vertical)
                                        .frame(width: singleButtonWidth)
                                        .foregroundColor(.white)
                                    
                                } .buttonStyle(.borderless)
                                    .background(
                                        themeController.theme.primary
                                    ).cornerRadius(10).shadow(radius: 20)
//                                    .background(Color.white.cornerRadius(10))
                            }else if friendshipStatus.didISendAFriendRequest == true {
                                
                                Button(action: {
                                    functions.deleteFriendRequest(id: person.id)
                                    friendshipStatus.cancelFriendRequest()
                                    friendshipStatus.declineFriendRequest()
                                }) {
                                    Text("CANCEL REQUEST")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(.vertical)
                                        .frame(width: singleButtonWidth)
                                        .foregroundColor(.white)
                                    
                                    
                                } .buttonStyle(.borderless)
                                    .background(
                                        themeController.theme.primary
//                                        LinearGradient(gradient: .init(colors: [Color.purple.opacity(1), Color.purple.opacity(0.3)]), startPoint: .leading, endPoint: .trailing)
                                    ).cornerRadius(10).shadow(radius: 20)
                                    .background(Color.white.cornerRadius(10))
                            }
                        }
                        if isLoading == false {
                        Button(action: {
                            isShowingMutuals.toggle()
                        }) {
                            Text(mutualFriends.mutualFriends.count == 1
                                 ? "1 MUTUAL" : "\(mutualFriends.mutualFriends.count) MUTUALS")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.black.opacity(0.4))
                        }
                        .offset(y: 150)
                    }
                    }
                        .disabled(isShowingMutuals ? true : false)
                        .blur(radius: isShowingMutuals ? 5 : 0)
                )
            VStack () {
                HStack {
                    Button(action: {
                        ProfileMatchedGeometry = ""
                    }) {
                        ZStack {
                            Color.white.opacity(0.2)
                        Image(systemName: "chevron.left")
                                .font(.largeTitle.weight(.heavy))

                            .foregroundColor(themeController.theme.primary)
                            .padding(.horizontal, 5)
                        }
                        .frame(width: 20, height: 20)
                        .padding(.leading)
                        
                    }.buttonStyle(.borderless)
                    .padding(.top, 40)
                    Spacer()
                }
                .padding()
                Spacer()
            }
            .disabled(isShowingMutuals ? true : false)
            .blur(radius: isShowingMutuals ? 5 : 0)
            if isShowingMutuals {
                if mutualFriends.mutualFriends.count > 0 {
                    MutualFriendsList(mutualFriends: mutualFriends, friendsDictionary: friendsDictionary, themeController: themeController) {
                        isShowingMutuals.toggle()
                    }
                }
            }
            if buttonAlertType != .none {
                ButtonTapAlertController(buttonAlertType: $buttonAlertType, themeController: themeController) 
            }
            ZStack{}
                .alert(isPresented: $showingFullFriendsListAlert) {
                    Alert(
                        title: Text("Your friends list is full "),
                        message: Text("150/150"))
                }
            ZStack{}
                .alert(isPresented: $showOtherUserFriendsListAlert) {
                    Alert(
                        title: Text("\(person.name)'s friends list is full "),
                        message: Text("150/150"))
                }
        }.ignoresSafeArea(edges: .all)
          .onReceive(friendshipStatus.$dismissStrangerProfile) { dismiss in
                if dismiss {
                    ProfileMatchedGeometry.removeAll()
                }
            }
          .onAppear {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                  withAnimation {
                      isLoading = false
                  }
              }
          }
          .onTapGesture {
              hideKeyboard()
          }
    }
}

struct StrangerProfileTabView: View {
    @Binding var ProfileMatchedGeometry: String
    let person: Person
    let id: String
    @State var selectedTab = "FriendRequest"
    //we are usng it optional here because if we just init it here in some case we might not use it. so we will be initailizing an object that we do not need, as FriendRequestsTabView child FriendRequest will have its own FriendRequestsOO
    var friendRequest : FriendRequestsOO?
    var addPNListener : Bool = true
    var body: some View {
        if selectedTab == "FriendRequest" {
            ZStack {
                let strangerProfile = StrangerProfile(ProfileMatchedGeometry: $ProfileMatchedGeometry,
                                                      person: person,
                                                      friendshipStatus: StrangerProfileOO(id: id,addPNListener: addPNListener),
                                                      friendRequest : friendRequest ??  FriendRequestsOO(), mutualFriends: MutualFriendsOO(id: id, tagMembers: [Person]()))
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
               .padding(.top,40)
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
             //FIXME: - i do not think we need this at all but we still need to check
            EmptyView()
                .onAppear() {
                    ProfileMatchedGeometry = ""
                }
        }
    }
}
 


private struct MentionTapView : View {
    @ObservedObject var mentionedUserVM : MentionedUserVM
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @State var isFromOpenedProfile: Bool
    @State var emptyStringBinding = ""
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            if mentionedUserVM.presentFriendProfile {
                FriendProfile(FriendProfileMatchedGeometry: $mentionedUserVM.friendProfileMatchedGeometry, friendsDictionary: friendsDictionary,
                              postData: FriendsPostsOO(id: mentionedUserVM.friendProfileSelectedID, friendsDictionary: timelinePosts.friendsDictionary),
                              id: mentionedUserVM.friendProfileSelectedID, mentionedUserVM: mentionedUserVM, CloseOpenConversationFromProfile: $emptyStringBinding, themeController: themeController, mutualFriends: MutualFriendsOO(id: mentionedUserVM.friendProfileMatchedGeometry, tagMembers: [Person]()))
                .padding(.top, 60)
                .padding(.top, iOS15 ? 40 : 0)
                .padding(.top, isFromOpenedProfile ? iOS15 ? 10 : 70 : 0)
                    .ignoresSafeArea(.all)
//                        .padding(.top, 10)
            } else if let user = mentionedUserVM.strangerUser{
                StrangerProfileTabView(ProfileMatchedGeometry: $mentionedUserVM.profileMatchedGeometry, person: user, id: mentionedUserVM.profileMatchedGeometry)
            }
        }
    }
}

 
struct UserMentionTabView: View {
    @ObservedObject var mentionedUserVM : MentionedUserVM
    @State var selectedTab = "openedPost"
    @State var isFromOpenedProfile: Bool
    @ObservedObject var themeController: ThemeController
    var body : some View {
        if selectedTab == "openedPost"{
            ZStack{
                let mentionTapView = MentionTapView(mentionedUserVM: mentionedUserVM, isFromOpenedProfile: isFromOpenedProfile, themeController: themeController)
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    mentionTapView
                        .tag("openedPost")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                mentionTapView
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear(perform: {
                    mentionedUserVM.clean()
                    selectedTab = ""
                })
        }
    }
}


struct MutualFriendsList: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var mutualFriends: MutualFriendsOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var themeController: ThemeController
    var action: () -> ()
    var body: some View {
        
        ZStack (alignment: .topLeading){
            VStack (spacing: 0) {
                Rectangle()
                    .foregroundColor(themeController.theme.primary)
                    .cornerRadius(18, corners: [.topLeft, .topRight])
                    .frame(height: 90)
                    .overlay (
                        HStack {
                            Text("MUTUAL FRIENDS")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .shadow(color: themeController.theme.primary.opacity(0.16), radius: 6, x: 0 , y: 6)
                            Spacer()
                        }
                            .padding(.horizontal)

                    )
                ScrollView {
                    VStack (spacing: 5) {
                        ForEach(mutualFriends.mutualFriends.values.sorted(by: {$1.name.lowercased() > $0.name.lowercased()}), id: \.self) { item in
                            if item.id != TristanUserID {
                                SearchBarResults(id: item.id, size: 55)
                                    .contentShape(Rectangle())
                                    .padding(.horizontal, 8)
                                Divider()
                                    .padding(. horizontal, 5)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .frame(height: screenHeight/1.747)
//                .frame(height: mutualFriends.mutualFriends.count > 7 ? 530 : ((CGFloat(mutualFriends.mutualFriends.count) * 65) + 10))
                .clipped()
                
            }
            .frame(width: screenWidth/1.1444)
            .padding(3)
            .background(
                Rectangle()
                    .foregroundColor(themeController.theme.secondary)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y:6))
            DoubleCircle(size1: 45, size2: 39,
                         themeController:themeController) {
                action()
            }
            .overlay (
                Image(systemName: "xmark")
                    .foregroundColor(.black)
                    .onTapGesture {
                        withAnimation {
                            action()
                        }
                    }
            )
            .offset(x: -10, y: -10)
        }
        .transition(.opacity)
    }
}
