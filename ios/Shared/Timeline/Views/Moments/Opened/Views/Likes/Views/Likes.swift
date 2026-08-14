//
//  HomeL.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import SwiftUI

struct Likes2: View {
    @Binding var LikesMatchedGeometry: String
    @ObservedObject var likes: LikesOO
    @Environment(\.colorScheme) var colorScheme
    @State var OpenProfileMatchedGeometry: String = ""
    // TimelineMoment items
    @State var id: String
    @State var StrangerProfileSelectedUser: Person?
    @State var FriendProfileMatchedGeometry: String = ""
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var myTags: MyTagsOO
    @Binding var isDeletePostAlertShowing: Bool
    @Binding var deletedPost : PostModel?
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var OpenedPhotoSelectedItem: URL?
    @ObservedObject var commentLikeVM: CommentLikeVM
    @State var isFirstResponder = true
    @ObservedObject var mentionedUserVM : MentionedUserVM
    @Binding var LongPostMatchedGeometry: String
     //FIXME: - do not know that should it be a stateObject or ObservedObject
    @StateObject var postVM = PostVM()
    //
    var body: some View {
        ZStack {
            Color.mainColorInverse.opacity(1.0)
                .ignoresSafeArea(.all)
            Color.speakerPurple.opacity(0.2)
                .ignoresSafeArea(.all)
            VStack {

                ZStack(alignment: .bottom) {
                    
                    Color.mainColorInverse.clipped()
                        .frame(height: 250)
                    TimelineMoment(id: id, friendProfileSelectedItem: $FriendProfileMatchedGeometry, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                                   friendsDictionary: friendsDictionary , myTags: myTags, isDeletePostAlertShowing: $isDeletePostAlertShowing, deletedPost:
                                    $deletedPost, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,commentLikeVM : commentLikeVM ,  isFromOpenedPost: true, isFirstResponder: $isFirstResponder, mentionedUserVM : mentionedUserVM, LongPostMatchedGeometry: $LongPostMatchedGeometry, postVM: postVM)
                    
                    Rectangle()
                        .frame(width: screenWidth, height: 8)
                        .foregroundColor(Color.mainColorInverse)
                        .offset(y: 8)
                }
                .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Button(action: {
                            LikesMatchedGeometry = ""
                        }){
                            ZStack {
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .foregroundColor(Color.white)
                            }
                            .frame(width: 40, height: 40)

                        }
                        HStack {
                  

                            Text("💜")
                                .font(.title)
                            .onTapGesture {
                                LikesMatchedGeometry = ""
                            }
                        Text("LIKES")
                            .font(.headline)
                          .foregroundColor(Color.mainColor)
                        }
                        .padding(.leading, 5)
                        Spacer()
                    }
                    .padding(.bottom, 10)

                    ScrollView(showsIndicators: false) {
//                        ForEach(likes.postLikes) { i in
                        VStack {
                 
                            ForEach(likes.postLikes, id: \.self) { person in
    
                                SearchBarResultRow(person: person, size: 40, friendsDictionary: friendsDictionary, anonymousModeAlert: .constant(false), buttonAlertType: .constant(.none))
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if friendsDictionary.friendsDictionary[person.id] != nil {
                                            FriendProfileMatchedGeometry = person.id
                                        } else {
                                            if person.anonymousMode != true {
                                            FriendProfileMatchedGeometry = person.id
                                            StrangerProfileSelectedUser = person
                                            }
                                        }
                                    }

                                Rectangle()
                                    .foregroundColor(Color.white.opacity(0.7))
                                    .frame(width: screenWidth / 1.05 , height: 1)
                            }
                        }

                    }
                }
                .padding(.leading)
                .padding(.top, 10)
//                .padding(.top, iOS15 ? 10 : 0)
                
                Spacer()
            }
//            .padding(.top, iOS15 ? 0 : -50)
            if OpenedPhotoMatchedGeometry != "" {
                OpenPhotoTabView(OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, photo: OpenedPhotoSelectedItem, isFromTimeline: true)

            }
            if FriendProfileMatchedGeometry != "" {
                if friendsDictionary.friendsDictionary[FriendProfileMatchedGeometry] != nil {
                FriendProfileHomeTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry, isFromOpenedPost: true, themeController: ThemeController())
//                    .padding(.horizontal, 20)
                } else {
                    StrangerProfileTabView(ProfileMatchedGeometry: $FriendProfileMatchedGeometry, person: StrangerProfileSelectedUser ?? Person(id: ""), id: FriendProfileMatchedGeometry)
                }
 
            }
        }
    }
}
