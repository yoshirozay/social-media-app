//
//  IntroductionPermissions.swift
//  speakEZ
//
//  Created by Ahmad naeem on 6/1/22.
//

import SwiftUI

struct IntroductionPermissions: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var currentView: CurrentIntroView
    @State var titleText = "Permissions"
    @State var isSkipButtonShowing = false
    @State var isSkipAlertShowing = false 
    @ObservedObject var firstLogin: FirstLoginOO
    @ObservedObject var permissonVM : PermissionVM
    var permissionAccess: Set<PermissonType> {
        permissonVM.permissionAccess
    }
    var body: some View {
        ZStack {
//            IntroBackground()
            LinearGradient(gradient: Gradient(colors: [.backgroundColor, .accent]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ZStack {
                VStack {
                ZStack {
                    
                    Image(colorScheme == .light ? "permission33" : "permission2")
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth/1.6, height: screenHeight/3.4) // 300, 300
                    
                }
                .frame(width: screenWidth/1.05, height: screenHeight/3.087) // 300
                .padding(screenWidth/10.7) // 40
                .background(Color.mainColorInverse.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                    ZStack {
                        VStack (alignment: .leading, spacing: 23) {
                            HStack {
                                
                                ZStack {
                                    Text(titleText)
                                        .font(.largeTitle)
                                    Rectangle()
                                        .frame(width: CGFloat(titleText.count * 16), height: 1)
                                        .foregroundColor(Color.speakerPurple)
                                        .offset(y: 20)
                                }
                         
                                Spacer()
                            }
                            .foregroundColor(Color.black)
                            VStack (alignment: .leading, spacing: 23) {
                                IntroductionIndividualPermissions(permissonType: .pushNotifications, description: "so you don't leave your friends on read", image: "bell", permissonVM: permissonVM)
                            Rectangle()
                                .frame(width: 30, height: 1)
                                .foregroundColor(Color.speakerPurple)
                                IntroductionIndividualPermissions(permissonType: .contacts, description: "so you can find your friends", image: "list.dash", permissonVM: permissonVM)
                            Rectangle()
                                .frame(width: CGFloat(titleText.count * 16 - 30), height: 1)
                                .foregroundColor(Color.speakerPurple)
                            } .padding(.top, -5)
                            
                            
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 5)
                        
                        
                        VStack {
                            
                            Button(action: {
                                withAnimation(.easeIn(duration: 0.3)) {
                                   goToNextScreen()
                                }
                            }) {
                                Text("Next")
                                    .font(.headline)
                                    .padding()
                                    .padding(.horizontal, 30)
//                                    .foregroundColor(Color.mainColorInverse)
//                                    .background(Color.speakerPurple.opacity(permissionAccess.count == 2 ? 1 : 0.1))
                                    .foregroundColor(Color.mainColor)
                                    .background(Color.mainColorInverse.opacity(permissionAccess.count > 0 ? 0.6 : 0.2))
                                    .clipShape(Capsule())
                                
                            }
                            .disabled(permissionAccess.count > 0 ? false : true)
                            .padding(.top, 30)
                            
                        }
                        .offset(y: screenHeight/4.5)
                    }
                    Spacer()
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
                        .padding(.leading, 10)
                        Spacer()
                        if isSkipButtonShowing {
                        Button(action: {
                            isSkipAlertShowing = true
                        }) {
                            Text("Skip")
                                .font(.footnote)
                                .foregroundColor(Color.mainColor.opacity(0.6))
                                .padding(7)
                                .padding(.horizontal, 5)
                                .background(Color.mainColorInverse.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        .padding(.trailing, 5)
                        }

                    }
                    .padding(.bottom, 10)
                }
            }
            .frame(width: screenWidth/1.05, height: screenHeight / 1.1)
            .background(Color.mainColorInverse.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .animation(.easeIn(duration: 0.3))
            .onAppear {
                permissonVM.askForPermissonOf(.pushNotifications)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeIn(duration: 0.3)) {
                        isSkipButtonShowing = true
                    }
                }
            }
            .alert(isPresented: $isSkipAlertShowing) {
                Alert(
                    title: Text("Are you sure? speakEZ won't work well without Permissions."),
                    primaryButton: .destructive(Text("Yes")) {
                        goToNextScreen()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    func goToNextScreen() {
        currentView = .Two_Factor
//        currentView = firstLogin.accountHasBeenCreated ? .Two_Factor : .CreateProfile
    }
}

struct IntroBackground: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        Image(colorScheme == .light ? "coolBackground" : "Planes")
            .resizable()
            .scaledToFill()
            .blur(radius: 15)
            .frame(width: screenWidth, height: screenHeight)
    }
}
 
