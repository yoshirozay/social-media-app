//
//  InvidivualNotification.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 7/31/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage



struct InvidivualNotification: View {
    @EnvironmentObject var friendDictionary: FriendsDictionary
    @State var id: String
    @State var timeString: String
    @State var person: Person?
//    @State var post: PostModel!
    @State var nameOfSendingUser: String?
    @State var webLink: URL?
    @Environment(\.colorScheme) var colorScheme
    var notificationType = Notification.Kind.comment
    @Binding var FriendProfileMatchedGeometryEffect: String
    @State var sentFromUser: String?
  
    var body: some View {
        ZStack{
        if notificationType == .comment {
            VStack (alignment: .leading){
                HStack (spacing: -5) {
                    ZStack {
                    Circle()
                        .frame(width: 54, height: 54)
                        .foregroundColor(friendDictionary.friendsDictionary[id]?.profileCircle)
    //                                .foregroundColor(Color.mainColor)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                        .clipShape(Circle())
                    WebImage(url: friendDictionary.friendsDictionary[id]?.profilePicLink)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .background(Color.lightGray)
                        .clipShape(Circle())
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            FriendProfileMatchedGeometryEffect = id
                        }
                }
                    HStack (alignment:. top){
                        
                        Text("\(friendDictionary.friendsDictionary[id]?.name ?? "") commented on your moment")
                            .multilineTextAlignment(.leading)
                            .font(.callout)
                        Spacer()
                        Text("\(timeString)")
                            .font(.caption2)
                             .opacity(colorScheme == .light ? 0.6 : 0.4)
                            .offset(x: -4, y: 3)

                    }
                    Spacer()
                }
//                if post != nil {
//                    Text(post.content)
//                        .font(.subheadline)
//                        .italic()
//                        .padding(.horizontal)
//                        .frame(height: 10)
//                        .opacity(0.8)
//
//                }
            } .foregroundColor(Color.mainColor)
        }
        if notificationType == .postMention {
            VStack (alignment: .leading){
                HStack (spacing: -5) {
                    ZStack {
                    Circle()
                        .frame(width: 54, height: 54)
                        .foregroundColor(friendDictionary.friendsDictionary[id]?.profileCircle)
    //                                .foregroundColor(Color.mainColor)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                        .clipShape(Circle())
                    WebImage(url: friendDictionary.friendsDictionary[id]?.profilePicLink)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .background(Color.lightGray)
                        .clipShape(Circle())
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            FriendProfileMatchedGeometryEffect = id
                        }
                }
                    HStack (alignment:. top){
                        
                        Text("\(friendDictionary.friendsDictionary[id]?.name ?? "") mentioned you in a moment")
                            .multilineTextAlignment(.leading)
                            .font(.callout)
                        Spacer()
                        
                        Text("\(timeString)")
                            .font(.caption2)
                             .opacity(colorScheme == .light ? 0.6 : 0.4)
                            .offset(x: -4, y: 3)
                    }
                    Spacer()
                }
//                if post != nil {
//                    Text(post.content)
//                        .font(.subheadline)
//                        .italic()
//                        .padding(.horizontal)
//                        .frame(height: 10)
//                        .opacity(0.8)
//
//                }
            } .foregroundColor(Color.mainColor)
        }
        if notificationType == .commentMention {
            VStack (alignment: .leading){
                HStack (spacing: -5) {
                    ZStack {
                    Circle()
                        .frame(width: 54, height: 54)
                        .foregroundColor(friendDictionary.friendsDictionary[id]?.profileCircle)
    //                                .foregroundColor(Color.mainColor)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                        .clipShape(Circle())
                    WebImage(url: friendDictionary.friendsDictionary[id]?.profilePicLink)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .background(Color.lightGray)
                        .clipShape(Circle())
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            FriendProfileMatchedGeometryEffect = id
                        }
                }
                    HStack (alignment:. top){
                        
                        Text("\(friendDictionary.friendsDictionary[id]?.name ?? "") mentioned you in a comment")
                            .multilineTextAlignment(.leading)
                            .font(.callout)
                        Spacer()
                        Text("\(timeString)")
                            .font(.caption2)
                             .opacity(colorScheme == .light ? 0.6 : 0.4)
                            .offset(x: -4, y: 3)
                    }
                    Spacer()
                }
//                if post != nil {
//                    Text(post.content)
//                        .font(.subheadline)
//                        .italic()
//                        .padding(.horizontal)
//                        .frame(height: 10)
//                        .opacity(0.8)
//
//                }
            } .foregroundColor(Color.mainColor)
        }
        if notificationType == .sharedF {
            VStack (alignment: .leading){
                HStack (spacing: -5) {
                    ZStack {
                    Circle()
                        .frame(width: 54, height: 54)
                        .foregroundColor(friendDictionary.friendsDictionary[id]?.profileCircle)
    //                                .foregroundColor(Color.mainColor)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                        .clipShape(Circle())
                    WebImage(url: friendDictionary.friendsDictionary[id]?.profilePicLink)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .background(Color.lightGray)
                        .clipShape(Circle())
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            FriendProfileMatchedGeometryEffect = id
                        }
                }
                    HStack (alignment:. top){
                        
                        Text("\(friendDictionary.friendsDictionary[sentFromUser ?? ""]?.name ?? "") shared a friend with you")
                            .multilineTextAlignment(.leading)
                            .font(.callout)
                        Spacer()
                           
                        Text("\(timeString)")
                            .font(.caption2)
                             .opacity(colorScheme == .light ? 0.6 : 0.4)
                            .offset(x: -4, y: 3)
                    }
                    Spacer()
                }
//                if post != nil {
//                    Text(post.content)
//                        .font(.subheadline)
//                        .italic()
//                        .padding(.horizontal)
//                        .frame(height: 10)
//                        .opacity(0.8)
//
//                }
            } .foregroundColor(Color.mainColor)
        }
        if notificationType == .likedComment {
            VStack (alignment: .leading){
                HStack (spacing: -5) {
                    ZStack {
                    Circle()
                        .frame(width: 54, height: 54)
                        .foregroundColor(friendDictionary.friendsDictionary[id]?.profileCircle)
    //                                .foregroundColor(Color.mainColor)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                        .clipShape(Circle())
                    WebImage(url: webLink)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(.horizontal, 10)
                        .onTapGesture {
//                            FriendProfileMatchedGeometryEffect = id
                        }
                }
                    HStack (alignment:. top){
                        
                        Text("\(nameOfSendingUser ?? "") liked your comment")
                            .multilineTextAlignment(.leading)
                            .font(.callout)
                        Spacer()
                        
                        Text("\(timeString)")
                            .font(.caption2)
                             .opacity(colorScheme == .light ? 0.6 : 0.4)
                            .offset(x: -4, y: 3)
                    }
                    Spacer()
                }
//                if post != nil {
//                    Text(post.content)
//                        .font(.subheadline)
//                        .italic()
//                        .padding(.horizontal)
//                        .frame(height: 10)
//                        .opacity(0.8)
//
//                }
            } .foregroundColor(Color.mainColor)
        }
        if notificationType == .commentReply {
            VStack (alignment: .leading){
                HStack (spacing: -5) {
                    ZStack {
                    Circle()
                        .frame(width: 54, height: 54)
                        .foregroundColor(friendDictionary.friendsDictionary[id]?.profileCircle ?? .clear)
    //                                .foregroundColor(Color.mainColor)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                        .clipShape(Circle())
                    WebImage(url: webLink)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            FriendProfileMatchedGeometryEffect = id
                        }
                }
                    HStack (alignment:. top){
                        
                        Text("\(nameOfSendingUser ?? "") replied to your comment")
                            .multilineTextAlignment(.leading)
                            .font(.callout)
                        
                        Spacer()
                        
                        Text("\(timeString)")
                            .font(.caption2)
                             .opacity(colorScheme == .light ? 0.6 : 0.4)
                            .offset(x: -4, y: 3)
                    }
                    Spacer()
                }
//                if post != nil {
//                    Text(post.content)
//                        .font(.subheadline)
//                        .italic()
//                        .padding(.horizontal)
//                        .frame(height: 10)
//                        .opacity(0.8)
//
//                }
            } .foregroundColor(Color.mainColor)
        }
        if notificationType == .alsoC {
            VStack (alignment: .leading){
                HStack (spacing: -5) {
                    ZStack {
                    Circle()
                        .frame(width: 54, height: 54)
                        .foregroundColor(friendDictionary.friendsDictionary[id]?.profileCircle)
    //                                .foregroundColor(Color.mainColor)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                        .clipShape(Circle())
                    WebImage(url: friendDictionary.friendsDictionary[id]?.profilePicLink)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            FriendProfileMatchedGeometryEffect = id
                        }
                }
                    HStack (alignment:. top){
                        
                        Text("\(friendDictionary.friendsDictionary[id]?.name ?? "") also commented on this moment")
                            .multilineTextAlignment(.leading)
                            .font(.callout)
                        Spacer()
                            
                        Text("\(timeString)")
                            .font(.caption2)
                             .opacity(colorScheme == .light ? 0.6 : 0.4)
                            .offset(x: -4, y: 3)
                    }
                    Spacer()
                }
//                if post != nil {
//                    Text(post.content)
//                        .font(.subheadline)
//                        .italic()
//                        .padding(.horizontal)
//                        .frame(height: 10)
//                        .opacity(0.8)
//
//                }
            } .foregroundColor(Color.mainColor)
        }
        if notificationType == .like {
            VStack (alignment: .leading) {
                HStack (spacing: -5) {
                ZStack {
                Circle()
                    .frame(width: 54, height: 54)
                    .foregroundColor(friendDictionary.friendsDictionary[id]?.profileCircle)
//                                .foregroundColor(Color.mainColor)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                    .clipShape(Circle())
                    WebImage(url: friendDictionary.friendsDictionary[id]?.profilePicLink)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            FriendProfileMatchedGeometryEffect = id
                        }
                }
                    HStack (alignment:. top){
                        
                        Text("\(friendDictionary.friendsDictionary[id]?.name ?? "") liked your moment")
                            .multilineTextAlignment(.leading)
                            .font(.callout)
                        Spacer()
                         Text("\(timeString)")
                            .font(.caption2)
                             .opacity(colorScheme == .light ? 0.6 : 0.4)
                            .offset(x: -4, y: 3)
                    }
                    Spacer()
                }
//                if post != nil {
//                    Text(post.content)
//                        .font(.subheadline)
//                        .italic()
//                        .padding(.horizontal)
//                        .frame(height: 10)
//                        .opacity(0.8)
//
//                }
            } .foregroundColor(Color.mainColor)
            
        }
        if notificationType == .friendRequest {
            VStack {
                HStack (spacing: -5) {
                    WebImage(url: friendDictionary.friendsDictionary["ctgg158KOnajMBuFZ5GyHLyRYPE3"]?.profilePicLink)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(.horizontal, 10)

                    HStack (alignment:. top){
               
                            Text("New friend request")
                                .multilineTextAlignment(.leading)
                                .font(.callout)
                        Spacer()
                            Text("\(timeString)")
                                .font(.caption2)
                                 .opacity(colorScheme == .light ? 0.6 : 0.4)
                                .offset(x: -4, y: 3)
                    }
                    Spacer()
                }
                
            } .foregroundColor(Color.mainColor)
        }
        if notificationType == .acceptedRequest {
            HStack (spacing: -5) {
                ZStack {
                Circle()
                    .frame(width: 54, height: 54)
                    .foregroundColor(friendDictionary.friendsDictionary[id]?.profileCircle)
//                                .foregroundColor(Color.mainColor)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                    .clipShape(Circle())
                WebImage(url: friendDictionary.friendsDictionary[id]?.profilePicLink)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding(.horizontal, 10)
            }
                HStack (alignment:. top){
                    
                    Text("\(friendDictionary.friendsDictionary[id]?.name ?? "") accepted your friend request")
                        .multilineTextAlignment(.leading)
                        .font(.callout)
                    Spacer()
                    Text("\(timeString)")
                        .font(.caption2)
                        .opacity(colorScheme == .light ? 0.6 : 0.4)
                        .offset(x: -4, y: 3)
                }
                Spacer()
            } .foregroundColor(Color.mainColor)
        }
        }
#if os(macOS)
        .padding(.trailing,20)
#endif
//        .overlay(Color.red.opacity(0.3))
    }
    
}
