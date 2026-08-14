//
//  CurrentUserProfile.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/6/21.
//
 
import SwiftUI
import SDWebImageSwiftUI
import Firebase

 /*
  so as we have decided to update this view. i think first thing i should do is remove the duplication. then i should try to ran it
  */
struct CurrentUserProfile: View {
    @Namespace var namespace
    @Binding var ProfileMatchedGeometry: String
    @State var EditProfileMatchedGeometry: String = ""
    @StateObject var postData : FriendsPostsOO  
    @State var id: String
    @State var emptyStringBinding = "" 
    @ObservedObject var friendsDictionary: FriendsDictionary
    @StateObject var login = LoginOO()
    @Binding var signOut: Bool
    @Environment(\.colorScheme) var colorScheme
    @State var isChangedPictureMessageShowing = false
    @StateObject var myTags = MyTagsOO()
    @State var isShowingContextMenu = false
    @State var isInfoPopUpShowing = false
    @State var isSavedPostsShowing = false
    @State var isDeletePostAlertShowing: Bool = false
    @EnvironmentObject var timelinePosts: TimelinePostsOO
//    @State var deletedPo stID = ""
    @State var deletedPost : PostModel?
    @StateObject var savePost = SavePostFunction()
    @StateObject var shareActivity = ShareActivityOO()
    @State var showQRScanner : Bool = false
     
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var OpenedPhotoSelectedItem: URL?
    @StateObject var mentionedUserVM: MentionedUserVM
    @State var isFirstResponder: Bool = false
    @StateObject var postVM = PostVM()
    @State var showUpdatePost : PostModel?
    @ObservedObject var themeController: ThemeController
    @State var buttonAlertType: ButtonAlertType = .none
    @AppStorage("themesAlert") var themesAlert : Bool = false
#if os(macOS)
    var isFromMacOSHome = false
#endif
    var topbarView : some View {
        HStack (spacing: 16) {  // Navigation Bar
            
            let returnButton =  Button(action: {
                ProfileMatchedGeometry = ""
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .padding(.leading)
            }.buttonStyle(.borderless)
//            Text("My Profile")
//                .fontWeight(.bold)
//                .font(.title)
#if os(iOS)
//            returnButton
            TitleHeader(title: "My Profile") {
                ProfileMatchedGeometry = ""
            }
#elseif os(macOS)
            if isFromMacOSHome{
                Spacer().frame(width: 1)
            }else{
                returnButton
            }
#endif
            Spacer()
            HStack (spacing: 10) {
               
                Button(action: {
                    withAnimation {
//                        isShowingContextMenu = true
                        EditProfileMatchedGeometry = "0"
                    }
                }){
//                    ZStack {
//                        Text(".")
//                            .font(.largeTitle)
//                            .offset(y: -7)
//                        Text(".")
//                            .font(.largeTitle)
//                        Text(".")
//                            .font(.largeTitle)
//                            .offset(y: 7)
//                    }
                    Image(systemName: "pencil")
                        .font(.title3.weight(.bold))
                }.buttonStyle(.borderless)
//                    .padding(.top, -10)
            }  .padding(.trailing)
            
        }
      .foregroundColor(Color.black)
    }
     
    var presentAbleViews : some View{
        Group{
            if let selectedCommentLikeVM = postVM.commentLikeVM {
                    ZStack{
                        let view = OpenedPostTabView(isFromProfile: true,
                                                      commentLikeVM : selectedCommentLikeVM,
                                                      postVM: postVM, showUpdatePost: $showUpdatePost, myTags: myTags)
                        if isLargeScreen {
                            view
                                .ignoresSafeArea(.all)
                                .padding(.top, 10)
                        }else{
                            view
                        }
                    }
            }
            if buttonAlertType != .none {
                ButtonTapAlertController(buttonAlertType: $buttonAlertType, themeController: themeController)
            }
            if EditProfileMatchedGeometry != "" {
                EditProfileTabView(EditProfileMatchedGeometry: $EditProfileMatchedGeometry, signOut: $signOut, isShowingChangedProfilePictureMessage: $isChangedPictureMessageShowing, themeController: themeController)
            }
            if OpenedPhotoMatchedGeometry != "" {
                OpenPhotoTabView(OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, photo: OpenedPhotoSelectedItem, isFromTimeline: true)
                    .onAppear(perform: postVM.removeViewInfo)
                    .onDisappear(perform: postVM.setViewInfo)
                
            }
            if isShowingContextMenu != false {
                EditProfileContextMenu(isInfoPopUpShowing: $isInfoPopUpShowing, EditProfileMatchedGeometry: $EditProfileMatchedGeometry, isShowingContextMenu: $isShowingContextMenu, isSavedPostsShowing: $isSavedPostsShowing, showQRScanner: $showQRScanner, shareActivity: shareActivity)
            }
            if isInfoPopUpShowing != false {
                InfoPopUp(isInfoPopUpShowing: $isInfoPopUpShowing, functionType: .feedbackRequest)
            }
            if isSavedPostsShowing != false {
                SavedPostTabView(myTags: myTags, friendsDictionary: friendsDictionary, isSavedPostsShowing: $isSavedPostsShowing)
            }
#if os(iOS)
            presntingViews
#endif
            
        }
    }
 
    var userInfoView : some View{
        VStack{
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
                    .onTapGesture {
                        
                        EditProfileMatchedGeometry = "0"
                        
                    }
                Image(systemName: "sparkles")
                        .foregroundColor(.black)
                    .font(.largeTitle)
                    .offset(x: -8, y: -20)
                

            }
            .padding(.top, 20)
           let vstack = VStack (spacing: 5) { // Username, name, and bio
                HStack (spacing: 5) {
                    Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("-")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                        .font(.headline)
                        .fontWeight(.bold)
                }
//                Text(friendsDictionary.friendsDictionary[id]?.bio ?? "")
//                    .padding(.horizontal)
//                    .font(.footnote)
//                    .multilineTextAlignment(.center)
            } // Username, name, and bio
          .foregroundColor(Color.black)
          .offset(y: 3)
//            .padding(.bottom, 5)
            
            isLargeScreen ?
            vstack.padding(.vertical) :
            vstack.padding(.vertical, 10)
            
        }
    }
    var postsVStack : some View{
        
           LazyVStack {
               
               ForEach( postData.sortedPostss , id: \.post.self) {  commentLikeVM in
                   let item = commentLikeVM.post
                   
                   //                   TimelineMoment(id: item.id,
                   //                                  friendProfileSelectedItem: $emptyStringBinding,
                   //                                  FriendProfileMatchedGeometry: $emptyStringBinding,
                   //                                  friendsDictionary: timelinePosts.friendsDictionary,
                   //                                  myTags: myTags,
                   //                                  isDeletePostAlertShowing: $isDeletePostAlertShowing,
                   //                                  deletedPost: $deletedPost,
                   //                                  OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry,
                   //                                  OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,
                   //                                  commentLikeVM :   commentLikeVM.getSelf() ,
                   //                                  isFirstResponder: $isFirstResponder,
                   //                                  mentionedUserVM: mentionedUserVM,
                   //                                  LongPostMatchedGeometry: $emptyStringBinding,
                   //                                  postVM: postVM) {
                   ////                                                withAnimation(.easeIn(duration: 0.3)) {
                   //
                   //                        postVM.openPost(commentLikeVM: commentLikeVM)
                   //                        }
                   VStack {
                   Rectangle()
                       .frame(width: screenWidth, height: 5)
                       .foregroundColor(Color.mainColorInverse)
                   TimelineMoment2(id: item.id,
                                   friendProfileSelectedItem: .constant(""),
                                   FriendProfileMatchedGeometry: .constant(""),
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
                                   .contextMenu {
                                       VStack {
                                           if item.id == currentUserID {
                                               
//                                               Button("Edit") {
//                                                   showUpdatePost = item
//                                               } .font(.headline)
                                               Button("Delete") {
                                                   isDeletePostAlertShowing = true
                                                   deletedPost = item
                                               }.font(.headline)
                                           }
                                           if item.hasSubscribed ?? false {
                                               Button(action: {
                                                   //                                savePost.savePost(postID: item.postID, postAuthor: item.id)
                                                   //                                SubscribeToPost.unsubscribeToPostCloudFunction(postID: postData.postID, originalAuthor: postData.id)
                                                   commentLikeVM.unSubcribePost()
                                                   
                                               }) {
                                                   Text("Pause Notifications")
                                                       .font(.headline)
                                               }
                                           }
                                       }
                                   }
               }
           }
       }


    }
    let isLargeScreen : Bool = screenWidth > 375
    var body: some View {
        
                ZStack {
                    themeController.theme.primary
                        .edgesIgnoringSafeArea(.all)
                    ZStack{
                        
                    VStack (spacing: 10) {
                        topbarView
                        
                        ScrollView(showsIndicators: false) {
                            VStack {
                                userInfoView
                                postsVStack
                            }
                         } // Scrollview, Container for Profile Picture, Username, Name, Bio, and Posts
                        .environmentObject(mentionedUserVM)
#if os(iOS)
                        Spacer() // Pushes contents to the top of the Main Container
#endif
                    } // VStack, Main Container
//
                    }
                    .disabled(isShowingContextMenu || isInfoPopUpShowing || showUpdatePost != nil ? true : false)
                    .blur(radius: isLargeScreen ? (isShowingContextMenu || isInfoPopUpShowing || showUpdatePost != nil ? 10 : 0) : (isShowingContextMenu || showUpdatePost != nil  ? 10 : 0))
                    .padding(.top, 48)
                    .alert(isPresented: $isDeletePostAlertShowing) {
                        Alert(
                            title: Text("Delete this moment??"),
                                       primaryButton: .destructive(Text("Delete")) {
                                        if let post = deletedPost{
                                            timelinePosts.delete(post: post)
                                            postData.postDeletePublisher.send(post.postID)
                                        }
//                                        deletePostFunction.deletePost(postID: deletedP ostID, isThere APhoto: isT hereAPhoto)
                                           print("Deleting...")
                                       },
                                       secondaryButton: .cancel()
                                   )
                    }
                    
                    presentAbleViews
                } // ZStack
                .ignoresSafeArea(.all)
                .padding(.top, iOS15 ? -60 : -60)
                .onTapGesture {
                    if isShowingContextMenu != false {
                        isShowingContextMenu = false
                    }
                }.ignoresSafeArea(edges: .all)
            .onAppear {
                if themesAlert == false {
                    withAnimation() {
                        buttonAlertType = .themes
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            themesAlert = true
                        }
                    }
                }
            }
#if os(iOS)
                .padding(.top, iOS15 ? 60 : 0)
#elseif os(macOS)
                .padding(.top, -40)
#endif
   
    }
    
#if os(iOS)
    var presntingViews : some View {
        ZStack{
            if let showUpdatePost = showUpdatePost{
                EditMomentTabView(showUpdatePost: $showUpdatePost)
//                        UpdatePost(showUpdatePost: $showUpdatePost, updatePostVM: UpdatePostVM(post: showUpdatePost))
            }
            if showQRScanner{
                QRScannerView(showQRScanner : $showQRScanner)
            }
            if let _ = shareActivity.qrCodeImageData {
                QRCodeView(qrCodeImageData: $shareActivity.qrCodeImageData)
            } 
            if let _ = shareActivity.shareURL {
                ActivityViewController(shareURL: $shareActivity.shareURL )
            }

        }
    }
#endif
}

