//
//  Login.swift
//  speakEZ crossplatform (iOS)
//
//  Created by Carson O'Sullivan on 2/16/21.
//

import SwiftUI
import Firebase
import CryptoKit
import FirebaseAuth
import AuthenticationServices


struct LoginController2: View {

    @State var isSuccessful: Bool
    @State var loggedOut: Bool = false
    @State var isDisabled = false
    @StateObject var login = LoginOO()
    var body: some View {
        if isSuccessful == false && loggedOut == false {
            OnboardingHome(isSuccessful: $isSuccessful)
        } else {
            LoadingController(signOut: $loggedOut)
        }
        
    }
}

struct AppController: View {
    @StateObject var login = LoginOO()
    @StateObject var friendsDictionary = FriendsDictionary()
    @State var signedOut = false
    var body: some View {
        if Auth.auth().currentUser != nil && signedOut == false {
            LoadingController(signOut: $signedOut)
                .environmentObject(friendsDictionary)
        } else {
#if targetEnvironment(simulator) && DEBUG
LoginController(isSuccessful: false)
#else
LoginController2(isSuccessful: false)
#endif
        }
    }
}

struct StatusBarStatus: EnvironmentKey {
    static var defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var hideStatusBar: Binding<Bool> {
        get { self[StatusBarStatus.self] }
        set { self[StatusBarStatus.self] = newValue }
    }
}

struct AppControllerWithPassword: View {
    @State var hideStatusBar = false
    @StateObject var sharedPerson = DynamicViewsNavigationOO()
    @StateObject var alert = AlertOO()
    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack{
            if Auth.auth().currentUser != nil {
                AppController()
                    .environment(\.hideStatusBar, $hideStatusBar)
            } else {
//                PasswordLoginController()
                AppController()
                    .environment(\.hideStatusBar, $hideStatusBar)
            }
            if alert.showAlert{
                AlertView(errorString:  $alert.alertDetail)
            }
        }
#if os(iOS)
        .statusBar(hidden: hideStatusBar)
#endif
        .onOpenURL{url in
//            if Auth.auth().canHandle(url) == false{
            sharedPerson.parseToDeepLink(url: url)
//            }
        }
        .environmentObject(sharedPerson)
        .environmentObject(alert)
        
    }
}

struct LoadingController: View {
    @State var isLoading = true
    @StateObject var friendsDictionary = FriendsDictionary()
    @StateObject var login = LoginOO()
    @StateObject var firstLogin = FirstLoginOO()
    @StateObject var timelinePosts = TimelinePostsOO()
    @Binding var signOut: Bool
    @State var emptyArrayStringBinding = [String]()
    @StateObject var currentTab = CurrentTab()
    var body: some View {
        ZStack {
            HomeController(signOut: $signOut,
                           allChats: AllMessagesOO(friendsDictionary: timelinePosts.friendsDictionary),
                           intro: IntroVideoOO(profileHasCreatedPublisher: firstLogin.$profileHasBeenCreated))
                .environmentObject(friendsDictionary)
                .environmentObject(firstLogin)
                .environmentObject(timelinePosts)
                .environmentObject(currentTab)
//                .opacity(isLoading ? 0.0001 : 1)
        if isLoading {
            LoadingScreen()
//                .environmentObject(friendsDictionary)
                .onAppear() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
//                        withAnimation(.easeOut(duration: 0.3)){
                            isLoading = false
//                        }
                    }
                }
        }
        }
    }
}


