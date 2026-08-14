//
//  TagButton.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 11/21/21.
//


import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Combine
   
 
struct TagButton: View {
    @Environment(\.colorScheme) var colorScheme
    var imageName: String
    var height: CGFloat = 16
    var width: CGFloat = 16
    var padding: CGFloat = 12
    var action: () -> Void
    
    var body: some View {
        ZStack {
            Button(action: { action() }, label: {
                Image(systemName: imageName)
                    .resizable()
                    .font(.headline)
                    .frame(width: width, height: height)
                    .padding(padding)
                    .offset(y: imageName == "paperplane" ? 1.5 : 0)
            })
            .buttonStyle(.borderless)
            .background(LinearGradient(gradient: .init(colors: [Color.speakerPurple.opacity(0.8), Color.speakerPink.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            .foregroundColor(.white)
            .clipShape(Circle())
//            .shadow(color: colorScheme == .light ? Color.mainColor.opacity(0.3) : Color.mainColor.opacity(0.3) , radius: 30, x: 0.0, y: 0.0)
        }
    }
}
