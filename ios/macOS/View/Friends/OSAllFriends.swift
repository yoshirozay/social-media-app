////
////  OSAllFriends.swift
////  speakEZ crossplatform (macOS)
////
////  Created by Carson O'Sullivan on 2/1/21.
////
//
import SwiftUI
import SDWebImageSwiftUI
//
struct OSAllFriends: View {
    @Namespace var namespace
    @State var text = ""
    @State var FriendProfileMatchedGeometry = ""
    @State var photo: String = "dantal-1"
    @State var name: String = "D'antal Sampson"
    @State var username: String = "@dantal"
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    var body: some View {
        ZStack {
            Color.mainColorInverse.opacity(0.3)
                .ignoresSafeArea(.all)
            VStack {
                HStack(spacing: 15) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 12, height: 12)
                    //                    .foregroundColor(Color.mainColor.opacity(0.3))
                    TextField("Search Friends", text: self.$text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if self.text != "" {
                        Image(systemName: "clear")
                            .font(.headline)
                            .foregroundColor(.mainColor)
                            .opacity(0.2)
                            .onTapGesture {
                                self.text = ""
                            }
                        
                    }
                }// HSTACK
                
                .padding(10)
                .padding(.trailing, 30)
                .padding(.leading, 18)
                Color.purple.opacity(0.15)
                    .frame(width: screenWidth/2.13, height: 2)
                ForEach(text != "" ? Array(friendsDictionary.friendsDictionary.values.filter{$0.name.contains(self.text.lowercased())}) : Array(friendsDictionary.friendsDictionary.values)){ item in
                    
                    OSFriendsResults(id: item.id)
                        .matchedGeometryEffect(id: UUID(), in: namespace, isSource: false)
                        .padding(.leading, -16)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.3)) {
                                FriendProfileMatchedGeometry = item.id

                            }
                        }
                } .padding(.leading)
                Spacer()
                //
            }
            .opacity(FriendProfileMatchedGeometry == "" ? 1 : 0)
            
            if FriendProfileMatchedGeometry != "" {
//                OSFriendProfile(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, postData: FriendsPostsOO(id: FriendProfileMatchedGeometry), id: FriendProfileMatchedGeometry)
            }
        }
        .padding(.trailing, -screenWidth/179.2) // -10
        
    }
}


//
struct OSFriendsResults: View {
    @State var id: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State private var showingAlert = false
    var body: some View {
        VStack{
            HStack (spacing: 12) {
                WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(friendsDictionary.friendsDictionary[id]?.name ?? "")
                        .font(.headline)
                    Text(friendsDictionary.friendsDictionary[id]?.username ?? "")
                        .font(.caption)
                        .padding(.top, -10)
                } // VSTACK
                .foregroundColor(.mainColor)
                Spacer()
                
                Image(systemName: "xmark")
                    .foregroundColor(Color.purple.opacity(0.7))
                    .font(.title3)
                    .onTapGesture {
                        showingAlert = true
                    }
                    .alert(isPresented:$showingAlert) {
                        Alert(title: Text("Are you sure you want to delete this friend?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                            print("Deleting...")
                        }, secondaryButton: .cancel())
                    }
                
                
                
                
                
            } // HSTACK
            .padding(.horizontal)
            Divider()
        }
    }
}
 
