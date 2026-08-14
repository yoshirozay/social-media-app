//
//  EditProfile.swift
//  speakEZ crossplatform (iOS)
//
//  Created by Carson O'Sullivan on 2/13/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore
 
struct EditProfile: View {
    @Binding var EditProfileMatchedGeometry: String
    @State var isShowingImagePicker = false
    @State var newMedia: NewMedia?
 
    @State var name: String = ""
    @State var username: String = ""
    @State var bio: String = ""
    @State var school = String()
    @State var photoLink: URL?
    @Binding var signOut: Bool
    @StateObject var login = LoginOO()
    @StateObject var functions = EditProfileFunction()
    @StateObject var newPostfunction = NewPostFunctions()
    @State var emptyBoolBinding = false
    @State var newUsername = ""
    @State var isUsernameTaken = false
    @Binding var isShowingChangedProfilePictureMessage: Bool
    @EnvironmentObject var friendsDictionary: FriendsDictionary
//    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var allowedCharacters: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    @State var doesContainSpecialCharacter = false
    @State var selectedProfileCircle: String = ""
    @StateObject var profileCircles = ProfileCirclesOO()
    @StateObject var circleFunctions = ProfileCircleFunctions()
    @Environment(\.colorScheme) var colorScheme
    @StateObject var preferences = ProfilePreferencesOO()
    @State var isMomentNotificationsShowing = false
    @State var isCommentNotificationsShowing = false
    @State var hasSetKeyboardDismissMode: Bool = false
    @State var isAlertShowing: Bool = false
    @State var isShowingLogoutAlert = false
    @State var isShowingThemesLight = false
    @State var isShowingThemesDark = false
    @ObservedObject var themeController: ThemeController
    var profileImageButton : some View {
        ZStack {
#if os(iOS)
            let width : CGFloat = 100
#elseif os(macOS)
            let width : CGFloat = screenWidth*0.3
#endif
 
            if let userImage = newMedia?.image {
                Image(uiImage: userImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: width)
                    .clipShape(Circle())
                    .onTapGesture {
                        isShowingImagePicker = true
                    }
            }else{
                ZStack {
                    Circle()
                        .frame(width: width+5, height: width+5)
                        .foregroundColor(themeController.theme.primary.opacity(0.6))
                        .clipShape(Circle())
                WebImage(url: photoLink)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: width)
                    .clipShape(Circle())
                    .onTapGesture {
                        isShowingImagePicker = true
                    }
                }
            }
            
        } .presentMediaPicker(isPresented: $isShowingImagePicker, newMedia: $newMedia,parentView: .userProfile)
    }
    
    func doneTap(){
        let UserImage = newMedia?.image
//        if name != friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid]?.name || bio != friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid]?.bio || "@\(newUsername)" != friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid]?.username || school != friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid]?.school || UserImage != nil{
//
//            updateUsernameIfAvailable()
//
//            if isUsernameTaken == false && UserImage != nil {
//                isShowingChangedProfilePictureMessage = true
//            }
//        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if doesContainSpecialCharacter == false {
               let userId = Auth.auth().currentUser?.uid ?? ""
                if name != friendsDictionary.friendsDictionary[userId]?.name || bio != friendsDictionary.friendsDictionary[userId]?.bio || "@\(newUsername)" != friendsDictionary.friendsDictionary[userId]?.username || school != friendsDictionary.friendsDictionary[userId]?.school || UserImage != nil {
                    updateUsernameIfAvailable()
                } else {
                    EditProfileMatchedGeometry = ""
                    hideKeyboard()
                }
            }
        }
        if selectedProfileCircle != "" {
            updateProfileCircle(color: selectedProfileCircle)
        }
       
    }
    
    func shareDynamicLink() {
        
    }
    @StateObject var shareActivity = ShareActivityOO()
    @StateObject var momentNotificationMembers = MomentNotificationOO()
    @StateObject var commentNotificationMembers = CommentNotificationOO()
    var body: some View {
        ZStack {
            ZStack(alignment: .bottom) {
                themeController.theme.primary
                .edgesIgnoringSafeArea(.all)
            //            ScrollView(showsIndicators: false) {
            VStack {
                HStack (spacing: 5) {
                    
                    Button(action: {
                        EditProfileMatchedGeometry = ""
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .foregroundColor(Color.black)
                    }.buttonStyle(.borderless)
                        .padding(.leading,-10)
                    Text("Edit Profile")
                        .fontWeight(.bold)
                        .font(.title)
                        .foregroundColor(Color.black)
                    
                    Spacer()
                    Button(action: doneTap){
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(themeController.theme.accent)
                    }
                    .opacity(name != "" &&  username != "" ? 1 : 0)
                    .disabled(name != "" && username != "" ? false : true)
                }
                .padding(.horizontal, 18)
                VStack {
                    HStack {
                        profileImageButton
                            .padding(.horizontal, 10)
                        VStack {
                            TextField(username == "" ? "Username" : username, text: self.$newUsername)
                                .foregroundColor(.black)
                                .disableAutocorrection(true)
                                .onAppear() {
                                    newUsername = String(username.dropFirst())
                                }
                            Rectangle()
                                .frame(width: screenWidth / 1.9, height: 2)
                                .offset(x: -7)
                                .foregroundColor((colorScheme == .light ?
                                                  Color.white.opacity(1) : Color.white.opacity(0.4)))
                            TextField(name == "" ? "Name" : name, text: self.$name)
                                .disableAutocorrection(true)
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 10)
                        .padding(.leading, 10)
                        .background(themeController.theme.primary.opacity(0.4).cornerRadius(15))
                        .padding(.trailing, 20)
                    }
                    .padding(.vertical)
                    .background(themeController.theme.secondary.cornerRadius(25))
                    .padding(10)
                    if isUsernameTaken == true {
                        Text("Username is already in use")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    if doesContainSpecialCharacter == true {
                        Text("Username contains an invalid character")
                            .foregroundColor(.red)
                            .font(.caption)
                        
                    }
                    VStack {
                        Rectangle()
                            .frame(width: screenWidth, height: 5)
                            .foregroundColor(Color.mainColorInverse)
                        VStack {
                            HStack {
                                Text("App Theme")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.bottom, 12)
                                .padding(.top, 6)
                            HStack(spacing: screenWidth/7.7) {
                                Button(action: {
                                    isShowingThemesLight.toggle()
                                }) {
                                    VStack {
                                        VStack(spacing: 0)  {
                                            Text("Light Mode")
                                                .font(.subheadline.weight(.semibold))
                                                .fixedSize(horizontal: true, vertical: false)
                                                .lineLimit(1)
                                            Rectangle()
                                                .frame(width: 80, height: 0.86)
                                        }
                                        .foregroundColor(.black)
                                        HStack (spacing: 4) {
                                            Circle()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(themeController.lightTheme.primary)
                                                .overlay (
                                                    Circle()
                                                        .stroke(Color.mainColorInverse, lineWidth: 0.8)
                                                )
                                            //
                                            Circle()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(themeController.lightTheme.secondary)
                                                .overlay (
                                                    Circle()
                                                        .stroke(Color.mainColorInverse, lineWidth: 0.8)
                                                )
                                            Circle()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(themeController.lightTheme.accent)
                                                .overlay (
                                                    Circle()
                                                        .stroke(Color.mainColorInverse, lineWidth: 0.8)
                                                )
                                        }
                                    }
                                }
                                
                                Rectangle()
                                    .frame(width: 1, height: 84)
                                    .foregroundColor(Color.mainColorInverse)
                                Button(action: {
                                    isShowingThemesDark.toggle()
                                }) {
                                VStack {
                                    VStack(spacing: 0) {
                                        Text("Dark Mode")
                                            .font(.subheadline.weight(.semibold))
                                        Rectangle()
                                            .frame(width: 80, height: 0.86)
                                    }
                                    .foregroundColor(.black)
                                    HStack (spacing: 4) {
                                        Circle()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(themeController.darkTheme.primary)
                                            .overlay (
                                                Circle()
                                                    .stroke(Color.mainColorInverse, lineWidth: 0.8)
                                            )
                                        Circle()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(themeController.darkTheme.secondary)
                                            .overlay (
                                                Circle()
                                                    .stroke(Color.mainColorInverse, lineWidth: 0.8)
                                            )
                                        Circle()
                                            .frame(width: 25, height: 25)
                                            .foregroundColor(themeController.darkTheme.accent)
                                            .overlay (
                                                Circle()
                                                    .stroke(Color.mainColorInverse, lineWidth: 0.8)
                                            )
                                    }
                                }
                            }
                                }
                            
                            .padding(.horizontal, 10)
                            .frame(width: screenWidth - 44, height: 84)
                            .background(themeController.theme.primary.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.black, lineWidth: 0)
                                    .shadow(color: Color.mainColorInverse.opacity(0.25), radius: 4)
                            )
//                            .offset(y: -5)
                          
                        }
                        .padding(.vertical)
                        .background(themeController.theme.secondary.cornerRadius(25))
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        
                        // ANONYMOUS MODE VIEW
//                        anonymousModeView
                        //
                        
                        VStack {
                            Toggle("Moment Notifications", isOn: $preferences.momentNotifications)
                                .foregroundColor(.black)
                                .onChange(of: preferences.momentNotifications) { value in
                                    
                                    ProfilePreferencesOO.updateMomentNotification(momentNotifications: preferences.momentNotifications) {error in
                                    }
                                }
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            ZStack (alignment: .leading) {
                                themeController.theme.primary.opacity(0.4)
                                
                                VStack (alignment: .leading) {
                                    
                                    HStack {
                                        Image(systemName: "")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 20, height: 20)
                                            .scaledToFit()
                                            .background(themeController.theme.primary.opacity(0.4))
                                        
                                            .clipShape(Circle())
                                        Text ("Push Notification")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.black)
                                    }
                                    
                                    .padding(.leading, 5)
                                    
                                    Text("Receive a silent push notification when a new Moment is created")
                                        .font(.body)
                                        .fontWeight(.light)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineLimit(4)
                                        .foregroundColor(Color.black)
                                        .padding(.leading, 10)
                                        .multilineTextAlignment(.leading)
                                        .offset(x: -3, y: -5)
                                        .padding(.trailing, 5)
                                        .padding(.bottom, 8)
                                    
                                }
                                .offset(x: 5, y: 2)
                                .padding(.horizontal, 5)
                                //            .offset(x: -10, y: -30)
                            }
                            .clipShape(ChatBubbleShape(direction: .left))
                            .padding(.horizontal, 10)
                            .frame(height: 95)
                        }
                        .padding(.vertical)
                        .background(themeController.theme.secondary.cornerRadius(25))
                        .padding(.horizontal, 10)
                        // comment & moment notifications, need to add ScrollView back
                        //                        VStack (alignment: .leading){
                        //                            Button(action: {
                        //                                withAnimation {
                        //                                isMomentNotificationsShowing.toggle()
                        //                                }
                        //                            }){
                        //                                HStack (spacing: 0) {
                        //                            Text("Moment Notifications")
                        //                                .font(.headline)
                        //                                .padding(.horizontal)
                        //                             Spacer()
                        //    //
                        //                                    Image(systemName: "chevron.down")
                        //                                        .offset(x: -23, y: 2)
                        //
                        //                            }
                        //                                .foregroundColor(Color.mainColor)
                        //                            }
                        //                            if isMomentNotificationsShowing {
                        ////                                ScrollView(showsIndicators: false) {
                        //                                    LazyVStack {
                        //                                        Rectangle()
                        //                                            .frame(width: screenWidth - 40, height: 2)
                        //                                            .foregroundColor((colorScheme == .light ?
                        //                                                              Color.white.opacity(1) : Color.white.opacity(0.4)))
                        //                                        ForEach(Array(momentNotificationMembers.allFriends.values.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})), id: \.self) { item in
                        //                                            HStack {
                        //                                                WebImage(url: friendsDictionary.friendsDictionary[item.id]?.webLink)
                        //                                                    .resizable()
                        //                                                    .aspectRatio(contentMode: .fill)
                        //                                                    .frame(width: 30, height: 30)
                        //                                                    .clipShape(Circle())
                        //
                        //                                                Text(friendsDictionary.friendsDictionary[item.id]?.name ?? "")
                        //                                                    .font(.body)
                        //                                                Spacer()
                        //                                                Button(action: {
                        //                                                    (momentNotificationMembers.members.firstIndex(of: item.id) != nil) ? momentNotificationMembers.removeID(id: item.id) : momentNotificationMembers.addID(id: item.id)
                        //                                                }){
                        //                                                Circle()
                        //                                                    .frame(width: 20, height: 20)
                        //                                                    .foregroundColor(
                        //                                                        (momentNotificationMembers.members.firstIndex(of: item.id) != nil) ? Color.speakerPurple : Color.speakerPurple.opacity(0.1))
                        //                                                }
                        //                                            }
                        //                                            Rectangle()
                        //                                                .frame(width: screenWidth - 60, height: 2)
                        //                                                .foregroundColor(Color.plumWeb.opacity(0.2))
                        //                                            .padding(.horizontal)
                        //                                        }
                        //
                        //                            }
                        //                                    .padding(.horizontal, 20)
                        ////                                }
                        //                            }
                        //                        }
                        //                        .padding(.vertical)
                        //                        .background(Color.mainColorInverse.opacity(0.6).cornerRadius(25))
                        //                        .padding(10)
                        
                        //                        VStack (alignment: .leading){
                        //                            Button(action: {
                        //                                withAnimation {
                        //                                isCommentNotificationsShowing.toggle()
                        //                                }
                        //                            }){
                        //                                HStack (spacing: 0) {
                        //                            Text("Comment Notifications")
                        //                                .font(.headline)
                        //                                .padding(.horizontal)
                        //                             Spacer()
                        //    //
                        //                                    Image(systemName: "chevron.down")
                        //                                        .offset(x: -23, y: 2)
                        //
                        //                            }
                        //                                .foregroundColor(Color.mainColor)
                        //                            }
                        //                            if isCommentNotificationsShowing {
                        ////                                ScrollView(showsIndicators: false) {
                        //                                    LazyVStack {
                        //                                        Rectangle()
                        //                                            .frame(width: screenWidth - 40, height: 2)
                        //                                            .foregroundColor((colorScheme == .light ?
                        //                                                              Color.white.opacity(1) : Color.white.opacity(0.4)))
                        //                                        ForEach(Array(commentNotificationMembers.allFriends.values.sorted(by: {$0.name.lowercased() < $1.name.lowercased()})), id: \.self) { item in
                        //                                            HStack {
                        //                                                WebImage(url: friendsDictionary.friendsDictionary[item.id]?.webLink)
                        //                                                    .resizable()
                        //                                                    .aspectRatio(contentMode: .fill)
                        //                                                    .frame(width: 30, height: 30)
                        //                                                    .clipShape(Circle())
                        //
                        //                                                Text(friendsDictionary.friendsDictionary[item.id]?.name ?? "")
                        //                                                    .font(.body)
                        //                                                Spacer()
                        //                                                Button(action: {
                        //                                                    (commentNotificationMembers.members.firstIndex(of: item.id) != nil) ? commentNotificationMembers.removeID(id: item.id) : commentNotificationMembers.addID(id: item.id)
                        //                                                }){
                        //                                                Circle()
                        //                                                    .frame(width: 20, height: 20)
                        //                                                    .foregroundColor(
                        //                                                        (commentNotificationMembers.members.firstIndex(of: item.id) != nil) ? Color.speakerPurple : Color.speakerPurple.opacity(0.1))
                        //                                                }
                        //                                            }
                        //                                            Rectangle()
                        //                                                .frame(width: screenWidth - 60, height: 2)
                        //                                                .foregroundColor(Color.plumWeb.opacity(0.2))
                        //                                            .padding(.horizontal)
                        //                                        }
                        //
                        //                            }
                        //                                    .padding(.horizontal, 20)
                        ////                                }
                        //                            }
                        //                        }
                        //                        .padding(.vertical)
                        //                        .background(Color.mainColorInversemainColorInverse.opacity(0.6).cornerRadius(25))
                        //                        .padding(10)
                        //
                        //                    VStack  {
                        //                        Scroll View(.horizontal, showsIndicators: false) {
                        //                        HStack (spacing: 5) {
                        //                            ForEach(Array(profileCircles.profileCircles.values.sorted(by: {$1.order > $0.order})), id: \.self) { item in
                        //
                        //                                ProfileCircleSelection(friendsDictionary: friendsDictionary, color: item.color, selectedProfileCircle: $selectedProfileCircle)
                        //
                        //                            }
                        //
                        //                            Spacer()
                        //                        }
                        //                        }
                        //                    }
                        //                    .padding(.leading)
                    }
                }
                //                .padding(.bottom, 180)
//                Spacer()
//                Text("Logout").foregroundColor(.blue)
//                    .onTapGesture {
//                        signOut = true
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            login.signOut()
//                        }
//                    }
//                    .padding(.bottom, iOS15 ? 10 : 100)
//
                Spacer()
            }
            //        }
            //            .introspectScrollView{ scrollView in
            //            print("introspectScrollView ")
            //          if hasSetKeyboardDismissMode == false{
            //#if os(iOS)
            //              scrollView.keyboardDismissMode = .interactive
            //#endif
            //              hasSetKeyboardDismissMode = true
            //          }
            //      }
            .padding(.top, iOS15 ? 10 : 60)
            
#if os(macOS)
            .frame(width: screenWidth, height: screenHeight-60)
            .padding(.top,25)
#endif
            
            
#if os(iOS)
            if let _ = shareActivity.shareURL {
                ActivityViewController(shareURL: $shareActivity.shareURL )
            }
                
#endif
                Menu {
                    Button("Delete Account") {
                        withAnimation {
                            isAlertShowing = true
                        }
                    }
                    Button("Logout") {
                        isShowingLogoutAlert.toggle()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .foregroundColor(Color.black.opacity(0.08))
                            .frame(width: 40, height: 40)
                            .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
                        Image(systemName: "xmark")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.black)
                            .padding(5)
                    }
                }
                .padding(.bottom, screenHeight/30)
                .padding(.bottom, iOS15 ? 0 : 35)
        }
            .sheet(isPresented: $isShowingThemesLight) {
                if #available(iOS 16.0, *) {
                    SelectTheme(themeController: themeController, light: true, isShowingThemesLight: $isShowingThemesLight, isShowingThemesDark: $isShowingThemesDark)
                        .presentationDetents([.fraction(0.75)])
                } else {
                    SelectTheme(themeController: themeController, light: true, isShowingThemesLight: $isShowingThemesLight, isShowingThemesDark: $isShowingThemesDark)
                }
                  }
            .sheet(isPresented: $isShowingThemesDark) {
                if #available(iOS 16.0, *) {
                    SelectTheme(themeController: themeController, light: false, isShowingThemesLight: $isShowingThemesLight, isShowingThemesDark: $isShowingThemesDark)
                        .presentationDetents([.fraction(0.75)])
                } else {
                    SelectTheme(themeController: themeController, light: false, isShowingThemesLight: $isShowingThemesLight, isShowingThemesDark: $isShowingThemesDark)
                }
                  }
            .blur(radius: isAlertShowing ? 10 : 0)
            .disabled(isAlertShowing ? true : false)
                if isAlertShowing {
                    DeleteAccountAlert(isAlertShowing: $isAlertShowing, isShowingLogoutAlert: $isShowingLogoutAlert, signOut: $signOut, login: login, themeController: themeController)
                }
    }
        .alert(isPresented: $isShowingLogoutAlert) {
            Alert(
                title: Text("Are you sure you want to logout?"),
                primaryButton: .destructive(Text("Yes")) {
                    signOut = true
                     DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                         login.signOut()
                     }
                },
                secondaryButton: .cancel()
            )
        }
        .padding(.top, -60)
