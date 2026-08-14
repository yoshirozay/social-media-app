//
//  TimelineRow.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/30/22.
//

import SwiftUI 
import SDWebImageSwiftUI 

 
struct TimelineRow : View {
    @State var hasBeenLiked = false
    @Binding var friendProfileSelectedItem: String
    @Binding var FriendProfileMatchedGeometry: String
    @Binding var isDeletePostAlertShowing: Bool
    @Binding var deletedPost : PostModel?
    @Binding var OpenedPhotoMatchedGeometry: String
    @Binding var OpenedPhotoSelectedItem: URL?
    @Binding var isFirstResponder: Bool
    @Binding var LongPostMatchedGeometry: String
    @Binding var showUpdatePost : PostModel?
    @StateObject var savePost = SavePostFunction()
    @StateObject var commentLikeVM : CommentLikeVM
    @ObservedObject var myTags: MyTagsOO
    @ObservedObject var mentionedUserVM : MentionedUserVM
    @ObservedObject var postVM: PostVM
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    var id: String {
        commentLikeVM.post.id
    }
    var item: PostModel{
        commentLikeVM.post
    }
    var body: some View {

        TimelineMoment(id: item.id,
                       friendProfileSelectedItem: $friendProfileSelectedItem,
                       FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                       friendsDictionary: timelinePosts.friendsDictionary,
                       myTags: myTags,
                       isDeletePostAlertShowing: $isDeletePostAlertShowing,
                       deletedPost: $deletedPost,
                       OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry,
                       OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,
                       commentLikeVM : commentLikeVM.getSelf(),
                       isFirstResponder: $isFirstResponder,
                       mentionedUserVM: mentionedUserVM,
                       LongPostMatchedGeometry: $LongPostMatchedGeometry,
                       postVM: postVM) {
                ///user can only open post if it has been sent.
                guard item.status != .sending  else{
                    return
                }
                postVM.openPost(commentLikeVM: commentLikeVM)
                isFirstResponder = false
//                commentLikeVM.readPost(postID: item.postID)
                //                                }
            }
        
            .onAppear {
                timelinePosts.getNextPageIfNeeded(post: item)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: screenWidth < 376 ? 12 : 8, bottom: 0, trailing: 0))
            .overlay( 
                    Color.clear
                    .contextMenu {
                        VStack {
                            if item.id == currentUserID {
                                
                                Button("Edit") {
                                    guard commentLikeVM.allowContextMenu else { return }
                                    showUpdatePost = item
                                } .font(.headline)
                              
                                Button("Delete") {
                                    guard commentLikeVM.allowContextMenu else { return }
                                    isDeletePostAlertShowing = true
                                    deletedPost = item
                                }.font(.headline)
                                       
                            }else {
                                Button("Save") {
                                    guard commentLikeVM.allowContextMenu else { return }
                                    savePost.savePost(postID: item.postID, postAuthor: item.id)
                                }.font(.headline)
                                 
                            }
                             
                            commentLikeVM.post.hasSubscribed?.falseIsNil.map { _ in
                                Button("Pause Notifications") {
                                    commentLikeVM.unSubcribePost()
                                }.font(.headline)
                                 .buttonStyle(.borderless)
                            }
                            
                        }
                    }.id(commentLikeVM.post.postID + String(describing: commentLikeVM.post.hasSubscribed))
            )
            .overlay(
                commentLikeVM.post.isDummy.falseIsNil.map { _ in
                    ZStack{
                        Color.red.opacity(0.0001)
                        ProgressViewPurpleCircular().scaleEffect(3)
                            .frame(width: screenWidth/2)
                            .rightInHStack
                    }
                })
    }
}

