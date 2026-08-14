//
//  Mentions.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 4/20/21.
//

import SwiftUI
import SDWebImageSwiftUI
//import ActiveLabel

//
struct MentionFriends: View {
    @Environment(\.colorScheme) var colorScheme
    @State var id: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    var body: some View {
        VStack {
            HStack {
                WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 12) {
                    Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                        .fontWeight(.bold)
                    Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                        .font(.caption)
                        .padding(.top, -10)
                } // VSTACK
                Spacer()
            } // HSTACK
            .contentShape(Rectangle())
           .foregroundColor(Color.mainColor)
        }
    }
}

struct MutualFriendsForMentions: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var content: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var mutualFriends: MutualFriendsOO
    @Binding var mentionCount: [String]
    var body: some View {
        if content != "@" {
        ScrollView() {
            VStack {
                ForEach(mutualFriends.mutualFriends.values.filter{$0.username.lowercased().contains(self.content.components(separatedBy: "@")[content.indicesOf(string: "@").count].lowercased())}, id: \.self) { item in
                    MentionFriends(id: item.id)
                        .onTapGesture {

                            let indicies = content.indicesOf(string: "@")
                            let endIndex = content.endIndex
                           
//                                          if
                                let index = content.index(content.startIndex, offsetBy: indicies[mentionCount.count])
                            content.removeSubrange(index..<endIndex)
                            content.append(item.username + " ")
                            mentionCount.append(item.id)
                            
                        }
                        .padding(.horizontal, 10)
                    Rectangle()
                        .frame(width: 293, height: 2)
                        .foregroundColor(Color.mainColorInverse)
                }
            }
            .background(Color.speakerPurple.opacity(0.3)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding(.vertical, -10)
                )
            .padding(.top, 2)
            .padding(.horizontal, 2)
            .background(Color.mainColorInverse
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding(.vertical, -10)
                )
            
            
            .padding(.top, 20)
        }
        .contentShape(Rectangle())
        .frame(width: 300, height: 300)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        .padding(.top, 150)
        }

    }
}
