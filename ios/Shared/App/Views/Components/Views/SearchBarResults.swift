//
//  SearchBarResults.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/6/21.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI
import Firebase
import FirebaseAuth

import Combine


struct SearchBarResults: View {
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var id: String
    @State var size: CGFloat = 55
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack { 
            ZStack {
                Circle()
                    .frame(width: size + 4, height: size + 4)
                    .foregroundColor(friendsDictionary.friendsDictionary[id]?.profileCircle)
//                                .foregroundColor(Color.mainColor)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                    .clipShape(Circle())
             WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .background(Color.mainColor.opacity(0.1))
                .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 12) {
                Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                    .fontWeight(.bold)
                Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                    .font(.caption)
                    .padding(.top, -10)
            } // VSTACK
           .foregroundColor(Color.black)
            Spacer()
        } // HSTACK
//        .contentShape(Rectangle())
        
    }
}


struct SearchBarResultRow: View {
    let person : Person
    var size: CGFloat = 55
    @ObservedObject var friendsDictionary: FriendsDictionary
    @Environment(\.colorScheme) var colorScheme
    @Binding var anonymousModeAlert: Bool
    @Binding var buttonAlertType: ButtonAlertType
    var body: some View {
        HStack {
            if person.anonymousMode == true && friendsDictionary.friendsDictionary[person.id] == nil {
                HStack {
                Image(systemName: "questionmark")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .scaledToFill()
                    .background(Color.black.opacity(0.2))
                    .clipShape(Circle())
                Text ("Anonymous")
                    .font(.headline)
                    .foregroundColor(Color.black)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        withAnimation() {
                            if anonymousModeAlert == false {
                                buttonAlertType = .anonymousMode
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    anonymousModeAlert = true
                                }
                            }
                        }
                    }
                }
            } else {
            ZStack {
                Circle()
                    .frame(width: size + 4, height: size + 4)
                    .foregroundColor(person.profileCircle)
//                                .foregroundColor(Color.mainColor)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                    .clipShape(Circle())
             WebImage(url: person.profilePicLink)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .background(Color.mainColor.opacity(0.1))
                .clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 12) {
                Text(person.name)
                    .fontWeight(.bold)
                Text(person.username)
                    .font(.caption)
                    .padding(.top, -10)
            } // VSTACK
           .foregroundColor(Color.black)
            }
            Spacer()
        } // HSTACK
        .contentShape(Rectangle())
        
    }
}
