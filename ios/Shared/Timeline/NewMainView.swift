//
//  NewMainView.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/10/22.
//

import SwiftUI
import CoreData
import SDWebImageSwiftUI
import Firebase

struct NewMainView: View {
    @Namespace var namespace
    @Binding var friendProfileSelectedItem: String
    @Binding var openedPostSelectedItem: PostModel
    @Binding var OpenedPostMatchedGeometry: String
    @Binding var FriendProfileMatchedGeometry: String
    @State var emptyBindingVariable = 0
    @State var emptyBindingBoolVariable = false
    @StateObject var myTags = MyTagsOO()
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @StateObject var savePost = SavePostFunction()
    @Binding var isDeletePostAlertShowing: Bool
    @Binding var deletedPost : PostModel?
    
    let columns = [GridItem(),GridItem()]
    
    var body: some View {
        VStack {
            let postInfoValues =  timelinePosts.postInfoValues//postInfoValues
            
            List  {
                LazyVGrid (columns: columns, spacing: 5) {
                    ForEach(postInfoValues , id: \.self) { item in
                        GridMoment(id: item.id, friendProfileSelectedItem: $friendProfileSelectedItem, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, friendsDictionary: timelinePosts.friendsDictionary, postData: item, myTags: myTags, isDeletePostAlertShowing: $isDeletePostAlertShowing, deletedPost: $deletedPost )
                        
                            .onTapGesture {
                                ///user can only open post if it has been sent.
                                guard item.status != .sending  else{
                                    return
                                }
                                openedPostSelectedItem = item
                                OpenedPostMatchedGeometry = "0"
                                //                                }
                            }
//                            .contextMenu {
//                                VStack {
//                                    Button(action: {
//                                        savePost.savePost(postID: item.postID, postAuthor: item.id)
//                                    }) {
//                                        Text("Save")
//                                            .font(.headline)
//                                    }
//                                    if item.id == Auth.auth().currentUser?.uid {
//                                        Button(action: {
//                                            isDeletePostAlertShowing = true
//                                            deletedPost = item
//                                        }) {
//                                            Text("Delete")
//                                                .font(.headline)
//                                        }.buttonStyle(.borderless)
//                                    }
//
//                                }
//                            }
                    }.listRowBackground(Color.mainColor.opacity(colorScheme == .light ? 0.05 : 0.00))
                    
                    if !timelinePosts.canScrollToNextPage, !timelinePosts.didFetchAllAvailabelPosts{
                        HStack {
                            ProgressView()
                                .colorScheme(colorScheme)
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                                .background(colorScheme == .light ? Color.white : Color.black)
                        }
                        .frame(width: screenWidth)
                        .background(colorScheme == .light ? Color.white : Color.black)
                        .offset(y: -10)
                    }
                                  }
                .padding(.top, -40)
//                if !timelinePosts.postInfoValues.isEmpty {
//                    Divider()
//                }
                 
               //MARK: - preloaded posts
                
                let postInfoValues =  timelinePosts.preloadedPosts//postInfoValues
     
                 ForEach(postInfoValues , id: \.self) { item in
                        
                        TimelinePost(id: item.id, friendProfileSelectedItem: $friendProfileSelectedItem, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, friendsDictionary: timelinePosts.friendsDictionary, postData: item, myTags: myTags, isDeletePostAlertShowing: $isDeletePostAlertShowing, deletedPost: $deletedPost )
                            .padding(.horizontal,-8)
                            .onTapGesture {
                                ///user can only open post if it has been sent.
                                guard item.status != .sending  else{
                                    return
                                }
                                openedPostSelectedItem = item
                                OpenedPostMatchedGeometry = "0"
                                //                                }
                            }
                            .padding(.top, -10)
                            .contextMenu {
                                VStack {
                                    Button(action: {
                                        savePost.savePost(postID: item.postID, postAuthor: item.id)
                                    }) {
                                        Text("Save")
                                            .font(.headline)
                                    }
                                    if item.id == Auth.auth().currentUser?.uid {
                                        Button(action: {
                                            isDeletePostAlertShowing = true
                                            deletedPost = item
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
                    
            }

            .listStyle(PlainListStyle())
//            .padding(.horizontal, -15)
        } .edgesIgnoringSafeArea(.top)
    }
}
