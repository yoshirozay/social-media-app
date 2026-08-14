//
//  NameGroupChatAlert.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/19/21.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI
import Firebase

struct NameGroupChatAlert: View {
    @Binding var text : String
    @Binding var isGroupChatAlertShowing: Bool
    @State var selectedUser: [String]
    @StateObject var functions = CreateGroupUserChatFunction()
    let doneTap : (()->Void)
    var body: some View {
        ZStack {
            LinearGradient(colors: [.speakerPurple, .speakerPink], startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack (spacing: 20) {
            Text("Name your group chat?")
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
              
                    doneTap()
//                    functions.createGroupUserChat(groupChatUsers: selectedUser, groupChatName: text)
                    isGroupChatAlertShowing = false
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
