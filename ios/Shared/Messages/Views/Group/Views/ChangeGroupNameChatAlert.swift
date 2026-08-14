//
//  ChangeGroupNameChatAlert.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/14/22.
//

import SwiftUI

struct ChangeGroupNameChatAlert: View {
    @State var name: String
    @State var text = ""
    @Binding var isGroupChatAlertShowing: Bool
    @State var chatUID: String
    @State var groupChatUsers: [Person]
    @StateObject var functions = UpdateGroupChatName()
    @Binding var GroupChatInfoMatchedGeometry: String
    @ObservedObject var themeController: ThemeController
    var body: some View {

        ZStack {
            LinearGradient(colors: [themeController.theme.accent, themeController.theme.accent], startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack (spacing: 20) {
            Text(name)
                .font(.title3)
                .bold()
                .foregroundColor(.white)

                TextField(" ", text: $text)
                    .padding(5)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.7))
                    .font(.headline)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(width: 220, height: 30)
                HStack (spacing: 30){
                Button(action: {
                    isGroupChatAlertShowing = false
                }) {
                    Text("Cancel")
                        .foregroundColor(Color.white.opacity(0.7))
                        .fontWeight(.bold)
                        .padding(10)
                        .padding(.horizontal, 2)
                        .background(Color.white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Button(action: {
                    functions.updateGroupChatName(groupChatUsers: groupChatUsers, chatUID: chatUID, groupChatName: text)
                    isGroupChatAlertShowing = false
                    GroupChatInfoMatchedGeometry = ""
                }) {
                    Text("Done")
                        .foregroundColor(Color.white.opacity(0.7))
                        .fontWeight(.bold)
                        .padding(10)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                }
                .padding(.top, 0)
            }
        }
        .frame(width: 275, height: 175)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
