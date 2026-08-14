//
//  HomeTL.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import SwiftUI
import CoreData
import SDWebImageSwiftUI
import Firebase



struct TimelineMainView2: View {
    @Namespace var namespace
    @Binding var friendProfileSelectedItem: String
    @Binding var FriendProfileMatchedGeometry: String
    @State var emptyBindingVariable = 0
    @State var emptyStringBinding = ""
    @State var emptyBindingBoolVariable = false
    @StateObject var myTags = MyTagsOO()
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @StateObject var savePost = SavePostFunction()
    @Binding var isDeletePostAlertShowing: Bool
    @Binding var deletedPost : PostModel?
    @Binding var OpenedPhotoMatchedGeometry: String
    @Binding var OpenedPhotoSelectedItem: URL?
    @Binding var isFirstResponder: Bool
    @Binding var showUpdatePost : PostModel?
    @StateObject var mentionedUserVM : MentionedUserVM
    @State var isLoading = true
    @StateObject var postVM = PostVM(addListener: false)
    @State var EditPostMatchedGeometry = ""
    @State var show = false
    @ObservedObject var currentTab: CurrentTab
    @ObservedObject var pushNotificationVM : PushNotificationVM
    @Binding var audioAlert: Bool
    @Binding var cameraAlert: Bool
    @State var buttonAlertType: ButtonAlertType = .none
    @AppStorage("lockedMomentAlert") var lockedMomentAlert : Bool = false
    @ObservedObject var themeController: ThemeController
    @Binding var hasCreatedAMoment: Bool
    @AppStorage("hasCreatedAMomentAlert") var hasCreatedAMomentAlert : Bool = false
    @Binding var newProfilePhoto: NewMedia?
    var timeline : some View{
        ZStack(alignment: .top) {
            ZStack {
                //                if timelinePosts.postInfoValues.isNotEmpty {
                if timelinePosts.postInfoValues.isEmpty && isLoading == false {
                    NewUserTimeline(timelinePosts: timelinePosts, friendsDictionary: timelinePosts.friendsDictionary, audioAlert: $audioAlert, cameraAlert: $cameraAlert, themeController: themeController, hasCreatedAMoment: $hasCreatedAMoment, newProfilePhoto: $newProfilePhoto)
                    
                } else {
                    if hasCreatedAMoment != true {
                        NewUserTimeline(timelinePosts: timelinePosts, friendsDictionary: timelinePosts.friendsDictionary, audioAlert: $audioAlert, cameraAlert: $cameraAlert, themeController: themeController, hasCreatedAMoment: $hasCreatedAMoment, newProfilePhoto: $newProfilePhoto)
                    } else {
                        VStack{
                            
                            
                            List {
                                ForEach( timelinePosts.postInfoValues , id: \.post.self) { commentLikeVM in
                                    TimelineRow(friendProfileSelectedItem: $friendProfileSelectedItem,
                                                FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                                                isDeletePostAlertShowing:  $isDeletePostAlertShowing,
                                                deletedPost:  $deletedPost,
                                                OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry,
                                                OpenedPhotoSelectedItem:  $OpenedPhotoSelectedItem,
                                                isFirstResponder: $isFirstResponder,
                                                LongPostMatchedGeometry: $emptyStringBinding,
                                                showUpdatePost: $showUpdatePost,
                                                commentLikeVM: commentLikeVM,
                                                myTags: myTags,
                                                mentionedUserVM: mentionedUserVM,
                                                postVM: postVM, show: $show, buttonAlertType: $buttonAlertType, lockedMomentAlert: $lockedMomentAlert, themeController: themeController)
                                    .id(commentLikeVM.post.postID)
                                    
                                }
                                .listRowBackground(Color.mainColorInverse)
                                //                            .listRowBackground(Color.mainColorInverse)
                                //                Spacer()
                                if  timelinePosts.showProgress{
                                    HStack {
                                        
                                        ActivityIndicator()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(themeController.theme.accent)
                                            .padding()
                                    }
                                    .frame(width: screenWidth)
                                    .offset(y: -10)
                                }
                                
                                //MARK: - preloaded posts
                                
                                //
                                //                            ForEach(timelinePosts.preloadedCommentLikeVM , id: \.post.self) { commentLikeVM in
                                //
                                //                                TimelineRow(friendProfileSelectedItem: $friendProfileSelectedItem,
                                //                                            FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                                //                                            isDeletePostAlertShowing: $isDeletePostAlertShowing,
                                //                                            deletedPost: $deletedPost,
                                //                                            OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry,
                                //                                            OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,
                                //                                            isFirstResponder: $isFirstResponder,
                                //                                            LongPostMatchedGeometry: $emptyStringBinding,
                                //                                            showUpdatePost: $showUpdatePost,
                                //                                            commentLikeVM : commentLikeVM,
                                //                                            myTags: myTags,
                                //                                            mentionedUserVM: mentionedUserVM,
                                //                                            postVM: postVM,
                                //                                            show: $show, isPreloadedMoment: true)
                                //                                .id(commentLikeVM.post.postID)
                                //
                                //                                .listRowInsets(EdgeInsets(top: 5, leading: screenWidth < 376 ? 12 : 8, bottom: 0, trailing: 0))
                                //                                .padding(.top, iOS15 ? 0 : -10)
                                //                            }
                                //                            //MARK: - preloaded posts ended
                                //                            Spacer().frame( height: UIApplication.getSafeAreaTopInsets())
                                //                                .background(colorScheme == .light ? Color.white : Color.black)
                                //                                .offset(y: -12)
                            } // SCROLLVIEW
                            //                        .modifier(ListBackgroundModifier())
                            .padding(.horizontal, -32)
                            .environmentObject(mentionedUserVM)
#if os(iOS)
                            .padding(.top, -40)
#elseif os(macOS)
                            .padding(.top, -10)
#endif
                            
                            
                            .listStyle(SidebarListStyle())
                        }
                    }
                }
            }
        }
//        .background(timelinePosts.postInfoValues.isNotEmpty ? timelinePosts.postInfoValues.count < 4 ? themeController.theme.primary.ignoresSafeArea() : Color.mainColorInverse.ignoresSafeArea() : themeController.theme.primary.ignoresSafeArea())
        .background(themeController.theme.primary.ignoresSafeArea())
        .onAppear {
            if hasCreatedAMoment != true {
                checkIfUserHasCreatedAMoment()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            timeline
                .fullSwipePop(show: $show) {
                    ZStack {
                        postVM.commentLikeVM.map{ commentLikeVM in
                            ZStack {
                                
                                let postData = commentLikeVM.post
                                OpenedPostController(
                                    myTags: myTags, comments: CommentsOO(id: postData.id, postID: postData.postID),
                                    likes: LikesOO(id: postData.id, postID: postData.postID),
                                    hasBeenLikedOO: HasPostBeenLikedOO(id: postData.id, postID: postData.postID),
                                    isFromProfile: false,
                                    isFirstResponder: isFirstResponder,
                                    commentLikeVM: commentLikeVM,
                                    postVM: postVM, showUpdatePost: $showUpdatePost, show: $show, buttonAlertType: $buttonAlertType, lockedMomentAlert: $lockedMomentAlert, themeController: themeController)
                                .id(commentLikeVM.post.postID)
                                .zIndex(pushNotificationVM.zIndex(.newPost))
                                .onDisappear {
                                    if currentTab.currentTab == "house.fill" {
                                        postVM.dismissOpenedPost()
                                    }
                                }
                            }
                            
                        }
                    }
                    .onDisappear(perform:  {
                        if currentTab.currentTab == "house.fill" {
                            postVM.dismissOpenedFriendTag()
                        }
                    })
                }
                .blur(radius: buttonAlertType != .none ? 10 : 0)
                .disabled(buttonAlertType != .none ? true : false)
            if buttonAlertType != .none {
                ButtonTapAlertController(buttonAlertType: $buttonAlertType, themeController: themeController)
            }
            if let showUpdatePost = showUpdatePost{
                EditMomentTabView(showUpdatePost: $showUpdatePost)
                    .padding(.horizontal, 28)
            }
            if FriendProfileMatchedGeometry.isNotEmpty  {
                FriendProfileHomeTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: friendProfileSelectedItem, themeController: themeController)
                    .padding(.horizontal, 28)
            }
            if OpenedPhotoMatchedGeometry != "" {
                OpenPhotoTabView(OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, photo: OpenedPhotoSelectedItem, isFromTimeline: true)
                    .padding(.top, iOS15 ? 0 : -60)
                
            }
            
            
        }
        .frame(width: screenWidth, height: screenHeight-66, alignment: .top)
        //        .ignoresSafeArea(.all)
        .onReceive( pushNotificationVM.$post) { post in
            if let post : PostModel = post {
                postVM.openPost(commentLikeVM: CommentLikeVM(post: post, friendsDictionary: timelinePosts.friendsDictionary))
                
                if currentTab.currentTab == "house.fill" {
                    withAnimation {
                        show = true
                    }
                } else {
                    show = true
                }
            }
        }
        .onReceive( postVM.$commentLikeVM) { commentLikeVM in
            if commentLikeVM == nil {
                pushNotificationVM.post = nil
            }
        }
        
    }
    func checkIfUserHasCreatedAMoment() {
        let colRef = Firestore.firestore().collection("Posts").document(currentUserID ?? "").collection("UserPosts")
        colRef.limit(to: 1).getDocuments {[self] (documents, error) in
            if error != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    colRef.limit(to: 1).getDocuments {[self] (documents, error) in
                        if error != nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                colRef.limit(to: 1).getDocuments {[self] (documents, error) in
                                    if documents?.documents.count ?? 0 > 0 {
                                        hasCreatedAMoment = true
                                        hasCreatedAMomentAlert = true
                                    } else {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            withAnimation {
                                                if hasCreatedAMomentAlert != true {
                                                    buttonAlertType = .firstMoment
                                                    hasCreatedAMomentAlert = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if documents?.documents.count ?? 0 > 0 {
                            hasCreatedAMoment = true
                            hasCreatedAMomentAlert = true
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    if hasCreatedAMomentAlert != true {
                                        buttonAlertType = .firstMoment
                                        hasCreatedAMomentAlert = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if documents?.documents.count ?? 0 > 0 {
                hasCreatedAMoment = true
                hasCreatedAMomentAlert = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        if hasCreatedAMomentAlert != true {
                            buttonAlertType = .firstMoment
                            hasCreatedAMomentAlert = true
                        }
                    }
                }
            }
        }
    }
}

struct ActivityIndicator: View {
    
    @State private var isAnimating: Bool = false
    
    var body: some View {
        GeometryReader { (geometry: GeometryProxy) in
            ForEach(0..<5) { index in
                Group {
                    Circle()
                        .frame(width: geometry.size.width / 5, height: geometry.size.height / 5)
                        .scaleEffect(calcScale(index: index))
                        .offset(y: calcYOffset(geometry))
                }.frame(width: geometry.size.width, height: geometry.size.height)
                    .rotationEffect(!self.isAnimating ? .degrees(0) : .degrees(365))
                    .animation(Animation
                        .timingCurve(0.5, 0.15 + Double(index) / 4, 0.75, 1, duration:  1.5)
                        .repeatForever(autoreverses: false))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .onAppear {
            self.isAnimating = true
        }
    }
    
    func calcScale(index: Int) -> CGFloat {
        return (!isAnimating ? 1 - CGFloat(Float(index)) / 5 : 0.2 + CGFloat(index) / 5)
    }
    
    func calcYOffset(_ geometry: GeometryProxy) -> CGFloat {
        return geometry.size.width / 10 - geometry.size.height / 2
    }
    
}
