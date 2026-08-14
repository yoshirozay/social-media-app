//
//  Notifications.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/20/21.
//

import SwiftUI
import Firebase
import FirebaseStorage
import SDWebImageSwiftUI
import FirebaseFirestore

struct Notifications: View {
    @Namespace var namespace
    @Binding var NotificationstMatchedGeometry: String
    @EnvironmentObject var notifications: NotificationsOO
    @EnvironmentObject var posts : TimelinePostsOO
    @EnvironmentObject var friendsDictionary : FriendsDictionary
    @EnvironmentObject var alert : AlertOO 
    @State var OpenedFriendRequestMatchedGeometryEffect = ""
    @State var OpenedFriendRequestSelectedItem = Person(id: "", username: "", name: "", bio: "", imageurl: "", webLink: URL(string: ""), accountCreationDate: Timestamp(), profileCircle: .clear)
    @State var FriendProfileMatchedGeometryEffect = "" 
    @State var StrangerProfileMatchedGeometry = ""
    @State var StrangerProfileSelectedItem: Person!
    @ObservedObject var newFriendRequest: UnreadFriendRequestsOO
    @StateObject var friendRequestFunction = FriendRequestsFunctions()
    @StateObject var friendProfile = FriendProfileOO()
    @State var showLoading : Bool = false
    @State var profileMatchedGeometry = ""
    @StateObject var postVM  = PostVM()
    @State var isLoading = true
    @Environment(\.colorScheme) var colorScheme
     
    func openPostView(post : PostModel){
        postVM.openPost(commentLikeVM: CommentLikeVM(post: post, friendsDictionary: posts.friendsDictionary))

//        id = post.id
    }
    
    func openPostView(postID: String, friendId: String?){
        
        if let post = posts.getPost(postID){
            openPostView(post: post)
        }else if let friendId =  friendId {
            showLoading = true
            notifications.fetchPost(postID: postID, friendId: friendId) { postModel, errorString in
                showLoading = false
                if let post = postModel{
                    openPostView(post: post)
                }else{
                    print(errorString ?? "")
                    alert.alertDetail = errorString ?? "This moment was forgotten"//"something went wrong, was not able to get the post"
                }
            }
        }else{
            print("we did not have a post creator id to fetch the post")
        }
    }
    
    func getPostRelatedNotificationView(item : Notification,
                                        notifType: Notification.Kind ) -> some View {
        
       return InvidivualNotification(id: item.sentFromUser,
                               timeString: item.timeString,
//                               post: postInfo,
                               nameOfSendingUser: item.nameOfSendingUser,
                               webLink: item.webLink,
                               notificationType: notifType,
                               FriendProfileMatchedGeometryEffect: $FriendProfileMatchedGeometryEffect)
            
            .matchedGeometryEffect(id: UUID(), in: namespace)
            .contentShape(Rectangle())
            .onTapGesture {
                    openPostView(postID: item.resourceID, friendId: item.originalAuthor)
//                }
            }
            .padding(.bottom, 5)
            .padding(.top, 5)
            .onChange(of: FriendProfileMatchedGeometryEffect) { newValue in
                if newValue.isNotEmpty,
                   !isAFriend(id: FriendProfileMatchedGeometryEffect) {
                    FriendProfileMatchedGeometryEffect = ""
                }
            }
    }
    
