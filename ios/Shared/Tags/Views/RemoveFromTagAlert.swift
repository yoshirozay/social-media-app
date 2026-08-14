//
//  RemoveFromTagAlert.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 11/21/21.
//


import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Combine
 

struct RemoveFromTagAlert: View {
   @State var hasBeenRemoved = false
   @ObservedObject var functions: CreateTagFunction
   @ObservedObject var tagFriends: TagFriendsOO
   @EnvironmentObject var friendsDictionary: FriendsDictionary
   @Environment(\.colorScheme) var colorScheme
   @Binding var removingTagInfo : OpenedTag.RemovingTagInfo
   var body: some View {
       
#if os(iOS)
              let buttonWidth: CGFloat = screenWidth - 300
              let spacing: CGFloat = 30
#elseif os(macOS)
              let buttonWidth: CGFloat = screenWidth*0.25
              let spacing: CGFloat = 50
#endif
      return ZStack {
           Color.white
           Color.mainColor.opacity(0.05)
           if hasBeenRemoved == false {
               
           VStack {
               HStack {
                  
                   (Text("Remove") + Text(" \(removingTagInfo.name)").fontWeight(.bold) + Text(" from \(removingTagInfo.tagName)?"))
                       .font(.title2)
                       .foregroundColor(colorScheme == .light ? Color.mainColor.opacity(0.7) : Color.black.opacity(0.7))
                       .multilineTextAlignment(.center)
                       .padding()
               }
               HStack (spacing: spacing) {
                   Button(action: {
//                        tagNavigation = ""
                       removingTagInfo.removeAll()
                   }) {
                       Image(systemName: "xmark")
                           .font(.headline)
                           .padding(.vertical)
                           .frame(width: buttonWidth)
                           .foregroundColor(.white)
                       
                       
                   } .buttonStyle(.borderless)
                       .background(
                       Color.speakerPink.opacity(0.7))
                   .cornerRadius(10).shadow(radius: 5)
                   Button(action: {
                       functions.removeFromTag(tagID: removingTagInfo.tagID,
                                               sentTo: [removingTagInfo.sentTo])
                       withAnimation() {
                           hasBeenRemoved = true
//                            tagFriends.removeFriend(id: removingTagInfo.sentTo)
                           removingTagInfo.removeAll()
                       }
                   }) {
                       Image(systemName: "checkmark")
                           .font(.headline)
                           .padding(.vertical)
                           .frame(width: buttonWidth)
                           .foregroundColor(.white)
                        
                   } .buttonStyle(.borderless)
                       .background(
                       Color.speakerPink.opacity(0.7)).cornerRadius(10).shadow(radius: 5)
               }
           }
           } else {
               HStack {
               Text("Removed")
                   .font(.largeTitle)
                   .fontWeight(.bold)
                   .foregroundColor(Color.mainColor)
                   .padding()
                   
                   Image(systemName: "checkmark")
                       .font(.title)
                       .foregroundColor(Color.mainColor)
                       .offset(x: -10)
               }
               .padding(.leading, 15)
           }
       }
#if os(iOS)
      .frame(width: screenWidth - 50, height: screenWidth - 200)
#elseif os(macOS)
      .frame(width: screenWidth*0.7  , height: screenWidth*0.6  )
#endif
 
       .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
   }
}
