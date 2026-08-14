//
//  IndividualFriendHexagon.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/6/21.
//

import SwiftUI
import SDWebImageSwiftUI

/////
struct IndividualFriendHexagon: View {
   @State var id: String = ""
   @EnvironmentObject var friendsDictionary: FriendsDictionary
   let backgroundColor = UIColor.gray.withAlphaComponent(0.1)
   var body: some View {
#if os(macOS)
            let screenWidth = IndividualTag.screenWidth
#endif
       return WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
           .resizable()
           .aspectRatio(contentMode: .fill)
           .frame(width: (screenWidth - 40) / 3, height: 125)
           .background(Color(backgroundColor))
           .clipShape(Hexagon())
           .padding(.top, 10)
           .shadow(radius: 4, x: 0, y: 3)
           .shadow(radius: 4, x: 3, y: 0)
       
   }
}


