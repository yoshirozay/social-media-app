//
//  Test.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/5/21.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import CryptoKit
import FirebaseAuth
import AuthenticationServices

struct OSLoginController: View {
    
    @State var isSuccessful: Bool
    @State var loggedOut: Bool = false
    @State var isDisabled = false
    var body: some View {
        if isSuccessful == false {
            LoginPageView(isSuccessful: $isSuccessful)
            
        } else {
            OSHomeController()
        }
        
    }
}

struct LoginPageView: View {
    @State var index = 0
    @Binding var isSuccessful: Bool
    @State var currentNonce:String?
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.2),Color.pink.opacity(0.2), Color.white.opacity(0.1)]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            VStack (spacing: 30) {
                VStack {
                //FIXME: - ADD IMAGE "pineapple.logo"
//                    Image("pineapple.logo")
                    Image(systemName: "applelogo")
                        .resizable()
                        .frame(width: 100, height: 180)
                        .offset(y: -35)
                } // VSTACK
                HStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0.5)) {
                            
                            self.index = 0
                        }
                    }) {
                        Text("Existing")
                            .foregroundColor(self.index == 0 ? .black : .white)
                            .fontWeight(.bold)
                            .padding(.vertical, 10)
                            .frame(width: (400 - 50) / 2)
                    } .background(self.index == 0 ? Color.white : Color.clear)
                    .clipShape(Capsule())
                    Button(action: {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0.5)) {
                            
                            self.index = 1
                        }
                    }) {
                        Text("New")
                            .foregroundColor(self.index == 1 ? .black : .white)
                            .fontWeight(.bold)
                            .padding(.vertical, 10)
                            .frame(width: (400 - 50) / 2)
                    } .background(self.index == 1 ? Color.white : Color.clear)
                    .clipShape(Capsule())
                } // HSTACK
                .background(Color.black.opacity(0.1))
                .clipShape(Capsule())
                
                if self.index == 0 {
                    Login(isSuccessful: $isSuccessful)
                        .padding(.bottom, 10)
                } else {
                    SignUP()
                        .padding(.bottom)
                }
                
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
            } //VSTACK
        } // ZSTACK
        .edgesIgnoringSafeArea(.all)
        
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


struct Login : View {
    @State var mail = ""
    @State var pass = ""
    @State var alertMessage = ""
    @Binding var isSuccessful: Bool
    
    var body: some View {
        VStack {
            HStack (spacing: 15) {
                Image(systemName: "envelope")
                    .foregroundColor(.black)
                TextField("Enter Email Address", text: self.$mail)
            } // HSTACK
            .padding(.vertical, 15)
            Divider()
            HStack (spacing: 15) {
                Image(systemName: "lock")
                    .resizable()
                    .frame(width: 15, height: 18)
                    .foregroundColor(.black)
                SecureField("Enter Password", text: self.$pass)
                Button(action: {
                    
                }) {
                    Image(systemName: "eye")
                        .foregroundColor(.black)
                } // BUTTON
            } // HSTACK
            .padding(.vertical, 17)
            
        } // VSTACK
        .padding(.vertical)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 3)
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        
        Button(action: {
            Auth.auth().signIn(withEmail: mail, password: pass) { (result, error) in
                if error != nil {
                    self.alertMessage = error?.localizedDescription ?? ""
                } else {
                    self.isSuccessful = true
                }
            }
            
        }) {
            Text("LOGIN")
                .padding(.vertical)
                .frame(width: 500 - 100)
                .foregroundColor(.white)
                .font(.headline)
            
            
        } .background(
            LinearGradient(gradient: .init(colors: [Color.red.opacity(0.6), Color.pink.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(10).shadow(radius: 20)
        .offset(y: -60)
        .padding(.bottom, -60)
        
        
    }
}

struct SignUP : View {
    @State var mail = ""
    @State var pass = ""
    @State var repass = ""
    var body: some View {
        VStack {
            HStack (spacing: 15) {
                Image(systemName: "envelope")
                    .foregroundColor(.black)
                TextField("Enter Email Address", text: self.$mail)
            } // HSTACK
            .padding(.vertical, 15)
            Divider()
            HStack (spacing: 15) {
                Image(systemName: "lock")
                    .resizable()
                    .frame(width: 15, height: 18)
                    .foregroundColor(.black)
                SecureField("Enter Password", text: self.$pass)
                Button(action: {
                    
                }) {
                    Image(systemName: "eye")
                        .foregroundColor(.black)
                } // BUTTON
            } // HSTACK
            .padding(.vertical, 17)
            Divider()
            HStack (spacing: 15) {
                Image(systemName: "lock")
                    .resizable()
                    .frame(width: 15, height: 18)
                    .foregroundColor(.black)
                SecureField("Re-Enter Password", text: self.$repass)
                Button(action: {
                    
                }) {
                    Image(systemName: "eye")
                        .foregroundColor(.black)
                } // BUTTON
            } // HSTACK
            .padding(.vertical, 17)
        } // VSTACK
        .padding(.vertical)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 3)
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        
        Button(action: {
            
        }) {
            Text("SIGNUP")
                .padding(.vertical)
                .frame(width: 500 - 100)
                .foregroundColor(.white)
                .font(.headline)
            
            
        } .background(
            LinearGradient(gradient: .init(colors: [Color.red.opacity(0.6), Color.pink.opacity(0.8)]), startPoint: .leading, endPoint: .trailing)).cornerRadius(10).shadow(radius: 20)
        .offset(y: -60)
        .padding(.bottom, -60)
    }
}

struct LoginPageView_Previews: PreviewProvider {
    static var previews: some View {
        OSLoginController(isSuccessful: false)
    }
}




