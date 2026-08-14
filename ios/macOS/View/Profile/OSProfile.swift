////
////  OSProfile.swift
////  speakEZ crossplatform (macOS)
////
////  Created by Carson O'Sullivan on 2/1/21.
////
//
import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth
//
struct OSProfile: View {
    @StateObject var postData = ProfilePostsOO()
    @EnvironmentObject var friendsDictionary: FriendsDictionary

    var body: some View {
        ZStack {
            Color.mainColorInverse.opacity(0.3)
                .ignoresSafeArea(.all)
            HStack {
            HStack {
            VStack(alignment: .leading) {
                
                let userId = Auth.auth().currentUser?.uid ?? ""
                WebImage(url: friendsDictionary.friendsDictionary[userId]?.profilePicLink)
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(10)
                    .frame(width: screenWidth/6, height: screenHeight/6)
                VStack (alignment: .leading) {
                    Text(friendsDictionary.friendsDictionary[userId]?.name ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                    Text(friendsDictionary.friendsDictionary[userId]?.username ?? "")
                        .font(.title2)
                        .italic()
                    HStack {
                    Text(friendsDictionary.friendsDictionary[userId]?.bio ?? "")
                        .font(.title)
                        .padding(.top, 2)
                        .multilineTextAlignment(.leading)

                    Spacer()
                    }
                    .frame(width: screenWidth/6)
                }
                .offset(y: screenWidth/17.92)
                Spacer()
        }
            .padding(.top, screenWidth/14.934)
               Spacer()
            }
        .padding(.horizontal)
        }
            ScrollView(showsIndicators: false) {
            LazyVStack (spacing: 8) {
                ForEach(postData.postInfo.sorted(by: {$0.timeString > $1.timeString}), id: \.self) { item in
                    OSProfilePosts(postData: item)
                        .frame(width: screenWidth/3.3)
                        .clipShape(RoundedRectangle(cornerRadius: 5))

                }
            } // LazyVStack used to lazily load the current users posts
//            .padding(.top, 8)
            .padding(.top, screenWidth/99.56)
            .padding(.leading, screenWidth/5.7344)
        }
        }
        .padding(.trailing, -screenWidth/179.2) // -10
    }
}

