//
//  TimelineMainView.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/15/21.
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
    @ObservedObject var postVM : PostVM
    @State var EditPostMatchedGeometry = "" 
    var timeline : some View{
        VStack{
            
        
            List {
//                ForEach(Array(timelinePosts.postInfoValues.enumerated()), id: \.element.post) { index, commentLikeVM in
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
                                postVM: postVM)
    

                }

                
                if  timelinePosts.showProgress{
                    HStack {
                        //                        ProgressView()
                        //                            .colorScheme(colorScheme)
                        //                            .progressViewStyle(CircularProgressViewStyle())
                        
                        ActivityIndicator()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.speakerPurple)
                            .padding()
                            .background(colorScheme == .light ? Color.white : Color.black)
                    }
                    .frame(width: screenWidth)
                    .background(colorScheme == .light ? Color.white : Color.black)
                    .offset(y: -10)
                }
                
                if !timelinePosts.postInfoValues.isEmpty {
                    Divider()
                }
                 
               //MARK: - preloaded posts
                
                  
                ForEach(timelinePosts.preloadedCommentLikeVM , id: \.post.self) { commentLikeVM in
                     TimelineMoment(id: commentLikeVM.post.id,
                                    friendProfileSelectedItem: $friendProfileSelectedItem,
                                    FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                                    friendsDictionary: timelinePosts.friendsDictionary,
                                    myTags: myTags,
                                    isDeletePostAlertShowing: $isDeletePostAlertShowing,
                                    deletedPost: $deletedPost,
                                    OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry,
                                    OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,
                                    commentLikeVM : commentLikeVM,
                                    isFirstResponder: $isFirstResponder,
                                    mentionedUserVM: mentionedUserVM,
                                    LongPostMatchedGeometry: $emptyStringBinding,
                                    postVM: postVM){ 
                         guard commentLikeVM.post.status != .sending  else{ return }
                         postVM.openPost(commentLikeVM: commentLikeVM)
                         isFirstResponder = false
                     }
//                        TimelinePost(id: item.id, friendProfileSelectedItem: $friendProfileSelectedItem, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, friendsDictionary: timelinePosts.friendsDictionary, postData: item, myTags: myTags, isDeletePostAlertShowing: $isDeletePostAlertShowing, deletedPost: $deletedPost )
                         .listRowInsets(EdgeInsets(top: 8, leading: screenWidth < 376 ? 12 : 8, bottom: 0, trailing: 0))
//                            .padding(.horizontal,8)
//                            .onTapGesture {
//                                ///user can only open post if it has been sent.
//                                guard item.status != .sending  else{
//                                    return
//                                } 
//                                OpenedPostMatch edGeometry = "0"
//                                //                                }
//                            }
                            .padding(.top, -10)
                            .contextMenu {
                                VStack {
                                    Button(action: {
                                        savePost.savePost(postID: commentLikeVM.post.postID, postAuthor: commentLikeVM.post.id)
                                    }) {
                                        Text("Save")
                                            .font(.headline)
                                    }
                                    if commentLikeVM.post.id == Auth.auth().currentUser?.uid {
                                        Button(action: {
                                            isDeletePostAlertShowing = true
                                            deletedPost = commentLikeVM.post
                                        }) {
                                            Text("Delete")
                                                .font(.headline)
                                        }.buttonStyle(.borderless)
                                    }


                                }
                            }
                    }.listRowBackground(Color.mainColor.opacity(colorScheme == .light ? 0.05 : 0.00))
                //MARK: - preloaded posts ended
                Spacer().frame( height: UIApplication.getSafeAreaTopInsets())
                    .background(colorScheme == .light ? Color.white : Color.black)
                    .offset(y: -10)
                    
                //            }
            } // SCROLLVIEW
            .environmentObject(mentionedUserVM)
#if os(iOS)
            .padding(.top, -40)
#elseif os(macOS)
            .padding(.top, -10)
#endif

         
            .listStyle(SidebarListStyle())
            //        .padding(.top, -50)
//            if !timelinePosts.postInfoValues.isEmpty {
//                //                Color.red
//            } else {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle())
//                    .offset(y: phoneHeight/2.3)
//            }
//            preloadedPosttimeline
           
        } .edgesIgnoringSafeArea(.top)
//
    }
    
    var body: some View {
        ZStack {
        timeline
            if let showUpdatePost = showUpdatePost{
                EditMomentTabView(showUpdatePost: $showUpdatePost)
                    .padding(.horizontal, 28)
//                        UpdatePost(showUpdatePost: $showUpdatePost, updatePostVM: UpdatePostVM(post: showUpdatePost))
            }
        if FriendProfileMatchedGeometry.isNotEmpty  {
//            if friendProfileSelectedItem == "" {
//                let  _ =   assert(false, " what happend friendProfileSelectedItem   ")
//            }
            FriendProfileHomeTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: friendProfileSelectedItem)
                .padding(.horizontal, 28)
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
