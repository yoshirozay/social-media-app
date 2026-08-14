//
//  FriendProfile.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/16/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct FriendProfileHomeTabView: View { // Used when a profile post is open and need to return to the friend's profile
    @Binding var FriendProfileMatchedGeometry: String
    @State var selectedTab = "friendProfile"
    @State var id: String = ""
    @State var emptyBoolBinding = false
    @State var isFromOpenedPost = false
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @State var emptyStringBinding = ""
    @ObservedObject var themeController: ThemeController
    
    var body: some View {
        if selectedTab == "friendProfile" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    FriendProfile(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,friendsDictionary:friendsDictionary, postData: FriendsPostsOO(id: id, friendsDictionary: timelinePosts.friendsDictionary), id: id, mentionedUserVM: MentionedUserVM(friendsDictionary: friendsDictionary), CloseOpenConversationFromProfile: $emptyStringBinding, themeController: themeController, mutualFriends: MutualFriendsOO(id: id, tagMembers: [Person]()))
                        .tag("friendProfile")
                        .padding(.top, 60)
//                        .padding(.top, isFromOpenedPost && iOS15 ? 10 : 50)
//                        .padding(.top, isFromOpenedPost ? iOS15 ? 10 : 50 : 0)
                    
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle() 
            }
            .ignoresSafeArea(edges: .top)
        } else {
//            Ho me(signOut: $emptyBoolBinding)
            EmptyView()
                .onAppear() {
                    FriendProfileMatchedGeometry = ""
                }
        }
    }
}
struct FriendProfile: View {
    @Binding var FriendProfileMatchedGeometry: String
    @ObservedObject var friendsDictionary: FriendsDictionary
    @StateObject var postData : FriendsPostsOO  
    @Namespace var namespace
    @State var emptyStringBinding = ""
    @State var id: String = ""
    @State var OpenConversationMatchedGeometry = ""
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var allChats : AllMessagesOO
    @StateObject var myTags = MyTagsOO()
    @State var isShowingShareDelete = false
    @State var deleteFriendAlert = false
    @State var ShareFriendMatchedGeometry = ""
    @StateObject var friendFunctions = FriendRequestsFunctions()
    @State var isSharedFriendPopUpShowing = false
    @State var isInfoPopUpShowing = false
    @State var emptyBoolBinding = false
    @StateObject var savePost = SavePostFunction()
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var OpenedPhotoSelectedItem: URL?
    @StateObject var mentionedUserVM: MentionedUserVM
    @State var isFirstResponder: Bool = false
    @State var deletedPost : PostModel?
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @StateObject var postVM = PostVM()
    @Binding var CloseOpenConversationFromProfile: String
    @ObservedObject var themeController: ThemeController
    @EnvironmentObject var currentTab: CurrentTab
    @StateObject var mutualFriends: MutualFriendsOO
    @State var isShowingMutuals = false
    var postVStack : some View {
        
        ZStack {

            LazyVStack (spacing: 8) {
                //                ForEach(Array(postData.sortedPosts), id: \.self) { item in
                ForEach(Array(postData.sortedPostss), id: \.post.self) {  commentLikeVM in
                    let item = commentLikeVM.post
                    //                    TimelineMoment(id: item.id, friendProfileSelectedItem: $emptyStringBinding, FriendProfileMatchedGeometry: $emptyStringBinding, friendsDictionary: friendsDictionary, myTags: myTags, isDeletePostAlertShowing: $emptyBoolBinding, deletedPost: $deletedPost, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,commentLikeVM : commentLikeVM.getSelf(), isFirstResponder: $isFirstResponder,mentionedUserVM: mentionedUserVM, LongPostMatchedGeometry: $emptyStringBinding, postVM: postVM){
                    ////       withAnimation(.easeIn(duration: 0.3)) {
                    //
                    //                        postVM.openPost(commentLikeVM: commentLikeVM)
                    ////                              }
                    //                            }
                    VStack {
                    Rectangle()
                        .frame(width: screenWidth, height: 5)
                        .foregroundColor(Color.mainColorInverse)
                    TimelineMoment2(id: item.id,
                                    friendProfileSelectedItem: .constant(""),
                                    FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                                    friendsDictionary: timelinePosts.friendsDictionary,
                                    myTags: myTags,
                                    isDeletePostAlertShowing: .constant(false),
                                    deletedPost: $deletedPost,
                                    OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry,
                                    OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,
                                    commentLikeVM : commentLikeVM.getSelf(),
                                    isFirstResponder: $isFirstResponder,
                                    mentionedUserVM: mentionedUserVM,
                                    LongPostMatchedGeometry: .constant(""),
                                    postVM: postVM, show: .constant(false), buttonAlertType: .constant(.none), lockedMomentAlert: .constant(false), themeController: themeController) {
                        ///user can only open post if it has been sent.
                        guard item.status != .sending  else{
                            return
                        }
                        withAnimation {
                            postVM.openPost(commentLikeVM: commentLikeVM)
                            isFirstResponder = false
                            //                            show.toggle()
                        }
                        //                commentLikeVM.readPost(postID: item.postID)
                        //                                }
                    }
                    
                }
            }
//                        Divider()
//                            .padding(.vertical)
//                preloadedPosts
            }
            .padding(.top, 8)
        }
    }
    
