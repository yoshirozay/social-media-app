//
//  DynamicLinkStrangerView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/11/21.
//

import SwiftUI

struct DynamicLinkViews : View {
    @EnvironmentObject var dynamicViews : DynamicViewsNavigationOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var eventModel: EventModelOO
    @State var StrangerProfileMatchedGeometry = "0"
    @State var OpenedEventMatchedGeometry = "0"
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack{
            if let sharedUser = dynamicViews.person {
                StrangerProfileTabView(ProfileMatchedGeometry: $StrangerProfileMatchedGeometry,
                                       person: sharedUser,
                                       id: sharedUser.id)
                    .onChange(of: StrangerProfileMatchedGeometry) { val in
                        if val == "" {
                            dynamicViews.refresh()
                        }
                    }
                    .padding(.top, iOS15 ? 0 : -100)
            } else if dynamicViews.event.eventName != ""  {
                ZStack {
                    OpenedEventTabView(OpenedEventMatchedGeometry: $OpenedEventMatchedGeometry, eventModel: eventModel, event: $dynamicViews.event, friendsDictionary: friendsDictionary, isRequestingToJoin: true, EventMatchedGeometryEffect: .constant(""), isFromInvitations: true, themeController: themeController)
                        .onChange(of: OpenedEventMatchedGeometry) { val in
                            if val == "" {
                                dynamicViews.refresh()
                            }
                        }
                        .padding(.top, iOS15 ? 0 : -100)
                }
            }else{

            }
        }
    }
    
}
