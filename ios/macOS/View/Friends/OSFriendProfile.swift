//
//  OSFriendProfile.swift
//  speakEZ crossplatform (macOS)
//
//  Created by Carson O'Sullivan on 2/4/21.
//
//
import SwiftUI
import SDWebImageSwiftUI

struct OSFriendProfile: View {
    @Binding var FriendProfileMatchedGeometry: String
    @StateObject var postData = FriendsPostsOO(id: "")
    @State var id: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    var body: some View {
        ZStack {
            Color.mainColorInverse.opacity(0.3)
                .ignoresSafeArea(.all)
            HStack {
                HStack {
                    VStack(alignment: .leading) {
                        WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                            .resizable()
                            .scaledToFill()
                            .cornerRadius(10)
                            .frame(width: screenWidth/6, height: screenHeight/6)
                        VStack (alignment: .leading) {
                            Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                                .font(.title)
                                .fontWeight(.bold)
                            Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                                .font(.title2)
                                .italic()
                            HStack {
                            Text(friendsDictionary.friendsDictionary[id]?.bio ?? "")
                                .font(.title)
                                .padding(.top, 2)
                                .multilineTextAlignment(.leading)

                            Spacer()
                            }
                            .frame(width: screenWidth/6)
                            
                        }
                        .offset(y: screenWidth/17.92)
                        Spacer()
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .padding(.bottom, screenWidth/19.91)
                            .onTapGesture {
                                FriendProfileMatchedGeometry = ""
                            }
                            .frame(width: 30, height: 30)
                    }
                    .offset(x: screenWidth/94.316)
                    .padding(.top, screenWidth/14.934)
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            ScrollView(showsIndicators: false) {
                LazyVStack (spacing: 8) {
                    ForEach(Array(postData.postInfo.sorted(by: {$0.timeString > $1.timeString})), id: \.self) { item in
                         
                        OSFriendProfilePosts(id: item.id, postData: item)
                            .clipShape(RoundedRectangle(cornerRadius: 5))

                    }
                } // LazyVStack used to lazily load the current users posts
                .padding(.top, screenWidth/99.56) // 18
                .padding(.leading, screenWidth/5.7344) // 312.5
            }
            .offset(x: screenWidth/179.2)
            .frame(width: screenWidth/2.3)
        }
        .padding(.trailing, -screenWidth/179.2) // -10
    }
}