    var preloadedPosts : some View{
            ForEach(Array(postData.preloadedPosts), id: \.self) { item in
                TimelineMoment(id: item.id, friendProfileSelectedItem: $emptyStringBinding, FriendProfileMatchedGeometry: $emptyStringBinding, friendsDictionary: friendsDictionary, myTags: myTags, isDeletePostAlertShowing: $emptyBoolBinding, deletedPost: $deletedPost, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,commentLikeVM : CommentLikeVM(post: item, friendsDictionary: friendsDictionary), isFirstResponder: $isFirstResponder,mentionedUserVM: mentionedUserVM, LongPostMatchedGeometry: $emptyStringBinding, postVM: postVM)
                    .matchedGeometryEffect(id: UUID(), in: namespace, isSource: false)
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.3)) {
                              postVM.openPost(commentLikeVM: CommentLikeVM(post: item, friendsDictionary: timelinePosts.friendsDictionary))
                        }
                    }
            }
        }

   
    var body: some View {
 
                ZStack {
                    themeController.theme.primary
                        .edgesIgnoringSafeArea(.all)
                    VStack (spacing: 10) {
                        HStack (spacing: 16) {  // Navigation Bar

                            Button(action: { // Navigation button

                                FriendProfileMatchedGeometry = ""
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.title)
                                    .padding(.leading)
                                    .foregroundColor(Color.black)
                                    .rotation3DEffect(.degrees(4), axis: (x: 0, y: 1, z: 0))
                            }.buttonStyle(.borderless)
                            Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                                .fontWeight(.bold)
                                .foregroundColor(Color.black)
                                .font(screenWidth < 375 ? .title2 : .title)
                                .rotation3DEffect(.degrees(4), axis: (x: 0, y: 1, z: 0))
                            Spacer()
                            if id != Auth.auth().currentUser?.uid {
                                Menu {
                                    Button("Delete", action: {
                                        deleteFriendAlert = true
                                    })
                                    Button("Report", action: {
                                        isInfoPopUpShowing = true
                                    })
                                    } label : {
                                        ZStack {
                                        Text(".")
                                            .font(.largeTitle)
                                            .offset(y: -7)
                                        Text(".")
                                            .font(.largeTitle)
                                        Text(".")
                                            .font(.largeTitle)
                                            .offset(y: 7)
                                        }
                                }
                                    .padding(.trailing)
                                   .padding(.top, -10)
                            }
                        } // Navigation Bar
                      .foregroundColor(Color.black)
                        
                        ScrollView(showsIndicators: false) {
                            VStack {
                                ZStack(alignment: .topTrailing) {
                                WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: screenWidth - 40, height: screenHeight * 0.6 - 40)
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 32)
                                            .stroke(.black, lineWidth: 5)
                                            .shadow(color: Color.mainColorInverse.opacity(0.25), radius: 6, x: 0, y: 3)
                                            .frame(width: screenWidth - 30, height: screenHeight * 0.6 - 30)
                                    )
                                    .rotation3DEffect(.degrees(1), axis: (x: 0, y: 1, z: 0))
                                Image(systemName: "sparkles")
                                        .foregroundColor(.black)
                                    .font(.largeTitle)
                                    .offset(x: -8, y: -20)
                            }
                                VStack (spacing: 20) { // Username, name, and bio
                                    HStack (spacing: 5) {
                                        Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                                            .font(.largeTitle)
                                            .fontWeight(.semibold)
                                            .italic()
//                                            .rotation3DEffect(.degrees(15), axis: (x: 0, y: 1, z: 0))
                                            .foregroundColor(.black)
                                        //                                        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
                                        //                                    Text("-")
                                        //                                        .font(.headline)
                                        //                                        .fontWeight(.bold)
                                        //                                    Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                                        //                                        .font(.headline)
                                        //                                        .fontWeight(.bold)
                                        //                                        Button(action: {
                                        //                                            OpenConversationMatchedGeometry = "0"
                                        //                                        }){
                                        //                                        Image(systemName: "bubble.left")
                                        //                                            .resizable()
                                        //                                            .frame(width: 15, height: 15)
                                        //                                          .foregroundColor(Color.black)
                                        //                                        }
                                        //                                        .buttonStyle(.borderless)
                                        //                                        .opacity(id == "ctgg158KOnajMBuFZ5GyHLyRYPE3" ? 0 : 1)
                                        //                                        .offset(x: 5, y: 2)
                                    }
                                    HStack {
                                    Button(action: {
                                        currentTab.openConversation(id: id)
                                    }) {
                                        Rectangle()
                                            .frame(width: screenWidth/2, height: 50)
                                            .foregroundColor(themeController.theme.accent)
                                            .cornerRadius(10)
                                            .overlay(
                                                Text("MESSAGE")
                                                    .foregroundColor(.white)
                                                    .bold()
                                            )
                                    }
                                        if mutualFriends.mutualFriends.count > 0 {
                                            Button(action: {
                                                isShowingMutuals.toggle()
                                            }) {
                                                Rectangle()
                                                    .frame(width: 70, height: 50)
                                                    .foregroundColor(themeController.theme.accent.opacity(1))
                                                    .cornerRadius(10)
                                                    .overlay (
                                                        HStack (spacing: 0) {
                                                            Text("\(mutualFriends.mutualFriends.count)")
                                                                .foregroundColor(.white)
                                                                .bold()
                                                                .font(.headline)
                                                            Image(systemName: "person")
                                                                .foregroundColor(.white)
                                                                .font(.subheadline)
                                                        }
                                                    )
                                            }
//                                            .offset(x: screenWidth/2.75)
                                        }
                                }
                                //                                    Text(friendsDictionary.friendsDictionary[id]?.bio ?? "")
                                //                                        .padding(.horizontal)
                                //                                        .font(.footnote)
                                //                                        .multilineTextAlignment(.leading)
                            } // Username, name, and bio
                            .foregroundColor(Color.black)
                            .padding(.vertical)
                            //                                .padding(.bottom, 10)
                            postVStack
                        }
                            .padding(.top, 20)
                        } // Scrollview, Container for Profile Picture, Username, Name, Bio, and Posts
                        .environmentObject(mentionedUserVM)
                        Spacer() // Pushes contents to the top of the Main Container
                    }  // VStack, Main Container

                    .disabled(isShowingShareDelete || isInfoPopUpShowing ? true : false)