//        .frame(width: screenWidth, height: screenHeight-66, alignment: .top)
        
    }
    var anonymousModeView: some View {
        VStack {
            Toggle("Anonymous Mode", isOn: $preferences.anonymousMode)
                .foregroundColor(.black)
                .onChange(of: preferences.anonymousMode) { value in
                    
                    ProfilePreferencesOO.updateAnonymousMode(anonymousMode: preferences.anonymousMode) {error in
                    }
                }
                .font(.headline)
                .padding(.horizontal)
            ZStack (alignment: .leading) {
                themeController.theme.primary.opacity(0.4)
                VStack (alignment: .leading) {
                    
                    HStack {
                        Image(systemName: "questionmark")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 25, height: 25)
                            .scaledToFill()
                            .background(themeController.theme.primary.opacity(0.4))
                            .clipShape(Circle())
                        Text ("Anonymous")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.black)
                    }
                    
                    .padding(.leading, 5)
                    
                    Text("Non-friends will see your comments as Anonymous")
                        .font(.body)
                        .fontWeight(.light)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(4)
                        .foregroundColor(Color.black)
                        .padding(.leading, 10)
                        .multilineTextAlignment(.leading)
                        .offset(x: -3, y: -5)
                        .padding(.trailing, 5)
                        .padding(.bottom, 8)
                    
                }
                .offset(x: 5, y: 2)
                .padding(.horizontal, 5)
                //            .offset(x: -10, y: -30)
            }
            .clipShape(ChatBubbleShape(direction: .left))
            .padding(.horizontal, 10)
            .frame(height: 95)
        }
        .padding(.vertical)
        .background(themeController.theme.secondary.cornerRadius(25))
        .padding(10)
    }
    func updateUsernameIfAvailable(){
        
        
        guard newUsername.lowercased().isAlphanumeric else {
            doesContainSpecialCharacter = true
            return
        }
        
        if doesContainSpecialCharacter {
            doesContainSpecialCharacter = false
        }
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        let updatedProfile =  UserProfile(name: name, username: newUsername, bio: bio, uid: userId, photo: newMedia?.image, token: notificationToken)
        if  username == "@\(newUsername)" {
            functions.updateProfile(updatedProfile: updatedProfile)
            EditProfileMatchedGeometry = ""
        }else{
            functions.checkUsername(newUsername) { isUsernameAvailable , error in
                if isUsernameAvailable  {
                    functions.updateProfile(updatedProfile: updatedProfile)
                    EditProfileMatchedGeometry = ""
                    
                }else{
                    isUsernameTaken = true
                }
                
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }
    }
    
  
    
    func tryUsername(username: String) {
        
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        
        let docRef  = Firestore.firestore().collection("UserInfo")
        docRef.whereField("username", isEqualTo: "@\(username.lowercased())").getDocuments { (snap, err) in
            if err != nil {
                print((err?.localizedDescription) ?? "error in editProfile")
                return
            }
            
            guard let snap = snap else { return  }
            
            for i in snap.documents {
                if Auth.auth().currentUser?.uid == i.documentID {
                    let updateProfile = UserProfile(name: name, username: username, bio: bio, uid: userId, photo: newMedia?.image, token: notificationToken)
                    functions.updateProfile(updatedProfile: updateProfile)
                    EditProfileMatchedGeometry = ""
                    print("notificationToken = \(notificationToken)")

                } else {
                    print("username is already taken")
                    isUsernameTaken = true
                }
            }
            if snap.isEmpty {
                print("username is good to go")
                let updateProfile = UserProfile(name: name, username: username, bio: bio, uid: userId, photo: newMedia?.image, token: notificationToken)
                functions.updateProfile(updatedProfile: updateProfile)
                EditProfileMatchedGeometry = ""

            }
        }
    }
    func updateProfileCircle(color: String) {

        circleFunctions.updateProfileCircle(color: color)
    }
     
}

