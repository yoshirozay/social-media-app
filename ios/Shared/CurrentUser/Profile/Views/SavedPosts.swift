//
//  SavedPosts.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/6/21.
//


import SwiftUI
import SDWebImageSwiftUI
import Firebase
  
struct SavedPosts: View {
    @Binding var isSavedPostsShowing: Bool
    @StateObject var savedPosts = SavedPostsOO()
    @StateObject var deleteSavedPost = SavePostFunction()
    @State var emptyBoolBinding = false
    @State var emptyStringBinding = ""
    @State var FriendProfileMatchedGeometry: String = ""
    @ObservedObject var myTags: MyTagsOO
    @State var isDeletePostAlertShowing: Bool = false
    @State var deletedPost : PostModel?
    @ObservedObject var friendsDictionary: FriendsDictionary 
    @Environment(\.colorScheme) var colorScheme
#if os(macOS)
    @Binding var isSavedPostsShowing : Bool
#endif
    @StateObject var mentionedUserVM : MentionedUserVM
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @StateObject var postVM = PostVM()
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var OpenedPhotoSelectedItem: URL?
    @State var showUpdatePost : PostModel?
    @State var friendProfileSelectedItem: String = ""
    var body: some View {
        ZStack {
            Color.mainColorInverse
                .edgesIgnoringSafeArea(.all)
            (colorScheme == .light ?
            Color.plumWeb.opacity(0.2) : Color.speakerPurple.opacity(0.2))
                .edgesIgnoringSafeArea(.all)
            VStack {
            HStack (spacing: 16) {
                Button(action: {
                    isSavedPostsShowing = false
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding(.leading)
                        .foregroundColor(Color.mainColor)
                }
                Text("Saved Moments")
                    .fontWeight(.bold)
                    .font(.title)
                    .foregroundColor(Color.mainColor)
                Spacer()
            }
            List {
#if os(macOS)
                HStack{
                    Button(action: {isSavedPostsShowing = false}){
                        MacOsDismissButton(matchedGeometry: .constant(""))
                    }
                    Spacer()
                }.buttonStyle(.borderless)
                .padding(.leading,20)
                .padding(.top,30)
//                .offset(y:10)
#endif
                ForEach(savedPosts.postInfo.sorted(by: {$0.updatedAt.dateValue().timeIntervalSinceNow > $1.updatedAt.dateValue().timeIntervalSinceNow}), id: \.self) { item in
//
//                TimelinePost(id: item.id, friendProfileSelectedItem: $emptyStringBinding, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, friendsDictionary: friendsDictionary, postData: item, myTags: myTags, isDeletePostAlertShowing: $isDeletePostAlertShowing, deletedPost: $deletedPost)
                    TimelineMoment(id: item.id, friendProfileSelectedItem: $friendProfileSelectedItem, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, friendsDictionary: timelinePosts.friendsDictionary, myTags: myTags, isDeletePostAlertShowing: $isDeletePostAlertShowing, deletedPost: $deletedPost, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,commentLikeVM : CommentLikeVM(post: item, friendsDictionary: timelinePosts.friendsDictionary), isFirstResponder: $emptyBoolBinding,mentionedUserVM: mentionedUserVM, LongPostMatchedGeometry: $emptyStringBinding, postVM: postVM)
                    
                    .onTapGesture {
                          postVM.openPost(commentLikeVM: CommentLikeVM(post: item, friendsDictionary: timelinePosts.friendsDictionary))
//                                }
                    }
                    .padding(.bottom, -10)
                    .contextMenu {
                        VStack {
                            Button(action: {
                                deleteSavedPost.deleteSavedPost(postID: item.postID, postAuthor: item.id)
                                savedPosts.removePost(postID: item.postID)
                            }) {
                                Text("Forget")
                                    .font(.headline)
                            }



                        }
                    }
            }
//                .listRowBackground(Color.mainColor.opacity(colorScheme == .light ? 0.05 : 0.00))
                    .listRowInsets(EdgeInsets(top: 8, leading: screenWidth < 376 ? 12 : 8, bottom: 0, trailing: 0))
            } .listStyle(SidebarListStyle())
                    .padding(.horizontal, -32)
                    .padding(.top, -30)
                    .clipped()
             

        }
            .padding(.top, 60)
            if let commentLikeVM = postVM.commentLikeVM  {
                OpenedPostTabView(commentLikeVM: commentLikeVM,
                              postVM: postVM, showUpdatePost: $showUpdatePost, myTags: myTags)
                    .transition(.opacity)
//                        .padding(.horizontal, 32)
                .padding(.top, 60)
        }
        }
        .padding(.top, iOS15 ? -50 : 0)
        .ignoresSafeArea(edges: .bottom)
    }
}

struct SavedPostTabView: View {
   
    @State var selectedTab = "openedPost"
    @ObservedObject var myTags: MyTagsOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @Binding var isSavedPostsShowing: Bool
    var body: some View {
        if selectedTab == "openedPost" {
            ZStack {
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    SavedPosts(isSavedPostsShowing: $isSavedPostsShowing, myTags: myTags, friendsDictionary: friendsDictionary, mentionedUserVM: MentionedUserVM(friendsDictionary: friendsDictionary))
                        .tag("openedPost")
                    
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                SavedPosts(myTags: myTags, friendsDictionary: friendsDictionary,isSavedPostsShowing : $isSavedPostsShowing, mentionedUserVM: MentionedUserVM(friendsDictionary: friendsDictionary))
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {

            EmptyView()
                .onAppear() {
                    isSavedPostsShowing = false
                }
            
        }
    }
}
