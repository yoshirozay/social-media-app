//
//  CreateNewTag.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 8/27/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Combine
 

struct CreateNewTag: View {

    @State var description = ""
    @State var filter = ""
    @State var selectedUser: [String]  = [Auth.auth().currentUser?.uid ?? ""]
    @Binding var CreateTagMatchedGeometry: String
    @State var isAnimating = false
    @State var falseBinding = false
    @State var trueBinding = true
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @ObservedObject var myTags: MyTagsOO
    @StateObject var functions = CreateTagFunction()
    @State private var isEmoji: Bool = true
    @State private var text: String = ""
    @State var isFromTabView = false
    var body: some View {
        ZStack(alignment: .top) {
            Color.mainColorInverse
                .ignoresSafeArea(.all)
            VStack {
                HStack (spacing: 10) {
                    Button(action: {
                        CreateTagMatchedGeometry = ""
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                          .foregroundColor(Color.mainColor)
                            .padding(.leading)
                    }.buttonStyle(.borderless)
                  
                    
                    Text("New Key")
                        .font(.title)
                        .fontWeight(.bold)
                      .foregroundColor(Color.mainColor)

                    
                    
                    Spacer()
                    
                    Button(action: {
                        if text != "" && description != "" {
                            functions.createTag(name: text, description: description, friendIDs: selectedUser)

                            CreateTagMatchedGeometry = ""
                        }
                    }){
                        Text("Create")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.speakerPink.opacity(1))
                            .padding(.trailing)
                    }.buttonStyle(.borderless)
                    
                }
              .foregroundColor(Color.mainColor)
                HStack() {
                    ZStack {
                        LinearGradient(gradient: .init(colors: [Color.speakerPink.opacity(1), Color.speakerPurple.opacity(1)]), startPoint: .top, endPoint: .bottom)
                            .frame(width: 90, height: 90)
                            .clipShape(Hexagon())
                            .shadow(radius: 2, x: 0, y: 2)
                            .shadow(radius: 2, x: 2, y: 0)
                        Text("\(text)")
                            .foregroundColor(.mainColorInverse)
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    ZStack {
                    HStack {
                        
//                        TextField("#toronto", text: $textBindingManager.text)
                        EmojiTextField(text: $text, placeholder: "Enter emoji", isEmoji: $isEmoji)
                            .onReceive(Just(text), perform: { _ in
                                // This allow only emoji
                                self.text = self.text.onlyEmoji()
                                self.text = String(self.text.onlyEmoji().prefix(1))
                                /*
                                 //This allow only emoji and allow only 3 emoji
                                
                                 */
                            })
//                            .autocapitalization(.none)
//                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title)
                            .foregroundColor(.mainColor)
                            .padding(.horizontal, 10)
                            .frame(width: screenWidth/1.5, height: 50)
 
                    }
                    .padding(.vertical, 10)
                    .background(Color.mainColor.opacity(0.05).clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))))
                        
                        Text("\(text.count)/1")
                            .foregroundColor(Color.mainColor.opacity(0.15))
                        .font(.title)
                        .offset(x: 105)
                    }
                    
                }
                .padding(.horizontal)
                VStack {
                    HStack {
                        
                        TextEditor(text: $description)
                            .autocapitalization(.none)
                            .padding(.leading, 10)
                            .frame(height: 80)
                            
                            .overlay(
                                
                                Text("My friends who like to have fun!!")
                                    
                                    .foregroundColor(Color.mainColor.opacity(0.3))
                                    .offset(x: -55, y: -20)
                                    .opacity(description != "" ? 0.0 : 1.0)
                            )
                    }
                    .background(Color.mainColor.opacity(0.05)
                                    
                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))))
                    .padding(.horizontal)
                    
                    if text != ""  && description != "" || isAnimating {
                        EmptyView()
                            .onAppear() {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                                    withAnimation(.easeInOut) {
                                        isAnimating = true
                                    }
                                }
                            }
                        if isAnimating {
                            HStack {
                                Text("INVITE")
                                    .font(.headline)
                                  .foregroundColor(Color.mainColor)
                                    .padding(.leading)
                                    .padding(.top, 10)
                                Spacer()
                            }
                            HStack {
                                TextField("Search", text: $filter)
#if os(macOS) 
                                    .textFieldStyle(.plain)
#endif
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.headline)
                                    .foregroundColor(.mainColor)
                                    .padding(.horizontal, 10)
                                
                            }
                            .padding(.vertical, 3)
                            .background(Color.mainColor.opacity(0.05).clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))))
                            ScrollView() {
                                LazyVStack(){
                                ForEach(filter == "" ? Array(friendsDictionary.friendsDictionary.values.sorted(by: {$1.name.lowercased() > $0.name.lowercased()})) : Array(friendsDictionary.friendsDictionary.values.filter{$0.username.lowercased().contains(filter)}), id: \.self) { item in
  
                                    SelectIndividuals(id: item.id, selectedUser: $selectedUser, selected: selectedUser.contains(item.id) ? $trueBinding : $falseBinding, themeController: ThemeController())
                                        .padding(.horizontal)
                                }
                                }
                            }
                            .transition(.opacity)
                            .padding(.bottom, 30)
                        }
                    }
                }
                .padding(.top, 10)
                Spacer()
            } .padding(.top, 120)
        } .padding(.top, -120)
    }
}
struct CreateNewTag2: View {
    @State var name = ""
    @State var description = ""
    @Binding var CreateTagMatchedGeometry: String
    @State var isEmoji: Bool = true
    @State var placeHolderText: String = "🔒"
    @State var isDescriptionShowing = false
    @State var isLockInvitationShowing: Bool = false
    @State var selectedUser = [Auth.auth().currentUser?.uid ?? ""]
    @State var emptyBoolBinding = false
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @ObservedObject var myTags: MyTagsOO
    @ObservedObject var functions: CreateTagFunction
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            
            themeController.theme.primary
                .ignoresSafeArea(.all)
            VStack {
                HStack {
                    if isDescriptionShowing != true {
                        Button(action: {
//                            withAnimation {
                                CreateTagMatchedGeometry = ""
//                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(Color.black)
                            
                        }
                    } else if isDescriptionShowing == true && isLockInvitationShowing != true {
                        Button(action: {
                            isDescriptionShowing = false
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(Color.black)
                            
                        }
                    } else {
                        Button(action: {
                            isDescriptionShowing = true
                            isLockInvitationShowing = false
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(Color.black)
                            
                        }
                    }
                    Spacer()
                    if isLockInvitationShowing {
                        
                        
                        Text("\(name)")
                            .font(.system(size: 35))
                    }
                    Spacer()
                    //                    ZStack {
                    if isLockInvitationShowing  {
                        Button(action:{
                            functions.createTag(name: name, description: "", friendIDs: selectedUser)
                            CreateTagMatchedGeometry = ""
                        }) {
                            Text("Finish")
                                .font(.headline)
                                .foregroundColor(Color.black)
                        }
                    }
                    //                    }
                }
                .padding(.horizontal)
                
                if isLockInvitationShowing != true {
                    Group {
                        VStack (spacing: 20) {
                            ZStack {
                                LinearGradient(gradient: .init(colors: [Color.mainColorInverse.opacity(0.3), Color.mainColorInverse.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
                                    .frame(width: 225, height: 200)
                                    .clipShape(Circle())
                                
                                ZStack {
//                                    if name == "" {
                                        Text("\(placeHolderText.lowercased())")
                                            .font(.system(size: 100))
                                        
                                    }
//                                    Text("\(name.lowercased())")
//                                        .font(.system(size: 100))
//
//                                }
                            }
//                            if isDescriptionShowing != true {
                                LockName(name: $name, isLockInvitationShowing: $isLockInvitationShowing)
//                            } else {
//                                LockDescription(description: $description, isLockInvitationShowing: $isLockInvitationShowing)
//                            }
                        }

                    }
                    Spacer()
                } else {
                    LockInvitation(selectedUser: $selectedUser, selected: $emptyBoolBinding, lockName: name, lockDescription: description, friendsDictionary: friendsDictionary, themeController: themeController)
                }
                Spacer()
            }
            .offset(y: isLockInvitationShowing != true ? 150 : 0)
            .padding(.top, 20)
            .padding(.top, 60)
        }
        .ignoresSafeArea(.all)
        .padding(.top, -60)
//        .edgesIgnoringSafeArea(.bottom)
    }
}
struct LockName: View {
    @Binding var name: String
    @State private var isEmoji: Bool = true
    @Binding var isLockInvitationShowing: Bool
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    
                    EmojiTextField(text: $name, placeholder: "", isEmoji: $isEmoji)
                        .onReceive(Just(name), perform: { _ in
                            // This allow only emoji
                            withAnimation() {
                                self.name = self.name.onlyEmoji()
                                self.name = String(self.name.onlyEmoji().prefix(1))
                                if self.name.count > 0 {
                                    isLockInvitationShowing = true
                                }
                                /*
                                 //This allow only emoji and allow only 3 emoji
                                 
                                 */
                            }
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    //                            .font(.caption2)
                        .foregroundColor(.black)
                        .offset(x: screenWidth/3.24)
                        .frame(width: screenWidth/1.5, height: 50)
                    
                }
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.05).clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))))
                
