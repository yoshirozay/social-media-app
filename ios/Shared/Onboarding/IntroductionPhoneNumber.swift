//
//  IntroductionPhoneNumber.swift
//  speakEZ
//
//  Created by Ahmad naeem on 6/1/22.
//

import SwiftUI
import Contacts
struct IntroductionPhoneNumber: View {
    @Binding var currentView: CurrentIntroView
    @State var phoneNumber = ""
    @State var verificationCode = ""
    @State var y : CGFloat = 150
    @State var countryCode = ""
    @State var countryFlag = ""
    @State var keyboard = KeyboardOO()
    @State var contactsCount = 10
    @Environment(\.colorScheme) var colorScheme
    @State var showProgresser : Bool = false
    @State var isSkipButtonShowing = false
    @StateObject var phoneVM = PhoneVerificationVM()
    @EnvironmentObject var alert : AlertOO
    @State var isSkipAlertShowing = false
    @ObservedObject var firstLogin: FirstLoginOO
    var body: some View {
        GeometryReader { _ in
            ZStack {
//                IntroBackground()
                LinearGradient(gradient: Gradient(colors: [.backgroundColor, .accent]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                if showProgresser {
                    ProgressViewPurpleCircular().scaleEffect(3)
                }
                
                ZStack {
                    VStack {
                        VStack {
                            Text("Two-Factor Authentication")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.leading, 3)
                                .padding(.top, 5)
                                .padding(.leading, 16)
                                .foregroundColor(Color.black)
                            ZStack (alignment: .bottomLeading) {
                                Image(colorScheme == .light ? "2FA" : "2FAdark")
                                .resizable()
                                .frame(width: screenWidth/1.2, height: screenHeight/3.087) // 300, 300
                                
                                if isSkipButtonShowing {
                                    if phoneVM.verificationID.isEmpty {
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
                                    .padding(.trailing, 10)
                                    .offset(x: -20, y: 32)
                                    } else {
                                        Button(action: {
                                            phoneVM.verificationID = ""
                                        }) {
                                            Text("Back")
                                                .font(.footnote)
                                                .foregroundColor(Color.mainColor.opacity(0.6))
                                                .padding(7)
                                                .padding(.horizontal, 5)
                                                .background(Color.mainColorInverse.opacity(0.2))
                                                .clipShape(Capsule())
                                        }
                                        .padding(.trailing, 10)
                                        .offset(x: -20, y: 32)
                                    }
                                }
                            }
                            
                            
                        }
                        .frame(width: screenWidth/1.05)
                        .background(Color.mainColorInverse.opacity(0.2))
                        
                        ZStack {
                            if phoneVM.verificationID.isEmpty {

//
                                NumberPadFirstResponder(text: $phoneVM.phoneNumber, placeHolderText: "Phone Number", isPhoneNumber: true)
                                        .padding(32)
//                                        .padding(.leading, 20)
                                        .frame(width: 200, height: 50)
                                        .keyboardType(.phonePad)

                            } else {
                                
                                NumberPadFirstResponder(text: $phoneVM.verificationCode, placeHolderText: "Enter Verification")
                                    .padding(32)
//                                    .padding(.leading, 30)
                                    .frame(width: 200, height: 50)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .padding(.leading, 50)
                                
                            }

                            RoundedRectangle(cornerRadius: 10)
                                .stroke()
                                .background(Color.mainColorInverse.opacity(0.2))
                                .foregroundColor(.black)
                                .frame(width: 280, height: 50)
                                .opacity(self.y != 150 && keyboard.value > 0 ? 0 : 1)
                            
                            ZStack {
                                if phoneVM.verificationID.isEmpty {
                                    Button(action: {
 
                                        if showProgresser == false {
                                            showProgresser = true
                                            phoneVM.sendCode { error in
                                                showProgresser = false
                                                if let description = error?.localizedDescription{
                                                    alert.alertDetail = description
                                                }
                                            }
                                        }
                                    }) {
                                        ZStack {
                                            Text("Send Code")
                                                .font(.headline)
                                        }
                                        .frame(width: 200, height: 50)
                                        .foregroundColor(Color.mainColor)
                                        .background(Color.mainColorInverse.opacity(0.6))
                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                    }
                                    
                                    .opacity(phoneVM.phoneNumber.count < 10 || self.y != 150 ? 0.00 : 1.00)
                                    .disabled(phoneVM.phoneNumber.count < 10 || self.y != 150 ? true : false)
                                    .animation(.easeIn(duration: 0.3))
                                } else {
                                    Button(action: {
                                        
                                        if showProgresser == false {
                                            showProgresser = true
                                            phoneVM.signIn { error in
                                                showProgresser = false
                                                if let description = error?.localizedDescription{
                                                    alert.alertDetail = description
                                                }else{
                                                    goToNextScreen()
                                                }
                                            }
                                        }
                                        
                                    }) {
                                        ZStack {
                                            Text("Confirm")
                                                .font(.headline)
                                        }
                                        .frame(width: 200, height: 50)
                                        .foregroundColor(Color.mainColor)
                                        .background(Color.mainColorInverse.opacity(0.6))
                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                    }
                                    .animation(.easeIn(duration: 0.3))
                                }
                            }
                            .offset(y: 75)
                        }
//                        .offset(y: -150)
                        Spacer()
                        HStack {
                            Button(action: {
                                currentView = .Permission 
                                phoneVM.verificationID = ""
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

                        }
                        .padding(.bottom, 10)
                        .opacity(y != 150 ? 0 : 1)
                        .disabled(y != 150 ? true : false)
                    }
                }
                .frame(width: screenWidth/1.05, height: screenHeight / 1.1)
                .background(Color.mainColorInverse.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .animation(.easeIn(duration: 0.3))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            isSkipButtonShowing = true
                        }
                    }
                }
                .alert(isPresented: $isSkipAlertShowing) {
                    Alert(
                        title: Text("Are you sure? Your friends will not be able to find you."),
                        primaryButton: .destructive(Text("Yes")) {
                            goToNextScreen()
                            hideKeyboard()
                            //                          phoneVM.verificationID = ""
                            
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .ignoresSafeArea(.all)
//        .offset(x: screenWidth/26)
//        .offset(x: screenWidth/19)
        .onAppear {
            print("screenWidth = \(screenWidth)")
        }
    }
    
    func goToNextScreen(){
        hasDoneIntroduction()
//        if firstLogin.accountHasBeenCreated || CNContactStore.authorizationStatus(for: .contacts) == .authorized{
//            currentView = .Contacts
//        } else {
            currentView = .Home
//        }
    }
    func hasDoneIntroduction() {
        guard let userId = currentUserID else { return }
          print(" IntroSeenStatusFuncs.hasDoneIntroduction")
        IntroSeenStatusFuncs.hasDoneIntroduction(userId: userId)
    }
}
