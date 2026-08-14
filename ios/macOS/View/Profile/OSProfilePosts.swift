//////
//////  OSProfilePosts.swift
//////  speakEZ crossplatform (macOS)
//////
//////  Created by Carson O'Sullivan on 2/4/21.
//////
//
import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth
//
struct OSProfilePosts: View {

    @State var postData: PostModel
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var hasBeenLiked = false
    @State var isPostOpened = false
    var body: some View {
        if isPostOpened == false {
        ZStack {

            VStack {
                VStack {
                    HStack (spacing: 10) {

                         let userId = Auth.auth().currentUser?.uid ?? ""
                        
                        WebImage(url: friendsDictionary.friendsDictionary[userId]?.profilePicLink)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                        
                        HStack(alignment: .top) { // necessary to align timestamp with name
                            VStack(alignment: .leading, spacing: 2) {
                                Text(friendsDictionary.friendsDictionary[userId]?.name ?? "")
                                    .fontWeight(.bold)
                                Text(friendsDictionary.friendsDictionary[userId]?.username ?? "")
                                    .font(.caption)
                            } // VSTACK
                            Spacer()
                            Text(postData.timeString)
                                .font(.caption)
                                .padding(.horizontal, 10)
                        } // HSTACK
                        .foregroundColor(.mainColor)
                        
                    } // HSTACK
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    HStack {
                        Text(postData.content)
                            .font(.title3)
                            .padding(.horizontal, 16)
                        Spacer()
                    } // HSTACK
                    if let photoLink = postData.photoLink  {
                        WebImage(url: photoLink)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 355, height: 400, alignment: .center)
                            .background(Color.mainColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                         .resizable()
//                            .frame(width: 355, height: 400, alignment: .center)
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                            .scaledToFill()
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.3)) {
//                                    OpenedPhotoMatchedGeometry = "0"
//                                    OpenedPhotoSelectedItem = postData.photo
                                }
                            }
                    }
                }
                .padding(.vertical, 10)
                Spacer()
                    .foregroundColor(.mainColor)
            }
            
        } .background(BlurView())
        .contentShape(Rectangle())
        .onTapGesture {
            
            isPostOpened.toggle()
            
        }
     
        }  else if  let userId = Auth.auth().currentUser?.uid   {
            OSProfileOpenedPost(isPostOpened: $isPostOpened, comments: CommentsOO(id: userId, postID: postData.postID), likes: LikesOO(id: userId, postID: postData.postID), postData: postData, hasBeenLikedOO: HasPostBeenLikedOO(id: userId, postID: postData.postID))
        }
    }
}
////
struct OSProfileOpenedPost: View {
    @Namespace var namespace
    @State var LikesProfileMatchedGeometry: String = ""
    @State var hasBeenLiked = false
    @Binding var isPostOpened: Bool
    @State var text = ""
    @StateObject var comments = CommentsOO(id: "", postID: "")
    @StateObject var likes = LikesOO(id: "", postID: "")
    @State var postData: PostModel
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var hasBeenLikedOO = HasPostBeenLikedOO(id: "", postID: "")
    //FIXME: - have no idea what myID is need to confirm 
    var myID : String{
        postData.id
    }
    var body: some View {
        ZStack {
            VStack{
            VStack {
                VStack {
                    HStack (spacing: 10) {

                        WebImage(url: friendsDictionary.friendsDictionary[myID]?.profilePicLink)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                        
                        HStack(alignment: .top) { // necessary to align timestamp with name
                            VStack(alignment: .leading, spacing: 2) {
                                Text(friendsDictionary.friendsDictionary[myID]?.name ?? "")
                                    .fontWeight(.bold)
                                Text(friendsDictionary.friendsDictionary[myID]?.username ?? "")
                                    .font(.caption)
                            } // VSTACK
                            Spacer()
                            Text(postData.timeString)
                                .font(.caption)
                                .padding(.horizontal, 10)
                        } // HSTACK
                        .foregroundColor(.mainColor)
                        
                    } // HSTACK
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    HStack {
                        Text(postData.content)
                            .font(.title3)
                            .padding(.horizontal, 16)
                        Spacer()
                    } // HSTACK
                    if let photoLink = postData.photoLink  {
                        WebImage(url: photoLink)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 355, height: 400, alignment: .center)
                            .background(Color.mainColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
//                            .resizable()
//                            .frame(width: 355, height: 400, alignment: .center)
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                            .scaledToFill()
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.3)) {
//                                    OpenedPhotoMatchedGeometry = "0"
//                                    OpenedPhotoSelectedItem = postData.photo
                                }
                            }
                    }
                }
                .padding(.vertical, 10)
//                Spacer()
                    .foregroundColor(.mainColor)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isPostOpened.toggle()
                
            }
                Group {
                HStack {
                    
                        Image(systemName: "heart")
                        .foregroundColor(hasBeenLiked ? Color.red.opacity(0.7) : Color.mainColor.opacity(0.7))
                            .onTapGesture {
                                hasBeenLiked.toggle()
                            }
                    Group {
                        if likes.postLikes.count == 1 {
                        
                            (Text("Liked by ") + Text("\(likes.postLikes[0].name) ").bold())
                            .font(.caption)
                            .padding(.leading, 9)
                            .foregroundColor(.mainColor)
                                .onTapGesture{
                                    LikesProfileMatchedGeometry = "0"
                                }
                        
                        .matchedGeometryEffect(id: UUID(), in: namespace)
                        }
                        if likes.postLikes.count > 1 {
                    
                            (Text("Liked by ") + Text("\(likes.postLikes[0].name) ").bold() + Text("and ") + Text("others").bold())
                            .font(.caption)
                            .padding(.leading, 9)
                            .foregroundColor(.mainColor)
                                .onTapGesture{
                                    LikesProfileMatchedGeometry = "0"
                                }
                        
                        .matchedGeometryEffect(id: UUID(), in: namespace)
                        }
                    Spacer()
                } // Likes
                }
                    .frame(height: 25)
                    .padding(.leading, 21)
                    Color.purple.opacity(0.15)
                        .frame(width: screenWidth/3.3, height: 2)
                    
                ZStack (alignment: .bottomTrailing) {
//                ScrollView(showsIndicators: false) { // Comments
                    LazyVStack() {
                        ForEach(Array(comments.comments), id: \.self) { item in
                              OSComment(comments: comments, comment: item)
                              Divider()
                          }
//                        ForEach(Array(comments.commentDict.keys), id: \.self) { item in
//                            OSComment(comments: comments, dictionaryID: item)
//                            Divider()
//                        }
                        HStack {
                        TextField("Comment", text: self.$text)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.mainColor)
                                // Rotating paperplane
                                .rotationEffect(.init(degrees: 45))
                                // Padding Shape
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    } .padding(.top, 10)
//                }
                }
                
                }
            
                Spacer()
            }
        
        } .background(BlurView())

    }
}