                Text("\(name.count)/1")
                    .foregroundColor(Color.black.opacity(0.15))
                    .font(.title)
                    .offset(x: 105)
            }
            Text("Create a friend subset for more private moments")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .frame(width: 300)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
            if name != "" {
                Button(action: {
                    withAnimation() {
                        isLockInvitationShowing = true
                    }
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(Color.speakerPurple)
                        .padding()
                        .padding(.horizontal, 30)
                        .background(Color.mainColorInverse.opacity(0.3))
                        .clipShape(Capsule())
                        .animation(.easeIn(duration: 0.2))
                }
                .disabled(name == "" ? true : false)
            }
        }

    }
}
struct LockDescription: View {
    @Binding var description: String
    @Binding var isLockInvitationShowing: Bool
    @State var textViewMaxHeight: CGFloat = screenHeight*0.4 - 120
    var body: some View {
        VStack {
            
            HStack {
                ZStack {
                    if description == "" {
                        Text("Description")
                            .foregroundColor(Color.mainColor.opacity(0.3))
                            .offset(x: -screenWidth/5)
                    }
                    ExpandingTextView(text: $description, maxHeight: $textViewMaxHeight, isFirstResponder: true)
                }
            }
            .padding(.leading, 10)
            .padding(.vertical, 20)
            .background(Color.black.opacity(0.05).clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))))
            .foregroundColor(.black)
            .frame(width: screenWidth/1.5, height: 50)
            
            Button(action: {
                hideKeyboard()
                isLockInvitationShowing = true
            }) {
                Text(description == "" ? "Skip" : "Next")
                    .font(.headline)
                    .foregroundColor(Color.speakerPurple)
                    .padding()
                    .padding(.horizontal, 30)
                    .background(Color.mainColorInverse.opacity(0.3))
                    .clipShape(Capsule())
            }
            .padding(.top, 30)
        } .transition(.slide)
            .padding(.top, 20)
    }
}
struct LockInvitation: View {

