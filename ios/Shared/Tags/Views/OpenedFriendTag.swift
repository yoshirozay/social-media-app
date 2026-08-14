//
//  OpenedFriendTag.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 3/14/22.
//

import SwiftUI

struct OpenedFriendTag: View {
    @State var tagName: String = "🔒"
    @State var tagIDs: [String] = [""]
    @State var OpenProfileMatchedGeometry: String = ""
    @ObservedObject var members: OpenedTagOO
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
    @ObservedObject var postVM : PostVM
    @ObservedObject var themeController: ThemeController
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
                                    $deletedPost, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,commentLikeVM : commentLikeVM ,
                                   isFromOpenedPost: true, isFirstResponder: $isFirstResponder, mentionedUserVM : mentionedUserVM, LongPostMatchedGeometry: $LongPostMatchedGeometry, postVM: postVM)
                    
                    Rectangle()
                        .frame(width: screenWidth, height: 8)
                        .foregroundColor(Color.mainColorInverse)
                        .offset(y: 8)
                }
                .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Button(action: {
                            postVM.dismissOpenedFriendTag()
                        }){
                            ZStack {
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .foregroundColor(Color.white)
                            }
                            .frame(width: 40, height: 40)

                        }
                        HStack {
                  

                            Image("pinkLock2")
                                .resizable()
                                .frame(width: 30, height: 35)
                                .font(.headline)
                            .opacity(0.7)

                            .onTapGesture {
                                postVM.dismissOpenedFriendTag()
                            }

                        

                        Text("ACCESS")
                            .font(.headline)
                          .foregroundColor(Color.mainColor)
                        }
                        .padding(.leading, 5)
                        Spacer()
                    }
                    .padding(.bottom, 10)

                    ScrollView(showsIndicators: false) {
                        LockMembersFriendTag(OpenProfileMatchedGeometry: $FriendProfileMatchedGeometry,  StrangerProfileSelectedUser: $StrangerProfileSelectedUser, friendsDictionary: friendsDictionary, members: members.people)
                            .animation(.spring())
                            .padding(.bottom, 40)

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
                FriendProfileHomeTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry, isFromOpenedPost: true, themeController: themeController)
//                    .padding(.horizontal, 20)
                } else {
                    StrangerProfileTabView(ProfileMatchedGeometry: $FriendProfileMatchedGeometry, person: StrangerProfileSelectedUser ?? Person(id: ""), id: FriendProfileMatchedGeometry)
                }
 
            }
        }
        
        .edgesIgnoringSafeArea(.bottom)
        
    }
}
//LockMembersFriendTag(OpenProfileMatchedGeometry: $OpenProfileMatchedGeometry, members: members.people)
//    .animation(.spring())
//    .padding(.bottom, 20)
struct LockMembersFriendTag: View {
    @State var isAllLockMembersShowing = false
    @Binding var OpenProfileMatchedGeometry: String
    @Binding var StrangerProfileSelectedUser: Person?
    @ObservedObject var friendsDictionary: FriendsDictionary
    var members: [Person]
    var body: some View {
        VStack {
 
            ForEach(members.sorted(by: {$1.name.lowercased() > $0.name.lowercased()}), id: \.self) { person in
                if person.id != TristanUserID {
                // SearchBarResult uses FriendDict to get user's info, so in case of non-friend user, the row shows blank view. so we created a new SearchBarResultRow that takes person and shows it
                    SearchBarResultRow(person: person, size: 40, friendsDictionary: friendsDictionary, anonymousModeAlert: .constant(false), buttonAlertType: .constant(.none))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if friendsDictionary.friendsDictionary[person.id] != nil {
                        OpenProfileMatchedGeometry = person.id
                        } else {
                            if person.anonymousMode != true {
                            OpenProfileMatchedGeometry = person.id
                            StrangerProfileSelectedUser = person
                            }
                        }
                    }
//                    .padding(.horizontal)
                Rectangle()
                    .foregroundColor(Color.white.opacity(0.7))
                    .frame(width: screenWidth / 1.05 , height: 1)
            }
            }
        }
    }
}

