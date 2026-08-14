//
//  CurrentUserProfile.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/15/21.
//

import SwiftUI

struct EditProfileContextMenu: View{
    @Binding var isInfoPopUpShowing: Bool
    @Binding var EditProfileMatchedGeometry: String
    @Binding var isShowingContextMenu: Bool
    @Binding var isSavedPostsShowing: Bool
    @Binding var showQRScanner : Bool
    @ObservedObject var shareActivity: ShareActivityOO
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {

            HStack {
                ZStack {
                VStack (alignment: .leading) {
                  
                        Button(action: {
                            withAnimation {
                            EditProfileMatchedGeometry = "0"
                            isShowingContextMenu = false
                            }
                        }){
                            HStack {
                        Text("Edit Profile")
                                       .font(.body)
                                    .fontWeight(.medium)
                                    .offset(y: -1)
                                    .foregroundColor(Color.mainColor)
                                    .padding(.horizontal)
                        }
                            .contentShape(Rectangle())
                    }.buttonStyle(.borderless)

                    Divider()
                        Button(action: {
                            withAnimation {
                                isSavedPostsShowing = true
                                isShowingContextMenu = false

                            }
                        }){
                            HStack {
                        Text("Saved Moments")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .offset(y: 4)
                                    .foregroundColor(Color.mainColor)
                                    .padding(.horizontal)
                                Spacer()
                        }
                            .contentShape(Rectangle())
                    }.buttonStyle(.borderless)
                }
                }
            }
            .frame(width: screenWidth/1.5, height: 100)
            .background(Color.mainColorInverse
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))))
            .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 0)
        }
    }
}
