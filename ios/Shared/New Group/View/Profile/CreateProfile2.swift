//
//  CreateProfile2.swift
//  speakEZ
//
//  Created by Ahmad naeem on 11/10/21.
//


import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestore

struct CreateProfile2: View {
    @State var isShowingImagePicker = false
    @State var newMedia: NewMedia?
    @State var name: String = ""
    @State var username: String = ""
    @State var bio: String = ""
    @State var city: String = ""
    @State var age: String = ""
    @Binding var isFirstLogin: Bool
    @State var school: String = ""
    @StateObject var functions = CreateProfileFunction()
    @StateObject var keyFunction = CreateTagFunction()
    @StateObject var editProfileFunction = EditProfileFunction()
    var allowedCharacters: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    let secretPassword = SecretPasswordFunction.savedSecretPassword
    @Environment(\.colorScheme) var colorScheme
    @State var showLoadingView = false
    @EnvironmentObject var alert : AlertOO
    @State var profileCreationError : ProfileCreationError?
    @Environment(\.hideStatusBar) var hideStatusBar
    enum ProfileCreationError : String {
        case userNameTaken = "Username is already in use"
        case containSpecialCharacter = "Username contains an invalid character"
        case userNameAvailability = "something went wrong while checking Username availability"
        case profileCreate = "something went wrong while creating profile"
    }
    
