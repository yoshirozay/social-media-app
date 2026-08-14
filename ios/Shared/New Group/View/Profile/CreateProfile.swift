//
//  CreateProfile.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/6/21.
//
 

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore

struct CreateProfile: View {
    @State var isShowingImagePicker = false
    @State var newMedia: NewMedia?
    @State var name: String = ""
    @State var username: String = ""
    @State var bio: String = ""
    @Binding var isFirstLogin: Bool
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var functions = CreateProfileFunction()
    @State var isUsernameTaken = false
//    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var sendPhotoButton : some View
    {
        ZStack {
            if let userImage = newMedia?.image {
                Image(uiImage: userImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .onTapGesture {
                        isShowingImagePicker = true
                    }
            }else{
                Image(systemName: "person.crop.circle.badge.plus")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .onTapGesture {
                        isShowingImagePicker = true
                    }
            }
        } .presentMediaPicker(isPresented: $isShowingImagePicker, newMedia: $newMedia,parentView: .userProfile)
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack (spacing: 5) {
                    
                    Text("Create Profile")
                        .fontWeight(.bold)
                        .font(.title)
                      .foregroundColor(Color.mainColor)
                    Spacer()
               
                    if username != "" , name != "" , bio != "" , let userImage = newMedia?.image {
                        Button(action: {
//                            functions.createProfile(name: name, username: username, bio: bio, uid: Auth.auth().currentUser!.uid, photo: userImage, token: notificationToken)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                isFirstLogin = false
                            }
                        }){
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(Color.blue)
                        }
                    }
                }
                .padding(.horizontal, 18)
                VStack {
                    sendPhotoButton
                        .padding(25)
                    
                    HStack (spacing: 30) {
                        VStack (alignment: .leading, spacing: 10) {
                            
                            Text("Username")
                                .padding(.bottom, 7)
                            Text("Display Name")
                                .padding(.bottom, 7)
                            Text("Bio")
                                .padding(.bottom, 7)
                            
                        }
                        .offset(y: 4)
                        
                        VStack {
                            
                            TextField(username == "" ? "Username" : username, text: self.$username)
                            
                            Divider()
                            TextField(name == "" ? "Name" : name, text: self.$name)
                            Divider()
                            TextField(bio == "" ? "Bio" : bio, text: self.$bio)
                            Divider()
                            
                        }
                        
                    } // HSTACK
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                }
                Spacer()
              
            }
            
        }
    }
    func tryUsername(username: String) {
        let docRef  = Firestore.firestore().collection("UserInfo")
        docRef.whereField("username", isEqualTo: "@\(username.lowercased())").getDocuments { (snap, err) in
            if err != nil {
                print((err?.localizedDescription) ?? "error in editProfile")
                return
            }
            let UserImage = newMedia?.image
            guard let snap = snap else { return  }
            for i in snap.documents {
                
                if Auth.auth().currentUser?.uid == i.documentID {
//                    functions.createProfile(name: name, username: username, bio: bio, uid: Auth.auth().currentUser?.uid, photo: UserImage, token: notificationToken, school: "")
//                    isFirstLogin = false
                    print("notificationToken = \(notificationToken)")

                } else {
                    print("username is already taken")
                    isUsernameTaken = true
                }
            }
            if snap.isEmpty {
                print("username is good to go")
//                functions.createProfile(name: name, username: username, bio: bio, uid: Auth.auth().currentUser?.uid, photo: UserImage, token: notificationToken, school: "")
                isFirstLogin = false
 
            }
        }
    }
}