    @Binding var selectedUser: [String]
    @Binding var selected: Bool
    @State var lockName: String
    @State var lockDescription: String
    @State var falseBinding = false
    @State var trueBinding = true
    @ObservedObject var friendsDictionary: FriendsDictionary
    @ObservedObject var themeController: ThemeController
//    let friendData: [PostModel] = Bundle.main.decode("posts.json")
    var body: some View {
        VStack (alignment: .leading) {
            //            Divider()
            Text("Your friends will not be notified when they are included in \(lockName)")
                .padding(.horizontal)
                .font(.footnote)
                .padding(.top, 10)
                .foregroundColor(Color.black)
            VStack (alignment: .leading) {
                Text("ADD MEMBERS")
                    .font(.headline)
                    .padding(.leading, 16)
                    .foregroundColor(Color.black)
                ScrollView() {
                    VStack {
                        ForEach(friendsDictionary.friendsDictionary.values.sorted(by: {$1.name.lowercased() > $0.name.lowercased()}), id: \.self) { item in
                            SelectIndividuals(id: item.id, selectedUser: $selectedUser, selected: selectedUser.contains(item.id) ? $trueBinding : $falseBinding, themeController: themeController)
                                .padding(.horizontal)
                            //
                        }
//                        SelectIndividuals(photo: item.photo, name: item.name, username: item.username, selectedUser: $selectedUser, selected: selectedUser.contains(item.name) ? $trueBinding : $falseBinding)
//                            .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 10)
            .transition(.opacity)
            
            Spacer()
        }
    }
}
struct CreateTagTabView: View {
    @Binding var CreateTagMatchedGeometry: String
    @State var selectedTab = "tag"
    @ObservedObject var myTag: MyTagsOO
    @ObservedObject var functions: CreateTagFunction
    @ObservedObject var themeController: ThemeController
    var body: some View {
        if selectedTab == "tag" {
            ZStack {
                let createNewTag =   CreateNewTag2(CreateTagMatchedGeometry: $CreateTagMatchedGeometry, myTags: myTag, functions: functions, themeController: themeController)
#if os(iOS) 
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    createNewTag
                        .tag("tag")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                createNewTag
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    CreateTagMatchedGeometry = ""
                }
        }
    }
}

