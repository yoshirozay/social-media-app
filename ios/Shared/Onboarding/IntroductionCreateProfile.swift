//
//  IntroductionCreateProfile.swift
//  speakEZ
//
//  Created by Ahmad naeem on 6/1/22.
//

import SwiftUI
import Combine

struct IntroductionCreateProfile: View {
    @Binding var currentView: CurrentIntroView
    @Environment(\.colorScheme) var colorScheme
    @State var isShowingImagePicker = false
    @State var newMedia: NewMedia?
    @State var name: String = ""
    @State var username: String = ""
    @State var bio: String = ""
    @State var isUsernameTaken = false
    @State var school: String = ""
    @StateObject var functions = CreateProfileFunction()
    @StateObject var keyFunction = CreateTagFunction()
    @StateObject var editProfileFunction = EditProfileFunction()
    var allowedCharacters: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E","F", "G", "H", "I", "J","K", "L", "M", "N", "O","P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    let secretPassword = SecretPasswordFunction.savedSecretPassword
    @State var doesContainSpecialCharacter = false
    @State var showLoadingView = false
    @EnvironmentObject var alert : AlertOO
    @State var profileCreationError : ProfileCreationError?
    @ObservedObject var intro: IntroVideoOO
    @ObservedObject var firstLogin: FirstLoginOO
    