struct PasswordLogin: View {
    @State var isInformationBubbleShowing = false
    @StateObject var keyboard = KeyboardOO()
    @StateObject var secretPasswordVM = SecretPasswordFunction()
    @State var text = ""
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.speakerPurple, Color.speakerPink]), startPoint: .top, endPoint: .bottom)
            VStack {
            VStack {
                Image("SPEAKMANSQUARES")
                    .resizable()
                    .frame(width: screenWidth + 100, height: screenHeight/2)
                    .offset(x: -10, y: -40)
                Image("150")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .offset(y: -90)
                    .overlay(
                    ZStack{
                        if secretPasswordVM.showLoadingCircle{
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(2)
                        }
                    }
                )
                Spacer()
            }
            .hidden()
                VStack (spacing: -20) {
                Text("speakEZ")
                    .font(.system(size: 100))
                    .bold()
                    Rectangle()
                        .frame(width: 380, height: 8)
                }
            .padding(.top, 100)
                VStack {
                    if isInformationBubbleShowing == true {
//                        Link(destination: URL(string: "https://www.youtube.com/watch?v=nGr7l1NQGSc")!, label: {
                       
                            LoginInformationBubble(text: "Message Carson for the password.")
//                        })
                    }
                HStack {
                        HStack {
                                TextField("Secret Password", text: $text)
                                    .padding(.leading)
                                    .frame(width: 200, height: 50)
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    secretPasswordVM.checkSecretPassword(text)
                                }){
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(Color.black.opacity(0.5))
                                        // Rotating paperplane
                                        .rotationEffect(.init(degrees: 45))
                                        // Padding Shape
                                        .padding(.vertical, 12)
                                        .padding(.leading, 12)
                                        .padding(.trailing, 17)

                                } // BUTTON
                        }
                        .background(Color.black.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                        .animation(.spring())
                       
                    
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.white.opacity(0.6))
                        .onTapGesture {
                            isInformationBubbleShowing.toggle()
                            
                        }
                        .padding(.horizontal, 4)
                       
                }
                }
                .offset(y: keyboard.value == 0 ? 0 : -keyboard.value + 100)
                .padding(.leading, 40)
                .padding(.bottom, 150)
            }
        }
        .ignoresSafeArea(.all)
    }
}
//
//struct SecretPasswordCheck: View {
//    @StateObject var passwordCheck = SecretPasswordFunction()
//    var body: some View {
//        ZStack {
//
//        }
//    }
//}

struct PasswordLoginController: View {
    
    @AppStorage(SecretPasswordFunction.Key.secretPassword()) var secretPassword: String = ""
    var body: some View {
        if secretPassword.isEmpty {
            PasswordLogin()
        } else {
            AppController()
        }
    }
}

struct LoadingScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.backgroundColor,  Color.accent]), startPoint: .top, endPoint: .bottom)
            VStack {
                Spacer()
                Image("speakEZname")
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth - 25, height: 50)
                    .offset(x: 0, y: screenHeight/12)
                Spacer()
                Image("martiniGlass")
                    .resizable()
                    .frame(width: screenWidth, height: screenHeight/2)
                    .offset(x: 0, y: screenHeight/15)
                    .opacity(0.8)
                   
            }
       
            }
        .ignoresSafeArea(.all)
//        ZStack {
//            Image("loadingScreen")
//                .resizable()
//                .frame(width: screenWidth, height: screenHeight)
////            LinearGradient(gradient: Gradient(colors: [Color.speakerPurple,  Color.speakerPink]), startPoint: .top, endPoint: .bottom)
////            VStack {
////                Image("speakez")
////                    .resizable()
////                    .frame(width: screenWidth, height: 200)
////                    .offset(x: 10, y: screenHeight/3)
////                Spacer()
////                Image("SPEAKMAN")
////                    .resizable()
////                    .frame(width: screenWidth + 100, height: screenHeight/2)
////                    .offset(x: 15, y: screenHeight/15)
////                    .opacity(0.8)
////
//////                Spacer()
////            }
//
//            }
//        .ignoresSafeArea(.all)
    }
}

struct LoginInformationBubble: View {
    @State var text = ""
    var body: some View {
        VStack {
            Text(text)
                .frame(width: screenWidth - 100)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .font(.caption)
                .padding(.horizontal)
        }
        
        .clipShape(ChatBubbleShape(direction: .right))
        
    }
}


