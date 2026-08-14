//
//  Banner.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 7/21/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Combine

struct NotificationBannerControllerView: View {
    @ObservedObject var friendsDictionary: FriendsDictionary
    @StateObject var pnBannerViewModel: PNBannerViewModel
    @State var hasNotificationBeenRemoved = false
    @ObservedObject var pushNotificationVM : PushNotificationVM
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {

            VStack (spacing: 5) {
                ForEach(pnBannerViewModel.notificationInfo, id: \.self) { item in
                
                    NotificationBannerView(friendsDictionary: friendsDictionary, notificationInfo: item, themeController: themeController)
                        .onAppear() {
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .heavy)
                        impactLight.impactOccurred(intensity: 1)
#endif
                        }
                        .onTapGesture {

                            pushNotificationVM.inAppPushNotification(notificationInfo: item)

                            pnBannerViewModel.removeNotificationInfo(id: item.id)
                        
                        }
                        .onAppear() {
                            if pushNotificationVM.isFromBannerNotification != true {
                                pushNotificationVM.tapFromBannerNotification()
                            }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    withAnimation(.linear(duration: 0.6)) {
                                    pnBannerViewModel.removeNotificationInfo(id: item.id)
                                    }
                            }
                        }
                }
                
            }
        }
        .padding(.top, 42)
    }
}

struct NotificationBannerView: View {
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var notificationInfo: NotificationBanner
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            switch notificationInfo.notificationType {
            case .newPrivateMessage:
                IndividualBanner(notificationTitle: friendsDictionary.friendsDictionary[notificationInfo.authorID]?.name ?? "", notificationBody: notificationInfo.body, image: friendsDictionary.friendsDictionary[notificationInfo.authorID]?.webLink, notificationInfo: notificationInfo, themeController: themeController)
            case .newComment:
                IndividualBanner(notificationTitle: notificationInfo.title, notificationBody: notificationInfo.body, image: friendsDictionary.friendsDictionary[notificationInfo.userID]?.webLink, notificationInfo: notificationInfo, themeController: themeController)
            case .newGroupMessage:
                IndividualBanner(notificationTitle: notificationInfo.title, notificationBody: notificationInfo.body, image: notificationInfo.userImage, notificationInfo: notificationInfo, themeController: themeController)
            case .newPost:
                IndividualBanner(notificationTitle: notificationInfo.title, notificationBody: notificationInfo.body, image: friendsDictionary.friendsDictionary[notificationInfo.authorID]?.webLink, notificationInfo: notificationInfo, themeController: themeController)
            case .newFriendRequest:
                IndividualBanner(notificationTitle: notificationInfo.title, notificationBody: notificationInfo.body, notificationInfo: notificationInfo, themeController: themeController)
            case .newCommentLike:
                IndividualBanner(notificationTitle: notificationInfo.title, notificationBody: "\(friendsDictionary.friendsDictionary[notificationInfo.userID]?.name ?? "") liked your comment ", image: friendsDictionary.friendsDictionary[notificationInfo.userID]?.webLink, notificationInfo: notificationInfo, themeController: themeController)
            case .newPostLike:
                IndividualBanner(notificationTitle: notificationInfo.title, notificationBody: "\(friendsDictionary.friendsDictionary[notificationInfo.userID]?.name ?? "") liked your Moment ", image: friendsDictionary.friendsDictionary[notificationInfo.userID]?.webLink, notificationInfo: notificationInfo, themeController: themeController)
            case .newCommentMention:
                IndividualBanner(notificationTitle: notificationInfo.title, notificationBody: "\(friendsDictionary.friendsDictionary[notificationInfo.authorID]?.name ?? "") mentioned you in a comment ", image: friendsDictionary.friendsDictionary[notificationInfo.authorID]?.webLink, notificationInfo: notificationInfo, themeController: themeController)
            case .newPostMention:
                IndividualBanner(notificationTitle: notificationInfo.title, notificationBody: "\(friendsDictionary.friendsDictionary[notificationInfo.userID]?.name ?? "") tagged you in a Moment ", image: friendsDictionary.friendsDictionary[notificationInfo.userID]?.webLink, notificationInfo: notificationInfo, themeController: themeController)
            case .newEvent:
                IndividualBanner(notificationTitle: notificationInfo.title, notificationBody: notificationInfo.body, image: friendsDictionary.friendsDictionary[notificationInfo.authorID]?.webLink, notificationInfo: notificationInfo, themeController: themeController)
            case .newEventMessage:
                IndividualBanner(notificationTitle: notificationInfo.title, notificationBody: notificationInfo.body, image: friendsDictionary.friendsDictionary[notificationInfo.authorID]?.webLink, notificationInfo: notificationInfo, themeController: themeController)
            }
        }
    }
}

struct IndividualBanner: View {
    @State var emojis = [":)", ":P", "!!!", ":D", "<3"]
    @State var notificationTitle: String
    @State var notificationBody: String
    @State var image: URL?
    @State var notificationInfo: NotificationBanner
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.accent
            ZStack {
                themeController.theme.secondary
                HStack {
                    ZStack {
                        Circle()
                            .frame(width: 52, height: 52)
                            .foregroundColor(Color.mainColorInverse)
                        if image != nil {
                        WebImage(url: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                        } else {
                            ZStack {
                                Circle()
                                    .foregroundColor(themeController.theme.accent)
                                    .frame(width: 50, height: 50)
                                Image("martiniGlass")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 41, height: 41)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    VStack (alignment: .leading) {
                        Text(notificationTitle)
                            .font(.headline)
                            .foregroundColor(Color.black)
                        HStack (spacing: 0) {
                           
                        Text(notificationBody)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: false)
                            .foregroundColor(Color.black)
//                            if notificationInfo.notificationType == .newCommentLike || notificationInfo.notificationType == .newPostLike {
//                                Text(emojis.randomElement() ?? ":)")
//                                    .font(.subheadline)
//                                    .fontWeight(.heavy)
//                                    .fixedSize(horizontal: true, vertical: false)
//                                    .foregroundColor(Color.speakerPurple)
//                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .cornerRadius(10)
            .frame(width: screenWidth - 15, height: 70)
            
        }
        .cornerRadius(12)
        .frame(width: screenWidth - 10, height: 75)
    }
}