    enum ProfileCreationError : String {
        case userNameTaken = "Username is already in use"
        case containSpecialCharacter = "Username contains an invalid character"
        case userNameAvailability = "something went wrong while checking Username availability"
        case profileCreate = "something went wrong while creating profile"
    }
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                let UserImage = newMedia?.image
//                IntroBackground()
                LinearGradient(gradient: Gradient(colors: [.backgroundColor, .accent]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                ZStack {
                    VStack {
                        HStack {
                            Image("speakEZLogo2")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: screenWidth/1.20, height: screenHeight/11)
                                .opacity(0.8)
                                .padding(.top, 15)
                        }
                        .padding(.bottom, 10)
                        .presentMediaPicker(isPresented: $isShowingImagePicker, newMedia: $newMedia,parentView: .userProfile)

                        VStack  {
//                            ZStack  {
                            Rectangle()
                                .frame(width: screenWidth/1.05, height: 2)
                                .foregroundColor(Color.mainColorInverse)
//                                .offset(y: 5)
//                                Text("Create Profile")
//                                    .opacity(0.8)
////                                    .rotationEffect(.degrees(-3))
//                                    .offset(x: 10, y: -20)
//
//                            }
                            HStack(spacing: 0){
                                
                                Text("NAME:")
                                    .font(.caption.weight(.semibold))
//                                    .foregroundColor(Color.speakerPurple)
                                    .foregroundColor(Color.black.opacity(1))
                                    .frame(width: screenWidth/3, alignment: .leading)
                                    .padding(.leading, 20)
                              
                                //
                                ZStack (alignment: .leading) {
//                                FirstResponder(text: $name, placeHolderText: "Tristan Winter")
                                    TextField("Tristan Winter", text: $name)
                                        .onReceive(Just(name), perform: { _ in
                                            withAnimation() {
                                                self.name = String(self.name.prefix(30))
                                                if self.name.count > 0 {
                                                
                                                }

                                            }
                                        })
                                    .offset(x: 5)
                                    .frame(width: screenWidth/2, height: 35)
                                    .background(Color.mainColorInverse.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                                    Text("Create Profile")
//                                        .opacity(0.8)
//                                        .foregroundColor(Color.black)
//                                        .offset(x: 20, y: -38)
                                }
                                Spacer()
                            }
                            Rectangle()
                                .frame(width: screenWidth/1.05, height: 2)
                                .foregroundColor(Color.mainColorInverse)
                            HStack(spacing: 0){
                                HStack (spacing: 0) {
                                    Text("USERNAME:")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(Color.black.opacity(1))
                                    
                                    Text("*")
                                        .foregroundColor(Color.speakerPink)
                                        .offset(y: -3)
                                    
                                }
                                .frame(width: screenWidth/3, alignment: .leading)
                                .padding(.leading, 20)
                                TextField("tristan", text: $username)
                                    .onReceive(Just(username), perform: { _ in
                                        withAnimation() {
                                            self.username = String(self.username.prefix(20).lowercased())
                                            for item in username {
                                                if allowedCharacters.firstIndex(of: item) == nil {
                                                    if let firstIndex = username.firstIndex(of: item) {
                                                    username.remove(at: firstIndex)
                                                    }
                                                }
                                            }
                                        }
                                    })
                                    .offset(x: 5)
                                    .frame(width: screenWidth/2, height: 35)
                                    .background(Color.mainColorInverse.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                Spacer()
                            }
                            
                            Rectangle()
                                .frame(width: screenWidth/1.05, height: 2)
                                .foregroundColor(Color.mainColorInverse)
                            HStack(alignment: .top, spacing: 0){
                                Text("PROFILE PICTURE:")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(Color.black.opacity(1))
                                    .frame(width: screenWidth/3, alignment: .leading)
                                    .padding(.leading, 20)
                                    .padding(.top, 10)
                                Button(action: {
                                    showImagePicker()
                                }) {
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 11)
                                            .foregroundColor(Color.mainColorInverse.opacity(0.5))
                                        
                                            .frame(width: screenWidth/2, height: (170 * (screenWidth/2/142)))
                                        ZStack {
                                            if UserImage == nil {
                                                Image("profileGirl2")
                                                    .resizable()
                                                    .opacity(0.6)
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: screenWidth/2 - 20, height: (170 * ((screenWidth/2/142)) - 20))
                                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                                        .foregroundColor(Color.accent.opacity(colorScheme == .light ? 0.3 : 0.5))
                                                    )
                                                Image(systemName: "plus.circle.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .foregroundColor(Color.black)
                                                    .background(Circle().foregroundColor(.speakerPink))
                                                    .frame(width: 30, height: 30)
                                                    .offset(x: screenWidth/4 - 15, y: screenWidth/4 + 5)
                                            } else {
                                                if let UserImage = UserImage{ Image(uiImage: UserImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: screenWidth/2 - 20, height: (170 * ((screenWidth/2/142)) - 20))
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                }
                                            }
                                        }
                                    }
                                }
                                Spacer()
                            }
                            Rectangle()
                                .frame(width: screenWidth/1.05, height: 2)
                                .foregroundColor(Color.mainColorInverse)
                            
                        }
                        .padding(.top, 10)
                        .disabled(showLoadingView)
                        if let profileCreationError = profileCreationError {
                            Text(profileCreationError())
                                .foregroundColor(.red)
                                .font(.subheadline)
                            
                        }

                        HStack {
                            Button(action: {
                                currentView = .IntroSpeakEZ
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title3)
                                    .foregroundColor(Color.mainColor.opacity(0.6))
                                    .padding(5)
                                    .background(Color.mainColorInverse.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                            .offset(x: 5)
                            Spacer()
                        if username.count > 0 {
                            Button(action: { 
                                hideKeyboard()
                                updateNameIfAvailabel()
    #if os(iOS)
                            let impactLight = UIImpactFeedbackGenerator(style: .soft)
                                            impactLight.impactOccurred()
    #endif

                            }) {
                                Text("Done")
                                    .font(.headline)
                                    .padding(10)
                                    .padding(.horizontal, 10)
                                    .foregroundColor(Color.mainColor)
                                    .background(Color.mainColorInverse.opacity(0.6))
                                    .clipShape(Capsule())
                            }.disabled(showLoadingView)
                        }
                            Spacer()
                        }
                        Spacer()
                        
                        
                    }
                    
                    
                }
                .frame(width: screenWidth/1.05, height: screenHeight / 1.1)
                .background(Color.mainColorInverse.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .animation(.easeIn(duration: 0.3))
                
            }
        }
        .ignoresSafeArea(.all)
        .overlay(
            showLoadingView.falseIsNil.map { _ in ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(3)}
           )
    }
    func showImagePicker(){
//        hideStatusBar.wrappedValue = true
        isShowingImagePicker = true
    }
    func updateNameIfAvailabel() {
//        currentView = .Two_Factor
//        return
        guard ReachabilityService.shared.isNetworkAvailable else {
            alert.alertDetail = "You are offline, You need to be online to continue"
             return
        }
        guard showLoadingView == false else {
            //so user can not just call the updateNameIfAvailabel func over and over again
            return
        }
        guard username.lowercased().isAlphanumeric , let userId = currentUserID else {
            profileCreationError = .containSpecialCharacter
            return
        }
        
        if profileCreationError == .containSpecialCharacter {
            profileCreationError = nil
        }
       
        showLoadingView = true
        let username = username
        editProfileFunction.checkUsername(username) { isUsernameAvailable , error in
            
            if let error = error {
                showLoadingView = false
                profileCreationError = .userNameAvailability
                print(error.localizedDescription)
            }else if isUsernameAvailable {
                profileCreationError = nil
               //we will check for existing user and then show error if it already exists
                let UserImage = newMedia?.image
                functions.createProfile(name: name == "" ? username : name.trimWhitespacesAndNewlines(),
                                        username: username,
                                        bio: bio,
                                        uid: userId,
                                        photo: UserImage,
                                        token: notificationToken,
                                        school: school,
                                        city: "",
                                        age: "",
                                        appPassword: secretPassword ?? "strawberry"){ error in
                    showLoadingView = false
                    if error == nil{
                        profileCreationError = nil 
                        currentView = .Permission
                    }else{
                        profileCreationError = .profileCreate
                    }
                }
                //                isFirstLogin = false
//                keyFunction.createTag(name: "💜", description: "", friendIDs: [userId])
            }else{
                showLoadingView = false
                profileCreationError = .userNameTaken
            }
            
            
        }
    }
}