//                    .padding(.top, iOS15 ? 0 : 60 )
                    .blur(radius: isShowingShareDelete || isInfoPopUpShowing ? 10 : 0)
                    .onTapGesture {
                        if isShowingShareDelete {
                            withAnimation {
                            isShowingShareDelete = false
                            }
                        }
                    }
                    
                    .alert(isPresented: $deleteFriendAlert) {
                        Alert(
                                       title: Text("Remove \(friendsDictionary.friendsDictionary[id]?.name ?? "") from your friends list?"),
                                       primaryButton: .destructive(Text("Delete")) {
                                        friendFunctions.deleteFriend(deletedUserID: id)
                                           FriendProfileMatchedGeometry = ""
                                           CloseOpenConversationFromProfile = ""
                                           print("Deleting...")
                                       },
                                       secondaryButton: .cancel()
                                   )
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
                    //
                    Group {
                    if isSharedFriendPopUpShowing != false {
                        SharedPopUp(isShowingPopUp: $isSharedFriendPopUpShowing)
                    }
//                        if OpenedPostMat chedGeometry != "", let selectedPost = selectedPost  {
                            if let selectedCommentLikeVM = postVM.commentLikeVM {
 
                                OpenedPostTabView(isFromProfile: true,
                                          commentLikeVM : selectedCommentLikeVM,postVM: postVM, showUpdatePost: .constant(nil), myTags: myTags)
//                            .padding(.top, 60)
                           
                    }
                           
                    if OpenConversationMatchedGeometry != "" {
                        OpenedConversation(OpenedConversationMatchedGeometry: $OpenConversationMatchedGeometry, allMessages: OpenedConversationOO(otherUserID: id),  allChats: allChats, id2: id, isOpenFromProfile: true, isFromOpenedMoment: false, show: .constant(false), themeController: ThemeController())
                            .padding(.top, iOS15 ? 0 : -60)
                            .frame(width: screenWidth, height: screenHeight-66, alignment: .top)
//                            .padding(.top, iOS15 ? (screenHeight > 800 ? 0 : 0) : 60)
                    }
                    if OpenedPhotoMatchedGeometry != "" {
                        OpenPhotoTabView(OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, photo: OpenedPhotoSelectedItem, isFromTimeline: true)
                            .onAppear(perform: postVM.removeViewInfo)
                            .onDisappear(perform: postVM.setViewInfo)
                        
                    }
//                    if ShareFriendMatchedGeometry != "" {
//                        ShareFriendTabView(SharePhotoMatchedGeometry: $ShareFriendMatchedGeometry, selectedFriend: id, isSharedFriendPopUpShowing: $isSharedFriendPopUpShowing)
//                    }
//
                    if isInfoPopUpShowing != false {
                        InfoPopUp(isInfoPopUpShowing: $isInfoPopUpShowing, functionType: .reportUser, reportedUserID: id)
                    }
                        

                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .padding(.top, -60)
//                .edgesIgnoringSafeArea(.top)
//                .padding(.top, iOS15 ? 0 : -60)
            .onChange(of: friendsDictionary.friendsDictionary[id]?.id) { friendId in
                if friendId == nil {
                    FriendProfileMatchedGeometry = ""
                }
            }
         
 // For smaller iPhones
    }
}
 


