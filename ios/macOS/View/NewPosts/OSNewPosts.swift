//
//  OSNewPosts.swift
//  speakEZ crossplatform (macOS)
//
//  Created by Carson O'Sullivan on 2/1/21.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth

struct OSNewPosts: View {
    @State var content = ""
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    
    @EnvironmentObject var timelinePosts : TimelinePostsOO
    @EnvironmentObject var navigation : OSNavigationOO
    var body: some View {
        
        ZStack {
            Color.mainColorInverse.opacity(0.3)
                .ignoresSafeArea(.all)
            VStack {
                Group {
                    HStack (alignment: .top, spacing: 10) {
                        
                        let userId = Auth.auth().currentUser?.uid ?? "" 
                        WebImage(url: friendsDictionary.friendsDictionary[userId]?.profilePicLink)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text(friendsDictionary.friendsDictionary[userId]?.name ?? "")
                                .font(.headline)
                            Text(friendsDictionary.friendsDictionary[userId]?.username ?? "")
                                .font(.caption)
                        }
                        //
                        Spacer()
                        OSHeaderButton(image: "paperplane") {
                            timelinePosts.sendNewPost(content: content, newMedia: nil, mentionedIDs: [], tags: [])
                            navigation.changeTo(.Home)
                        }
                        .padding(.top, 5)
                        .frame(width: 50, height: 30)
                      .foregroundColor(Color.mainColor)
//
                    } // HStack, Navigation Menu
                  .foregroundColor(Color.mainColor)
                    .padding(.horizontal, 10)

                } // Header
                .padding(.top)
                Divider()
                Spacer()
            }
            VStack {
                TextEditor(text: $content)
//                    .background(Color.red.opacity(0.3))
                    .padding(.horizontal)
                    .font(.title)
                    .disableAutocorrection(true)
//                    .clipShape(ChatBubbleShape(direction: .right))
                    .overlay(
                        ZStack {
                            VStack {
                                HStack {
                            if content == "" {
                                Text("What's new?")
                                  .foregroundColor(Color.mainColor)
                                    .font(.title)
                                    .padding(.horizontal, 25)

                            }
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    )
                
            } .offset(x: -8)
            .padding(.top, 85)
        }
        .padding(.trailing, -screenWidth/179.2)
       
    }
}

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear //<<here clear
            drawsBackground = true
        }

    }
}
