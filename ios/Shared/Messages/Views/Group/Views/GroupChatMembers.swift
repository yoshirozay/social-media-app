//
//  GroupChatMembers.swift
//  speakEZ
//
//  Created by Ahmad naeem on 4/14/22.
//

import SwiftUI
 
struct GroupChatMembers: View {
    @ObservedObject var allMessages : OpenedGroupConversationOO
    @Environment(\.colorScheme) var colorScheme
    @Binding var OpenedProfileSelectedPerson: Person
    @Binding var OpenedProfileMatchedGeometry: String
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack (spacing: 10) {
        ForEach(allMessages.chatModel.otherMembers, id: \.self) { item in
            SearchForSomeoneResults(person: item)
                .contentShape(Rectangle())
                .onTapGesture {
                    OpenedProfileMatchedGeometry = item.id
                    OpenedProfileSelectedPerson = item
                }
            Rectangle()
                .frame(width: screenWidth - 40, height: 2)
                .foregroundColor(themeController.theme.accent.opacity(0.2))
        }
            }
            .background(themeController.theme.secondary
                .clipShape(RoundedRectangle(cornerRadius: 25))
//                            .padding(.horizontal, 10)
                .padding(.vertical, -10)
                )
            .padding(.top, 20)
        }
    }
}