struct Login2: View {
    @State var isInformationBubbleShowing = false
    @Binding var isSuccessful: Bool
    @State var currentNonce: String?
    var body: some View {
        ZStack (alignment: .bottom) {
            LinearGradient(gradient: Gradient(colors: [Color.speakerPurple, Color.speakerPink]), startPoint: .top, endPoint: .bottom)
                        Image("coolBackground")
                            .resizable()
                            .frame(width: screenWidth * 2, height: screenHeight)
                            .blur(radius: 20)
                            .opacity(0.4)
           LoadingScreen()
                .opacity(0.6)

                    VStack {
                        if isInformationBubbleShowing == true {
                            LoginInformationBubble(text: "speakEZ accounts are created with Apple ID")
                        }
                        HStack {
                            SignInWithAppleButton(
                                          
                                          //Request
                                          onRequest: { request in
                                              let nonce = randomNonceString()
                                              currentNonce = nonce
                                              request.requestedScopes = [.fullName, .email]
                                              request.nonce = sha256(nonce)
                                          },
                                          
                                          //Completion
                                          onCompletion: { result in
                                              switch result {
                                                  case .success(let authResults):
                                                      switch authResults.credential {
                                                          case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                                          
                                                                  guard let nonce = currentNonce else {
                                                                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                                                  }
                                                                  guard let appleIDToken = appleIDCredential.identityToken else {
                                                                      fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                                                  }
                                                                  guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                                                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                                                                    return
                                                                  }
                                                                 
                                                                  let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
                                                                  Auth.auth().signIn(with: credential) { (authResult, error) in
                                                                      if (error != nil) {
                                                                          // Error. If error.code == .MissingOrInvalidNonce, make sure
                                                                          // you're sending the SHA256-hashed nonce as a hex string with
                                                                          // your request to Apple.
                                                                          print(error?.localizedDescription as Any)
                                                                          return
                                                                      }
                                                                      print("signed in")

                                                                    isSuccessful = true
              
                                                                  }
                                                          
                                                              print("\(String(describing: Auth.auth().currentUser?.uid))")
                                                      default:
                                                          break
                                                                  
                                                              }
                                                     default:
                                                          break
                                                  }
                                              
                                          }
                                      ).frame(width: 280, height: 45, alignment: .center)
                            .padding(.leading, screenWidth/9)
                            
                            Image(systemName: "info.circle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color.white.opacity(0.8))
                                .onTapGesture {
                                    withAnimation {
                                    isInformationBubbleShowing.toggle()
                                    }
                                    
                                }
                                .padding(.horizontal, 4)
                        } .animation(.spring())
                    }
                    .padding(.bottom, 200)
                
//
//                Spacer()
//            }
//            .padding(.top, 100)
            
        }
        .ignoresSafeArea(.all)
    }
    //Hashing function using CryptoKit
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
}

