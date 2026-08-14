//
//  GridMoment.swift
//  speakEZ crossplatform (iOS)
//
//  Created by Carson O'Sullivan on 2/10/22.
//

import SwiftUI
import Combine
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI

struct GridMoment: View {
    @State var id: String
    @Binding var friendProfileSelectedItem: String
    @Binding var FriendProfileMatchedGeometry: String
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var postData: PostModel
    @Environment(\.colorScheme) var colorScheme
    @State var progressBarValue : CGFloat = 0
    @ObservedObject var myTags: MyTagsOO
    @State var isFromProfile = false
    var postDeletePublisher : PassthroughSubject<String,Never>! = nil
    @Binding var isDeletePostAlertShowing: Bool
    @Binding var deletedPost : PostModel?
    
    var body: some View {
        
        ZStack (alignment: .trailing) {
            ZStack (alignment: .bottomLeading) {
                
                WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screenWidth/2 - 5, height: 250)
                //                ZStack (alignment: .leading){
                //                    Color.mainColorInverse.opacity(0.4)
                //                Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                //                        .font(.headline)
                //                        .foregroundColor(.mainColor)
                //                    .padding(.bottom)
                //                    .padding(.leading, 1)
                //
                //                }
                //                .frame(width: (CGFloat((friendsDictionary.friendsDictionary[id]?.username ?? "").count) * 10) + 10, height: 10)
                
            }
            VStack(spacing: 10) {
                VStack (spacing: 0) {
                    Image(systemName: "heart")
                    //                        .frame(width: 20, height: 20)
                        .font(.title2)
                    Text("7")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                VStack(spacing: 0) {
                    Image(systemName: "bubble.middle.bottom")
                        .font(.title3)
                    Text("3")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .background(Color.white.opacity(0.2))
            .foregroundColor(Color.white)
            .padding(.bottom, -50)
            
            //
            //            timelinePosts?.hasBeenRead == false ? Color.speakerPink.opacity(0.00) :  Color.mainColorInverse.opacity(0.30)
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}
 

