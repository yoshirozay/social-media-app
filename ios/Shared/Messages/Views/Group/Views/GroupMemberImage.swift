//
//  GroupMemberImage.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/14/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupMemberImage : View {
    @Environment(\.colorScheme) var colorScheme
    var weblink : URL?
    var diameter : CGFloat = 55
    var body: some View {
        ZStack {
            WebImage(url: weblink)
             .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: diameter, height: diameter)
//                .background(Color.softWhite)
                .clipShape(Rectangle())
        }
    }
}