    var scrollView : some View {
        
        ScrollView() {
            LazyVStack() {
                Rectangle()
                        .frame(width: screenWidth, height: 4)
                        .foregroundColor(Color.mainColorInverse.opacity(0.35))
                ForEach(notifications.notifications.values.sorted(by: {$0.createdAt.dateValue().timeIntervalSinceNow > $1.createdAt.dateValue().timeIntervalSinceNow}), id: \.self) { item in
                    Group {
                        
                        if let notifType = item.notificationType?.getIfPostRelatedNotification()
                        /*, let friendId = item.postCreatorId */ {
                            getPostRelatedNotificationView(item: item,
                                                           notifType: notifType )
//                            Divider()
                            Rectangle()
                                    .frame(width: screenWidth, height: 4)
                                    .foregroundColor(Color.mainColorInverse.opacity(0.35))
                            
                        }
                      
                        if item.resourceType == "friendRequest" {
                            InvidivualNotification(id: item.sentFromUser,
                                                   timeString: item.timeString,
                                                   notificationType: .friendRequest,
                                                   FriendProfileMatchedGeometryEffect: $FriendProfileMatchedGeometryEffect)

                                .matchedGeometryEffect(id: UUID(), in: namespace)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    getFriendRequestUser(id: item.sentFromUser)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        OpenedFriendRequestMatchedGeometryEffect = item.sentFromUser
                                    }
                                    if newFriendRequest.newRequest == true {
                                        friendRequestFunction.readFriendRequest()
                                    }
                                }
                                .padding(.bottom, 5)
                                .padding(.top, 5)
//                            Divider()
                            Rectangle()
                                    .frame(width: screenWidth, height: 4)
                                    .foregroundColor(Color.mainColorInverse.opacity(0.35))

                        }
                        if item.resourceType == "acceptedRequest" {
                            InvidivualNotification(id: item.resourceID, timeString: item.timeString, notificationType: .acceptedRequest, FriendProfileMatchedGeometryEffect: $FriendProfileMatchedGeometryEffect)
                                .matchedGeometryEffect(id: UUID(), in: namespace)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard isAFriend(id: item.resourceID) else { return  }
                                        FriendProfileMatchedGeometryEffect = item.resourceID
                                }
                                .padding(.bottom, 5)
                                .padding(.top, 5)
//                            Divider()
                            Rectangle()
                                    .frame(width: screenWidth, height: 4)
                                    .foregroundColor(Color.mainColorInverse.opacity(0.35))
                        }
                        if item.resourceType == "sharedF" {
                            InvidivualNotification(id: item.sentFromUser, timeString: item.timeString, webLink: item.webLink, notificationType: .sharedF, FriendProfileMatchedGeometryEffect: $FriendProfileMatchedGeometryEffect, sentFromUser: item.sentFromUser)
                                .matchedGeometryEffect(id: UUID(), in: namespace)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard isAFriend(id: item.resourceID) else { return  }
                                    StrangerProfileSelectedItem = Person(id: item.resourceID, username: "", name: item.nameOfSharedFriend, bio: "", imageurl: "", webLink: item.webLink, token: "", accountCreationDate: Timestamp(), profileCircle: .clear)
                                    StrangerProfileMatchedGeometry = "0"
                                }
                                .padding(.bottom, 5)
                                .padding(.top, 5)
//                            Divider()
                            Rectangle()
                                    .frame(width: screenWidth, height: 4)
                                    .foregroundColor(Color.mainColorInverse.opacity(0.35))
                        }
                    }
                }
            } .padding(.top, 10)
        }
    }
    
    func isAFriend(id : String) -> Bool {
        if let _ = friendsDictionary.friendsDictionary[id] {
            return true
        }
        friendProfile.fetchFriend(id: id)
        profileMatchedGeometry = "0"
        showLoading = true
        return false
    }
    
    var body: some View {
        ZStack {
            Color.mainColorInverse.opacity(1.0)
                .edgesIgnoringSafeArea(.all)
            (colorScheme == .light ?
            Color.plumWeb.opacity(0.2) : Color.speakerPurple.opacity(0.2))
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack (spacing: 16) {
#if os(iOS)
                    Button(action: {
                        NotificationstMatchedGeometry = ""
                    }){
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .padding(.leading)
                            .foregroundColor(Color.mainColor.opacity(0.7))
                            
                    }.buttonStyle(.borderless)
#endif 
                    Text("Notifications")
                        .fontWeight(.bold)
                        .font(.title)
//                      .foregroundColor(Color.mainColor)
#if os(macOS)
                        .padding(.leading,10)
#endif
                    Spacer()
                }
                Spacer()
                ZStack {
                scrollView
                    if notifications.notifications.isEmpty && isLoading == false {
                        Text("NO NOTIFICATIONS")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.mainColor.opacity(0.2))
                            .offset(y: -50)
                    }
                }
                
            } // VStack, Main Container
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(){
                        isLoading = false
                    }
                }
            }
#if os(iOS)
            .padding(.top, 60)
#elseif os(macOS)
            .padding(.top, 20)
#endif
 
            if let commentLikeVM = postVM.commentLikeVM {
                OpenPostNotificationTabView(commentLikeVM : commentLikeVM,
                                             postVM: postVM)
                    .ignoresSafeArea(.all)
                
#if os(iOS)
            .padding(.top, 10)
#endif
            }
            if OpenedFriendRequestMatchedGeometryEffect != "" {
                FriendRequestsTabView(searchFriendRequestMatchedGeometry: $OpenedFriendRequestMatchedGeometryEffect)
#if os(macOS)
                    .padding(.top, -60)
#endif 
            }
            if FriendProfileMatchedGeometryEffect != "" {
                FriendProfileAllFriendsTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometryEffect, id: FriendProfileMatchedGeometryEffect)