    var body: some View {
        ZStack {
            let UserImage = newMedia?.image
            //            Color.mainColorInverse.opacity(0.93)
            LinearGradient(gradient: Gradient(colors: [Color.speakerPurple, Color.speakerPink]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea(.container)
            VStack {
                HStack (spacing: 5) {
                    Spacer()
                    Text("Create Profile")
                        .fontWeight(.bold)
                        .font(.title2)
                        .padding(.leading, 45)
 
                    Spacer()
                    Button(action: {
//                        for item in username.lowercased() {
//                            if allowedCharacters.firstIndex(of: item) != nil {
//
//                            } else {
//                                doesContainSpecialCharacter = true
//                            }
//                        }
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                            if doesContainSpecialCharacter == false {
//                                tryUsername(username: username)
//                            }
//                        }
                         
                            updateNameIfAvailabel()
#if os(iOS)
                        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                                        impactLight.impactOccurred()
#endif
                         
                    }){
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(Color.speakerPink)
                           
                    }
                    .opacity(username != "" && UserImage != nil ? 1 : 0)
                    .disabled(username != "" && UserImage != nil ? false : true)

                }
                .padding(.horizontal)
                Divider()
                    .offset(y: -5)
                VStack {
//
                    ZStack {
                        Text("select photo")
                                             .opacity(0.5)
                                             .foregroundColor(.speakerPink)
                                             .font(.caption2)
                                             .offset(y: -114)
                            .opacity(UserImage == nil ? 1 : 0)
                        if let UserImage = UserImage  {
                            Image(uiImage: UserImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: screenWidth/2, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .background(RoundedRectangle(cornerRadius: 10)
                                                .strokeBorder(Color.speakerPink, lineWidth: 1))
                                .onTapGesture(perform: showImagePicker)
                        }else{
                            Image("SPEAKMANSQUARES")
                                .resizable()
                                .offset(x: -5)
                                .frame(width: screenWidth/2, height: 200)
                                .background(RoundedRectangle(cornerRadius: 10)
                                                .strokeBorder(Color.speakerPink, lineWidth: 1))
                                .onTapGesture(perform: showImagePicker)
                        }
                        
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .background(Circle().foregroundColor(.speakerPink))
                            .frame(width: 30, height: 30)
                            .padding(.leading, screenWidth/2 - 10)
                            .padding(.top, screenWidth/2 - 10)
                            .onTapGesture(perform: showImagePicker)

                        Text("*")
                            .foregroundColor(.speakerPurple)
                            .font(.headline)
                            .offset(x: 110, y: -90)

                        
                    }.presentMediaPicker(isPresented: $isShowingImagePicker, newMedia: $newMedia,parentView: .userProfile)
//                    }
                   
                    HStack (alignment: .top, spacing: 0) {
                        VStack (alignment: .leading, spacing: 11) {
                            
                            Text("Username:")
                                .font(.headline)
                                .padding(.bottom, 7)
                            Text("Name:")
                                .font(.headline)
                                .padding(.bottom, 7)
                            Text("Bio:")
                                .font(.headline)
                                .padding(.bottom, 7)
//
                            Text("City:")
                                .font(.headline)
                                .padding(.bottom, 7)
                            
                            Text("Age:")
                                .font(.headline)
                                .padding(.bottom, 7)

                            
                        }
                        .opacity(0.7)
                        .padding(.trailing, 4)
                        VStack {
                            ZStack {
                            TextField(username == "" ? "tristan" : username, text: self.$username)
                                Text("*")
                                    .foregroundColor(.speakerPurple)
                                    .font(.headline)
                                    .offset(x: -screenWidth/4, y: 3)
                                    .opacity(username.count < 2 ? 1 : 0)
                            }
                            Divider()
                            ZStack {
                            TextField(name == "" ? "Tristan" : name, text: self.$name)
//                                Text("*")
//                                    .foregroundColor(.red)
//                                    .font(.headline)
//                                    .offset(x: -phoneWidth/4 + 11, y: 5)
//                                    .opacity(name == "" ? 1 : 0)
                            }
                            Divider()
                            ZStack {
                            TextField(bio == "" ? "Just here for a good time" : bio, text: self.$bio)
//                                Text("*")
//                                    .foregroundColor(.red)
//                                    .font(.headline)
//                                    .offset(x: -phoneWidth/4 + 11, y: 5)
//                                    .opacity(bio == "" ? 1 : 0)
                            }
                            Divider()
                            ZStack {
                            TextField(city == "" ? "Toronto" : city, text: self.$city)
                            }
                            Divider()
        
                            ZStack {
                                TextField(age == "" ? "24" : age, text: self.$age)
#if os(iOS)
                                    .keyboardType(.numberPad)
#endif

                            }
                            Divider()

                        }
                        .padding(.horizontal)
                        
                    } // HSTACK
                    .padding(.horizontal)
                    //                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    if let profileCreationError = profileCreationError {
                        Text(profileCreationError())
                            .foregroundColor(.red)
                            .font(.caption)
                            .offset(x: 0, y: -210)
                        
                    }
//                    if errors == .userNameTaken {
//                        Text("Username is already in use")
//                            .foregroundColor(.red)
//                            .font(.caption)
//                            .offset(x: 0, y: -200)
//                    }
                    
//                    if doesContainSpecialCharacter == true {
//                        Text("Username contains an invalid character")
//                            .foregroundColor(.red)
//                            .font(.caption)
//                            .offset(x: 0, y: -200)
//                    }
                    
                    
                }
                Spacer()
                
                
                
            }

            .padding(.top, 10)
            .background(LinearGradient(gradient: Gradient(colors: [Color.mainColorInverse.opacity(0.9), Color.mainColorInverse.opacity(0.9)]), startPoint: .top, endPoint: .bottom))
            
            .frame(width: screenWidth/1.2, height: screenHeight/1.13)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
            .shadow(radius: 10, x: 0, y: 0)
            if showLoadingView {
                Color.black.opacity(0.00001)
                ProgressView(value: 0.4)
                    .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .light ? .black : .white ))
                    .accentColor(.green)
                    .scaleEffect(3.0)
                    .accentColor(.green)
            }
        }
        .animation(.spring())
        .ignoresSafeArea(.keyboard)
    }
    func showImagePicker(){
//        hideStatusBar.wrappedValue = true
        isShowingImagePicker = true
    }
    func updateNameIfAvailabel() {
        guard showLoadingView == false else {
            //so user can not just call the updateNameIfAvailabel func over and over again
            return
        }
        guard username.lowercased().isAlphanumeric , let userId = Auth.auth().currentUser?.uid else {
            profileCreationError = .containSpecialCharacter
            return
        }
        
        if profileCreationError == .containSpecialCharacter {
            profileCreationError = nil
        }
       
        showLoadingView = true
        editProfileFunction.checkUsername(username) { isUsernameAvailable , error in
            
            if let error = error {
                showLoadingView = false
                profileCreationError = .userNameAvailability
                print(error.localizedDescription)
            }else if isUsernameAvailable {
                profileCreationError = nil
               
                let UserImage = newMedia?.image
                functions.createProfile(name: name == "" ? username : name,
                                        username: username,
                                        bio: bio,
                                        uid: userId,
                                        photo: UserImage,
                                        token: notificationToken,
                                        school: school,
                                        city: city,
                                        age: age,
                                        appPassword: secretPassword ?? "strawberry"){ error in
                    showLoadingView = false
                    if error == nil{
                        profileCreationError = nil
                        isFirstLogin = false
                    }else{
                        profileCreationError = .profileCreate
                    }
                }
                //                isFirstLogin = false
                keyFunction.createTag(name: "💜", description: "my mental health key- these are my friends that will be there for me", friendIDs: [userId])
            }else{
                showLoadingView = false
                profileCreationError = .userNameTaken
            }
            
            
        }
    }
}
