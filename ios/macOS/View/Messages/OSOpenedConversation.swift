////
////  OSOpenedConversation.swift
////  speakEZ crossplatform (macOS)
////
////  Created by Carson O'Sullivan on 2/1/21.
////
//
import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth
struct OSOpenedConversation: View {
    @Binding var OSOpenedChatMatchedGeometry: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var allMessages : OpenedConversationOO
    @State var id2: String
    @State var message = ""
    @Binding var OSNewConversationMatchedGeometry: String
    var body: some View {
        ZStack {
            VStack {
                ZStack(alignment: .top) {
                    HStack  {
                        
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .padding(.bottom, 10)
                            .padding(.horizontal, 10)
                            .onTapGesture {
                                OSOpenedChatMatchedGeometry = ""
                                OSNewConversationMatchedGeometry = ""

                            }
                        
                        Spacer()
                        
                        WebImage(url: friendsDictionary.friendsDictionary[id2]?.profilePicLink)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .padding(.horizontal)
                        
                    } // HSTACK
                    VStack {
                        Text(friendsDictionary.friendsDictionary[id2]?.name ?? "")
                            .fontWeight(.bold)
                        Text(friendsDictionary.friendsDictionary[id2]?.username ?? "")
                            .font(.caption)
                            .fontWeight(.light)
                    } // VSTACK
                    .padding(.horizontal)
                } // ZSTACK
                .foregroundColor(.mainColor)
              
                .padding(.top)

                
                // Displaying Message
                VStack {
                    ScrollView(.vertical, showsIndicators: false, content: {
                        if !allMessages.messages.isEmpty{
                        ZStack {
                            ScrollViewReader { reader in
                                LazyVStack (spacing: 10) {
                                    //
                                    ForEach(allMessages.messages, id: \.id) { item in
                                        //                             Chat bubble
                                        OSChatBubble(message: item, myMessage: item.sentBy)
                                            .id(item.id)
                                        
                                    }
                                }
                                
                                .padding(.top, -10)
                                .onAppear() {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        
                                        reader.scrollTo(allMessages.messages[allMessages.messages.endIndex-1].id)
                                    }
                                }
                                .onChange(of: allMessages.messages) { (value) in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        reader.scrollTo(allMessages.messages[allMessages.messages.endIndex-1].id)
                                    }
                                }
                                
                                .padding([.horizontal, .bottom])
                                .padding(.top, 25)
                            }
                            
                        }
                        }
                    })
                    Spacer()
                    
                    HStack(spacing: 0) {
                        HStack(spacing: 5) {
                            
                            
                            TextField("Message", text: $message)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                                
                                
                            Image(systemName: "paperclip.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.mainColor)
                                .padding(.vertical, 12)
                            
                            
                        } // HSTACK
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.mainColor)
                                    // Rotating paperplane
                                    .rotationEffect(.init(degrees: 45))
                                    // Padding Shape
                        
                    } // HSTACK
                    .padding(.horizontal, 10)
                    .padding(.bottom, 16)
                    
                } // VStack, main container
              
            }
        }
        .ignoresSafeArea(.all)
    }
}
//

struct OSChatBubble: View {
    @State var offset: CGFloat = 0
    let message : MessageModel
    @State var myMessage: String
    var body: some View {
        
        HStack (alignment: .top, spacing: 10) {
            if myMessage == Auth.auth().currentUser?.uid {
                // Pushing message to the right
                // Minimum space
                
                HStack (spacing: 20) {
                    Spacer(minLength: 25)
                    Text(message.message)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.purple.opacity(0.3))
                        .foregroundColor(.mainColor)
                        .clipShape(ChatBubbleShape(direction: .right))
                        .gesture(
                            DragGesture()
                                .onChanged({ (value) in
                                    if value.translation.width < 50 {
                                        //                                        offset = -80
                                    }
                                    
                                })
                                .onEnded({ (value) in
                                    
                                    offset = 0
                                }
                                ))
                    Text(message.timeString)
                        .font(.caption)
                        .frame(width: 66)
                }
                .offset(x: 85+offset)
                .padding(.top, -5)
                
            } else {
                    
                    HStack (spacing: 20) {
                        Text(message.timeString)
                            .font(.caption)
                            .frame(width: 66)
                        
                        Text(message.message)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color.mainColor.opacity(0.06))
                            .foregroundColor(.mainColor)
                            .clipShape(ChatBubbleShape(direction: .left))
                            .gesture(
                                DragGesture()
                                    .onChanged({ (value) in
                                        
                                        if value.translation.width > 50 {
                                            //                                        offset = 80
                                        }
                                        
                                    })
                                    .onEnded({ (value) in
                                        
                                        offset = 0
                                    }
                                    ))
                        
                        Spacer(minLength: 25)
                    }
                    .offset(x: -85+offset)
                    .padding(.top, -5)
                
            }
            
        }
        
    }
    
}