#if os(macOS)
                    .padding(.top, 20)
#endif
            }
            if StrangerProfileMatchedGeometry != "" {
                StrangerProfileFromNotificationsTabView(ProfileMatchedGeometry: $StrangerProfileMatchedGeometry, person: ProfileOO(id: StrangerProfileSelectedItem.id), id: StrangerProfileSelectedItem.id)
            }
            strangerView
            if showLoading {
                
                VStack(spacing : 0) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.speakerPurple))
                        .scaleEffect(3.0)
                }.frame(width: screenWidth*0.6, height: 200, alignment: .center)
                .animation(.easeOut)
            }
            
        }
#if os(iOS)
        .padding(.top, -60)
#endif
    }
     
    var strangerView : some View {
         friendProfile.person.map { person in
                StrangerProfileTabView(ProfileMatchedGeometry: $profileMatchedGeometry,
                                       person: person,
                                       id: person.id)
                    .onChange(of: profileMatchedGeometry) { val in
                        if val == "" {
                            friendProfile.refresh()
                        }
                    }
            }?.onAppear{
                showLoading = false
            }
#if os(macOS)
            .padding(.top, -40)
#endif
    }
    
    func getFriendRequestUser(id: String) {
        Person.fetchFriend(id: id){  (person, error) in
            if let person = person{
                OpenedFriendRequestSelectedItem = person
            }else if let error = error{
                print("getFriendRequestUser error \(error.localizedDescription)")
            }
        } 
    }
}

 

 
struct OpenPostNotificationTabView: View {
    @State var selectedTab = "openedPost" 
    @StateObject var commentLikeVM : CommentLikeVM
    @ObservedObject var postVM : PostVM
    var postData: PostModel {
        commentLikeVM.post
    }
    var body: some View {
        if selectedTab == "openedPost" {
            ZStack { 
                //we need mentions vm here as a environmendObject as well
                let openedPostController =   OpenedPostController(
                    myTags: MyTagsOO(), comments: CommentsOO(id: postData.id, postID: postData.postID),
                    likes: LikesOO(id: postData.id, postID: postData.postID),
                    hasBeenLikedOO: HasPostBeenLikedOO(id: postData.id, postID: postData.postID),
                    commentLikeVM: commentLikeVM,
                    postVM: postVM, showUpdatePost: .constant(nil), show: .constant(false), buttonAlertType: .constant(.none), lockedMomentAlert: .constant(false), themeController: ThemeController())
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    openedPostController
                        .tag("openedPost")
                        .padding(.top, iOS15 ? 0 : 40)
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                openedPostController
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() { 
                    postVM.dismissOpenedPost()
                }
            
        }
    }
}

struct NotificationsTabView: View {
    @Binding var NotificationstMatchedGeometry: String
    @State var selectedTab = "Notifications"
    @State var emptyBoolBinding = false
    @ObservedObject var newFriendRequest: UnreadFriendRequestsOO

    var body: some View {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    Notifications(NotificationstMatchedGeometry: $NotificationstMatchedGeometry, newFriendRequest: newFriendRequest)
                        .tag("Notifications")
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
                
            }
            .ignoresSafeArea(edges: .top)
            //the real solution
            .onReceive(selectedTab.publisher) { (_) in
                if selectedTab != "Notifications", !NotificationstMatchedGeometry.isEmpty {
                    NotificationstMatchedGeometry = ""
                }
            }
    }
}


 
struct StrangerProfileNotificationTabView: View {
    @Binding var OpenedFriendRequestMatchedGeometryEffect: String
    @State var person: Person
    @State var id: String
    @State var selectedTab = "strangerProfile"
    var body: some View {
        if selectedTab == "strangerProfile" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    StrangerProfile(ProfileMatchedGeometry: $OpenedFriendRequestMatchedGeometryEffect, person: person, friendshipStatus: StrangerProfileOO(id: id), mutualFriends: MutualFriendsOO(id: id, tagMembers: [Person]()))
                        .tag("strangerProfile")
                        .padding(.top, 10)
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    OpenedFriendRequestMatchedGeometryEffect = ""
                }
            
        }
    }
}
