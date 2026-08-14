//
//  ProfileCircleSelection.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/6/21.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth

struct ProfileCircleSelection: View {
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var color: Color
    @Binding var selectedProfileCircle: String
    var body: some View {
        ZStack {

            Circle()
                .frame(width: 65, height: 65)
                .foregroundColor(Color.speakerPurple.opacity(1))
                .opacity(selectedProfileCircle == spliceString(color: "\(color)")
 ? 1 : 0)
            
            Button(action : {
                selectedProfileCircle = spliceString(color: "\(color)")
                
                print("SELECTED CIRCLE = \(selectedProfileCircle)")
                
            }) {
            ZStack {
                Circle()
                    .frame(width: 59, height: 59)
                    .foregroundColor(color)
            WebImage(url: friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? ""]?.profilePicLink)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 55, height: 55)
            .clipShape(Circle())
            }
            }
        }
    }
    func spliceString(color: String) -> String {
        let string = color

        if let index = string.firstIndex(of: "\""),
            case let start = string.index(after: index),
            let end = string[start...].firstIndex(of: "\"") {
            let substring = string[start..<end]
            return String("\(substring)")
        }
        return color
    }
}
