////
////  MainView.swift
////  speakEZ crossplatform (macOS)
////
////  Created by Carson O'Sullivan on 1/31/21.
////

import SwiftUI

struct OSTimelineMainView: View {
    @Namespace var namespace
    @State var openedPostSelectedItem: PostModel!
    @State var OpenedPostMatchedGeometry: String = ""
    @State var FriendProfileMatchedGeometry: String = ""

    @State var emptyBindingVariable = 0
    @State var emptyBindingBoolVariable = false
    
    @EnvironmentObject var timelinePosts : TimelinePostsOO
    var body: some View {
       
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 6) {
                    
//  ForEach(timelinePosts.postInfo.sorted(by: {$0.timeString > $1.timeString}), id: \.self)
                    ForEach(timelinePosts.allTimeLinePosts, id: \.self) { item in
                        OSTimelinePosts(id: item.id, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, postData: item)
                            .matchedGeometryEffect(id: UUID(), in: namespace, isSource: false)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .onTapGesture {
                                openedPostSelectedItem = item
                                OpenedPostMatchedGeometry = "0"

                            }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .opacity(FriendProfileMatchedGeometry == "" ? 1 : 0)
            } // SCROLLVIEW
            if FriendProfileMatchedGeometry != ""  {
                OSFriendProfile(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, postData: FriendsPostsOO(id: FriendProfileMatchedGeometry), id: FriendProfileMatchedGeometry)

            }
        } .background(timelinePosts.allTimeLinePosts.isEmpty ? Color.mainColorInverse.opacity(0.3) : nil)
        .padding(.trailing, -screenWidth/179.2) // -10
    }
}

