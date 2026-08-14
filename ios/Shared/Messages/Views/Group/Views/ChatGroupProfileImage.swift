//
//  ChatGroupProfileImage.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/14/22.
//

import SwiftUI
  
struct ChatGroupProfileImage : View {
    var chatModel : ChatModel
    private let columns = [GridItem(.fixed(17.5)),GridItem(.fixed(17.5))]
    var body: some View {
        LazyVGrid(columns: columns,spacing : 0.5) {
            ForEach(chatModel.firstFourUsers, id: \.self) {
                GroupMemberImage(weblink: $0.profilePicLink,diameter : 25)
            }
        }
        .frame(width: 50, height: 50)
        .background(Color.softWhite)
        .clipShape(Circle())
    }
}