struct CurrentUserProfileTabView: View {
    @Binding var ProfileMatchedGeometry: String
    @State var id: String
    @State var selectedTab = "Profile"
    @Binding var signOut: Bool
    @ObservedObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @StateObject var themeController = ThemeController()
    var body: some View {
        if selectedTab == "Profile" {
            ZStack {
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    if let _ = currentUserID {
//                        FriendProfile(FriendProfileMatchedGeometry: $ProfileMatchedGeometry,friendsDictionary:friendsDictionary, postData: FriendsPostsOO(id: id, friendsDictionary: timelinePosts.friendsDictionary), id: id, mentionedUserVM: MentionedUserVM(friendsDictionary: friendsDictionary))
                         
                        CurrentUserProfile(ProfileMatchedGeometry: $ProfileMatchedGeometry, postData: FriendsPostsOO(id: id, friendsDictionary: timelinePosts.friendsDictionary), id: id, friendsDictionary: friendsDictionary, signOut: $signOut, mentionedUserVM: MentionedUserVM(friendsDictionary: friendsDictionary), themeController: themeController)
                            .tag("Profile")
                    } else {
                        LoginController2(isSuccessful: false)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                if let _ = currentUserID {
                    CurrentUserProfile(ProfileMatchedGeometry: $ProfileMatchedGeometry, postData: FriendsPostsOO(id: id), id: id, friendsDictionary: friendsDictionary, signOut: $signOut, mentionedUserVM: MentionedUserVM(friendsDictionary: friendsDictionary))
                        .tag("Profile")
                }
                 
//                else {
//#if os(iOS)
//                        LoginController2(isSuccessful: false)
//#endif
//                    }
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
            //            Hom e(signOut: $signOut)
            EmptyView()
                .onAppear() {
                    ProfileMatchedGeometry = ""
                }
        }
    }
     

}
/*
 we need to replace selectedPost with selectedCommentLikeVM
 */