struct FriendProfileAllFriendsTabView: View {  // Used when an individual hexagon is selected
    @Binding var FriendProfileMatchedGeometry: String
    @State var selectedTab = "friendProfile"
    @State var id: String = ""
    @State var emptyStringBinding = ""
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    var body: some View {
        if selectedTab == "friendProfile" {
            ZStack {
                let friendProfile = FriendProfile(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,friendsDictionary:friendsDictionary, postData: FriendsPostsOO(id: id, friendsDictionary: timelinePosts.friendsDictionary), id: id, mentionedUserVM: MentionedUserVM(friendsDictionary: friendsDictionary), CloseOpenConversationFromProfile: $emptyStringBinding, themeController: ThemeController(), mutualFriends: MutualFriendsOO(id: id, tagMembers: [Person]()))
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    friendProfile
                        .tag("friendProfile")
                        .padding(.top, 60)
                }
             
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                friendProfile
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    FriendProfileMatchedGeometry = ""
                }
        }
    }
}
struct FriendProfileOpenedConversationTabView: View {  // Used when an individual hexagon is selected
    @Binding var FriendProfileMatchedGeometry: String
    @State var selectedTab = "friendProfile"
    @State var id: String = ""
    @State var emptyStringBinding = ""
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @Binding var CloseOpenConversationFromProfile: String
    @ObservedObject var themeController: ThemeController
    var body: some View {
        if selectedTab == "friendProfile" {
            ZStack {
                let friendProfile = FriendProfile(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,friendsDictionary:friendsDictionary, postData: FriendsPostsOO(id: id, friendsDictionary: timelinePosts.friendsDictionary), id: id, mentionedUserVM: MentionedUserVM(friendsDictionary: friendsDictionary), CloseOpenConversationFromProfile: $CloseOpenConversationFromProfile, themeController: themeController, mutualFriends: MutualFriendsOO(id: id, tagMembers: [Person]()))
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    friendProfile
                        .tag("friendProfile")
                        .padding(.top, 60)
                }
             
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                friendProfile
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    FriendProfileMatchedGeometry = ""
                }
        }
    }
}
