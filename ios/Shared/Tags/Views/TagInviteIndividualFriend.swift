//
//  TagInviteIndividualFriend.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 11/21/21.
//
 
import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Combine
   
struct SelectIndividuals: View {
    @State var id: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @Binding var selectedUser: [String]
    @Binding var selected: Bool
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            if id != Auth.auth().currentUser?.uid && id != TristanUserID {
        VStack {
            HStack {
                WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 12) {
                    Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                        .fontWeight(.bold)
                 .foregroundColor(Color.black)
                    Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                        .font(.caption)
                        .padding(.top, -10)
                        .foregroundColor(Color.black)
    
                } // VSTACK
                Spacer()
                Button(action: {
                    hideKeyboard()
                    if selected == false {
                        selectedUser.append(id)
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .heavy)
        impactLight.impactOccurred()
#endif
//                        selected = true
                    } else {
                        if let firstIndex = selectedUser.firstIndex(of: id) {
                            if id != Auth.auth().currentUser?.uid {
                            selectedUser.remove(at: firstIndex)
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .heavy)
        impactLight.impactOccurred()
#endif
//                            selected = false
                            }
                        }
                    }
                }){
                    Circle()
                        .frame(width: 20, height: 20)
                        .padding(.trailing)
                        .foregroundColor(selected ? Color.mainColorInverse.opacity(1) : themeController.theme.accent.opacity(0.3))
//                        .shadow(radius: 3, x: 0, y: 0)
                }.buttonStyle(.borderless)
            } // HSTACK
//            Divider()
            Rectangle()
                .frame(width: screenWidth - 40, height: 2)
                .foregroundColor(themeController.theme.accent.opacity(0.2))
        }
//        .background(Color.mainColorInverse)
//        .contentShape(Rectangle())
//        .onTapGesture {
//            if selected == false {
//                selectedUser.append(id)
////                selected = true
//            } else {
//                if  let firstIndex = selectedUser.firstIndex(of: id) {
//                    selectedUser.remove(at: firstIndex)
////                    selected = false
//                }
//            }
//            hideKeyboard()
//        }
        }
        }
    }
}