struct EditProfileTabView: View {
    @Binding var EditProfileMatchedGeometry: String
    @State var emptyStringBinding = ""
    @State var selectedTab = "editProfile"
    @Binding var signOut: Bool
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @Binding var isShowingChangedProfilePictureMessage: Bool
    @State var selectedProfileCircle = ""
    @ObservedObject var themeController: ThemeController
    var body: some View {
        if selectedTab == "editProfile" {
            ZStack {
                
                let currentUser = friendsDictionary.friendsDictionary[(Auth.auth().currentUser?.uid ?? "")]
                let editProfile = EditProfile(EditProfileMatchedGeometry: $EditProfileMatchedGeometry,
                                              name: currentUser?.name ?? "",
                                              username: currentUser?.username ?? "",
                                              bio: currentUser?.bio ?? "",
                                              school: currentUser?.school ?? "",
                                              photoLink: currentUser?.profilePicLink,
                                              signOut: $signOut,
                                              isShowingChangedProfilePictureMessage: $isShowingChangedProfilePictureMessage, themeController: themeController)
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home") 
                    editProfile
                        .tag("editProfile")
                        .padding(.top, 60)
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                editProfile
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else if let userId = Auth.auth().currentUser?.uid {
             EmptyView()
//            CurrentUserProfileTabView(ProfileMatchedGeometry: $emptyStringBinding, id: userId, postData: FriendsPostsOO(id: userId), signOut: $signOut)
                .onAppear() {
                    EditProfileMatchedGeometry = ""
                }
        }
    }
}
struct SelectTheme: View {
    @ObservedObject var themeController: ThemeController
    @State var light: Bool
    @Binding var isShowingThemesLight: Bool
    @Binding var isShowingThemesDark: Bool
    var body: some View {
        VStack {
            Text(light ? "LIGHT MODE" : "DARK MODE")
                .font(.subheadline.weight(.medium))
            Divider()

            ScrollView() {
                LazyVStack {
                    if light {
                        IndividualTheme(theme: themeController.lightTheme, themeController: themeController, light: light, isShowingThemesLight: $isShowingThemesLight, isShowingThemesDark: $isShowingThemesDark)
                        Rectangle()
                            .frame(width: screenWidth, height: 2)
                            .padding(.vertical)
                        ForEach(Array(themeController.allThemes.values.sorted(by: {$1.name > $0.name})), id: \.self) { item in
                            if item != themeController.lightTheme {
                                IndividualTheme(theme: item, themeController: themeController, light: light, isShowingThemesLight: $isShowingThemesLight, isShowingThemesDark: $isShowingThemesDark)
                                Rectangle()
                                    .frame(width: screenWidth, height: 2)
                                    .padding(.vertical)
                            }
                        }
                    } else {
                        IndividualTheme(theme: themeController.darkTheme, themeController: themeController, light: light, isShowingThemesLight: $isShowingThemesLight, isShowingThemesDark: $isShowingThemesDark)
                        Rectangle()
                            .frame(width: screenWidth, height: 2)
                            .padding(.vertical)
                        ForEach(Array(themeController.allThemes.values.sorted(by: {$1.name > $0.name})), id: \.self) { item in
                            if item != themeController.darkTheme {
                                IndividualTheme(theme: item, themeController: themeController, light: light, isShowingThemesLight: $isShowingThemesLight, isShowingThemesDark: $isShowingThemesDark)
                                Rectangle()
                                    .frame(width: screenWidth, height: 2)
                                    .padding(.vertical)
                            }
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
        .padding(.top, 10)
    }
}

struct IndividualTheme: View {
    var theme: ThemeModel
    @ObservedObject var themeController: ThemeController
    @State var light: Bool
    @Binding var isShowingThemesLight: Bool
    @Binding var isShowingThemesDark: Bool
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(theme.name.dropFirst(3))
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    withAnimation() {
                        themeController.changeTheme(theme: theme.theme, light: light)
                        if light {
                            isShowingThemesLight.toggle()
                        } else {
                            isShowingThemesDark.toggle()
                        }
                    }
                }) {
                    Circle()
                        .frame(width: 25, height: 25)
                        .foregroundColor(
                            light ? themeController.lightTheme == theme ? theme.accent : theme.secondary.opacity(0.5)
                            :
                                themeController.darkTheme == theme ? theme.accent : theme.secondary.opacity(0.5)

                        )
                }
            }
            .padding(.horizontal, 2)
            .padding(.bottom, 16)
            HStack {
                VStack {
                    Rectangle()
                        .frame(width: screenWidth/3.37, height: 151)
                        .foregroundColor(theme.primary)
                    Text("Primary")
                        .font(.subheadline.weight(.semibold))
                        .offset(y: 7)
                }
                VStack {
                    Rectangle()
                        .frame(width: screenWidth/3.37, height: 151)
                        .foregroundColor(theme.secondary)
                    Text("Secondary")
                        .font(.subheadline.weight(.semibold))
                        .offset(y: 7)
                }
                VStack {
                    Rectangle()
                        .frame(width: screenWidth/3.37, height: 151)
                        .foregroundColor(theme.accent)
                    Text("Accent")
                        .font(.subheadline.weight(.semibold))
                        .offset(y: 7)
                }
            }
        }
        .padding(.horizontal, 10)
    }
}
struct DeleteAccountAlert: View {
    @Binding var isAlertShowing: Bool
    @Binding var isShowingLogoutAlert: Bool
    @State var text = ""
    @Environment(\.colorScheme) var colorScheme
    @StateObject var function = DeleteAccountFunction()
    @State var isLoading = false
    @Binding var signOut: Bool
    @ObservedObject var login: LoginOO
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
        VStack {
            HStack {
                Text("Woah, are you sure?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color.mainColorInverse)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .offset(y: 5)
            }
            .frame(width: 330, height: 60)
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.black.opacity(colorScheme == .light ? 0.02 : 0.08))
                    .frame(width: 260, height: 60)
                    .overlay (
                TextField("Confirm by typing \"DELETE\"", text: $text)
                    .frame(width: 218)
                )
                HStack (spacing: 20) {
                    Button(action: {
                        withAnimation {
                            isAlertShowing = false
                        }
                    }) {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 100, height: 40)
                            .foregroundColor(themeController.theme.primary)
                            .overlay (
                                Text("CANCEL")
                                    .foregroundColor(Color.mainColorInverse)
                                    .font(.headline.weight(.bold))
                            )
                    }
                    Button(action: {
                        withAnimation {
                            if text == "DELETE" {
                                isLoading.toggle()
                                DeleteAccountFunction.deleteAccount {error in
                                    withAnimation {
                                        isLoading.toggle()
                                        signOut.toggle()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            login.signOut()
                                            isAlertShowing = false
                                        }
                                    }
                                }
                            } else {
                                text = ""
                            }
                        }
                    }) {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 140, height: 40)
                            .foregroundColor(themeController.theme.primary)
                            .overlay (
                                Text("YUP, DELETE IT")
                                    .foregroundColor(Color.mainColorInverse)
                            )
                    }
                }
            }
            .padding(.top, 10)
            .padding(.horizontal)
            .frame(width: 330, height: 190)
            .background(themeController.theme.accent.opacity(colorScheme == .light ? 0.6 : 0.9))
        }
        .frame(width: 330, height: 250)
        .background(themeController.theme.primary.opacity(1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.mainColorInverse, lineWidth: 2)
                .shadow(color: Color.mainColorInverse.opacity(0.25), radius: 4)
        )
            if isLoading {
                ProgressView()
            }
    }
    }
}
class DeleteAccountFunction: ObservableObject, CloudFunction {
    func deleteUserAccount() {
        DeleteAccountFunction.deleteAccount() { error in
        }
    }
    class func deleteAccount(callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        let accountInformation = [
            "userID": Auth.auth().currentUser?.uid
        ]
        Self.call(funcName: "deleteAccount-deleteAccount", informationDict: accountInformation){
            callback($0)
        }
    }
}
class MomentNotificationOO: ObservableObject, CloudFunction {
    @Published var friendsDictionary = FriendsDictionary()
    @Published var members = [String]()
    @Published var allFriends = [String: Person]()
    init() {
        friendsDictionary.getFriendsDictionary(source: .cache) {[weak self] (friendsDictionary, error) in
            self?.allFriends = self?.friendsDictionary.friendsDictionary ?? ["" : Person(id: "")]
            
            guard let userId = Auth.auth().currentUser?.uid else{ return }
            let docRef = Firestore.firestore().collection("UserInfo").document(userId.nonEmpty).collection("Settings").document("MomentNotifications")
            self?.listener =  docRef.addSnapshotListener {[weak self] (document, error) in
                if let document = document, document.exists,
                   let dataDescription = document.data() as? [String: Bool]{
                    for item in dataDescription.keys {
                        self?.members.append(item)
                    }
                }
            }
            
        }
    }
    func removeID (id: String) {
        if let firstIndex = members.firstIndex(of: id) {
            members.remove(at: firstIndex)
            MomentNotificationOO.disableMomentNotificationCloudFunction(friendID: id) {error in
            }
        }
    }
    func addID (id: String) {
        let firstIndex = members.firstIndex(of: id)
        if firstIndex == nil {
            members.append(id)
            MomentNotificationOO.enableMomentNotificationCloudFunction(friendID: id) {error in
            }
        }
    }
    class func enableMomentNotificationCloudFunction(friendID: String, callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        let userInformation = [
            "friendID": friendID,
            "uid": Auth.auth().currentUser?.uid
        ]
        Self.call(funcName: "enableMomentNotification-enableMomentNotification", informationDict: userInformation){
            callback($0)
        }
    }
    class func disableMomentNotificationCloudFunction(friendID: String, callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        let userInformation = [
            "friendID": friendID,
            "uid": Auth.auth().currentUser?.uid
        ]
        Self.call(funcName: "disableMomentNotification-disableMomentNotification", informationDict: userInformation){

            callback($0)
        }
    }
    var listener: ListenerRegistration?
    deinit {
        listener?.remove()
    }
}
class CommentNotificationOO: ObservableObject, CloudFunction {
    @Published var friendsDictionary = FriendsDictionary()
    @Published var members = [String]()
    @Published var allFriends = [String: Person]()
    init() {
        friendsDictionary.getFriendsDictionary(source: .cache) {[weak self] (friendsDictionary, error) in
            self?.allFriends = self?.friendsDictionary.friendsDictionary ?? ["" : Person(id: "")]
            
            guard let userId = Auth.auth().currentUser?.uid else{ return }
            let docRef = Firestore.firestore().collection("UserInfo").document(userId.nonEmpty).collection("Settings").document("CommentNotifications")
            self?.listener =  docRef.addSnapshotListener {[weak self] (document, error) in
                if let document = document, document.exists,
                   let dataDescription = document.data() as? [String: Bool]{
                    for item in dataDescription.keys {
                        self?.members.append(item)
                    }
                }
            }
            
        }
    }
    func removeID (id: String) {
        if let firstIndex = members.firstIndex(of: id) {
            members.remove(at: firstIndex)
            CommentNotificationOO.disableCommentNotificationCloudFunction(friendID: id) {error in
            }
        }
    }
    func addID (id: String) {
        let firstIndex = members.firstIndex(of: id)
        if firstIndex == nil {
            members.append(id)
            CommentNotificationOO.enableCommentNotificationCloudFunction(friendID: id) {error in
            }
        }
    }
    class func enableCommentNotificationCloudFunction(friendID: String, callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        let userInformation = [
            "friendID": friendID,
            "uid": Auth.auth().currentUser?.uid
        ]
        Self.call(funcName: "enableCommentNotification-enableCommentNotification", informationDict: userInformation){
            callback($0)
        }
    }
    class func disableCommentNotificationCloudFunction(friendID: String, callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        let userInformation = [
            "friendID": friendID,
            "uid": Auth.auth().currentUser?.uid
        ]
        Self.call(funcName: "disableCommentNotification-disableCommentNotification", informationDict: userInformation){
            callback($0)
        }
    }
    var listener: ListenerRegistration?
    deinit {
        listener?.remove()
    }
}