struct OnboardingHome: View {
    @State var selection = 1
    @State var isInformationBubbleShowing = false
    @Binding var isSuccessful: Bool
    @State var currentNonce: String?
    var body: some View {
        VStack {
                TabView(selection: $selection) {
                    OnboardingScreen1()
                        .tag(1)
                    OnboardingScreen2()
                        .tag(2)
                    OnboardingScreen3()
                        .tag(3)
                    OnboardingScreen4()
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .ignoresSafeArea(.all)
            VStack {
                if isInformationBubbleShowing == true {
                    LoginInformationBubble(text: "speakEZ accounts are created with Apple ID")
                }
                HStack {
                    SignInWithAppleButton(
                                  
                                  //Request
                                  onRequest: { request in
                                      let nonce = randomNonceString()
                                      currentNonce = nonce
                                      request.requestedScopes = [.fullName, .email]
                                      request.nonce = sha256(nonce)
                                  },
                                  
                                  //Completion
                                  onCompletion: { result in
                                      switch result {
                                          case .success(let authResults):
                                              switch authResults.credential {
                                                  case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                                  
                                                          guard let nonce = currentNonce else {
                                                            fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                                          }
                                                          guard let appleIDToken = appleIDCredential.identityToken else {
                                                              fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                                          }
                                                          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                                            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                                                            return
                                                          }
                                                         
                                                          let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
                                                          Auth.auth().signIn(with: credential) { (authResult, error) in
                                                              if (error != nil) {
                                                                  // Error. If error.code == .MissingOrInvalidNonce, make sure
                                                                  // you're sending the SHA256-hashed nonce as a hex string with
                                                                  // your request to Apple.
                                                                  print(error?.localizedDescription as Any)
                                                                  return
                                                              }
                                                              print("signed in")

                                                            isSuccessful = true
      
                                                          }
                                                  
                                                      print("\(String(describing: Auth.auth().currentUser?.uid))")
                                              default:
                                                  break
                                                          
                                                      }
                                             default:
                                                  break
                                          }
                                      
                                  }
                              ).frame(width: 280, height: 45, alignment: .center)
                        .signInWithAppleButtonStyle(.white)
                    .padding(.leading, screenWidth/9)
                    
                    Image(systemName: "info.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.white.opacity(0.8))
                        .onTapGesture {
                            withAnimation {
                            isInformationBubbleShowing.toggle()
                            }
                            
                        }
                        .padding(.horizontal, 4)
                } .animation(.spring())
            }
                    .padding(.bottom, 50)
        }
        .background(Color.black.ignoresSafeArea())
    }
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
}

struct OnboardingScreen1: View {
    var body: some View {
            ZStack {
                Image("introBackgroundImage1")
                    .resizable()
                    .scaledToFill()
                    .overlay(
                        LinearGradient(colors: [.black.opacity(0.5), .black.opacity(0.35), .black], startPoint: .top, endPoint: .bottom)
                    )
                    .offset(y: -30)
                VStack (spacing: -10) {
                    Text("Welcome to your personal")
                        .foregroundColor(.white)
                    Text("speakEZ")
                        .font(.system(size: 80))
                        .foregroundColor(.white)

                }
                .offset(y: -30)
        }
    }
}

struct OnboardingScreen2: View {
    var body: some View {
        ZStack {
                Image("introBackgroundImage2")
                    .resizable()
                    .scaledToFill()
                    .overlay(
                        LinearGradient(colors: [.black.opacity(0.5), .black.opacity(0.35), .black], startPoint: .top, endPoint: .bottom)
                    )
                    .offset(y: -30)
                VStack (spacing: 10) {
                    Text("150 friends")
                        .foregroundColor(.white)
                        .font(.title.weight(.semibold))
                    Text("No followers, no following, just your social circle.")
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)

                }
                .offset(y: -30)
            }

    }
}

struct OnboardingScreen3: View {
    var body: some View {
            ZStack {
                Image("introBackgroundImage3")
                    .resizable()
                    .scaledToFill()
                    .overlay(
                        LinearGradient(colors: [.black.opacity(0.5), .black.opacity(0.35), .black], startPoint: .top, endPoint: .bottom)
                    )
                    .offset(y: -30)
                VStack (spacing: 10) {
                    Text("Be connected")
                        .foregroundColor(.white)
                        .font(.title.weight(.semibold))
                    Text("Create memories with the people you care about.")
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)

                }
                .offset(y: -30)
            }

    }
}

struct OnboardingScreen4: View {
    var body: some View {
            ZStack {
                Image("introBackgroundImage4")
                    .resizable()
                    .scaledToFill()
                    .overlay(
                        LinearGradient(colors: [.black.opacity(0.5), .black.opacity(0.35), .black], startPoint: .top, endPoint: .bottom)
                    )
                    .offset(y: -30)
                VStack (spacing: 10) {
                    Text("Stay lowkey")
                        .foregroundColor(.white)
                        .font(.title.weight(.semibold))
                    Text("What happens in your speakeasy, stays in your spakeasy.")
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)

                }
                .offset(y: -30)
        }

    }
}
