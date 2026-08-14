//
//  InfoPopUp.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/6/21.
//

import SwiftUI


struct InfoPopUp: View {
    @State var text = ""
    @State var hasReportBeenSent = false
    @Binding var isInfoPopUpShowing: Bool
    var functionType = functionsEnum.feedbackRequest
    enum functionsEnum {
        case feedbackRequest, reportUser
    }
    @State var reportedUserID = ""
    @StateObject var functions = InfoPopUpFunctions()
    var body: some View {
        ZStack {
            HStack {
                ZStack (alignment: .bottom){
                    Color.mainColorInverse

                        VStack {
                            if hasReportBeenSent != true {

                            TextEditor(text: $text)
                                .padding(.horizontal, 5)
                                .frame(width: screenWidth/1.2, height: 300)
                              .foregroundColor(Color.mainColor)
                                .background(Color.mainColor.opacity(0.03).cornerRadius(10))
                                .padding(.horizontal)
                            }
                        
                            HStack (spacing: 30) {
                            Button(action: {
                                isInfoPopUpShowing = false
                            }){
                                Text("CANCEL")
                                  .foregroundColor(Color.mainColor)
                                    .fontWeight(.bold)
                                
                            }.buttonStyle(.borderless)
                            .frame(width: screenWidth/2.5, height: 50)
                            
                            .background(
                                Color.mainColor.opacity(0.03)).cornerRadius(10)
                            Button(action: {
                                withAnimation(.easeIn(duration: 0.5)) {
                                    hasReportBeenSent = true
                                    isInfoPopUpShowing = false
                                }
#if os(iOS)
                                let impactLight = UIImpactFeedbackGenerator(style: .heavy)
                                                impactLight.impactOccurred()
#endif
                                
                                if functionType == .feedbackRequest {
                                    functions.featureRequest(message: text)
                                    
                                } else if functionType == .reportUser {
                                    functions.reportUser(message: text, reportedUserID: reportedUserID)
                                }

                            }){
                                Text("SEND")
                                  .foregroundColor(Color.mainColor)
                                    .fontWeight(.bold)
                            }.buttonStyle(.borderless)
                            .frame(width: 150, height: 50)
                            .background(
                                Color.mainColor.opacity(0.03)).cornerRadius(10)

                           
                        }
                            .padding(.top, 10)
                            .padding(.bottom, 16)
                        }

                }
                
            }
            .frame(width: screenWidth/1.1, height: 400, alignment: .center)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        }
        .shadow(color: Color.mainColor.opacity(0.5), radius: 5)
//        .padding(.bottom, phoneHeight/3)
//        .padding(.trailing, 20)
    }
}
