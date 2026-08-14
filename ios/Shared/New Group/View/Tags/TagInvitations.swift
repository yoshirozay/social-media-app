//
//  TagInvitations.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 8/27/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Combine



struct TagInvitations: View  {
    @Binding var TagInvitationToTagHomeNavigation: String
    @State var OpenedTagInvitationMatchedGeomtry = ""
    @StateObject var tags = TagInvitationsObservable()
    @StateObject var myTags = MyTagInvitationsOO()
    @State var offset: CGFloat = 0
    @State var emptyStringArrayBinding = [""]
    @State var emptyBoolBinding = false
    @State var OpenedTagDescription = ""
    @State var OpenedTagID: String = ""
    @State var OpenedTagSentBy: String = ""
    var body: some View {
        ZStack {
            Color.mainColorInverse
                .ignoresSafeArea(.all)
            VStack {
                HStack (spacing: 16) {
                    Button(action: {
                        TagInvitationToTagHomeNavigation = ""
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .padding(.leading)
                    }
                    
                    Text("Invitations")
                        .fontWeight(.bold)
                        .font(.title)
                    Spacer()
                    HeaderButton(image: "xmark") {
                        TagInvitationToTagHomeNavigation = ""
                    }
                    .foregroundColor(.speakerPurple)
                    .padding(.horizontal, 20)
                } // HStack, Navigation Menu
              .foregroundColor(Color.mainColor)
                Spacer()
                LazyVStack {
                    ScrollView (showsIndicators: false) {
                        VStack(spacing: -14) {
                            ForEach(tags.rows.indices, id: \.self) { rowIdx in
                                
                                HStack(spacing: 6) {
                                    ForEach(Array(tags.rows[rowIdx].indices), id: \.self) { columnIdx in
                                        
                                        IndividualTag(tagName: myTags.tags[tags.rows[rowIdx][columnIdx]]?.name ?? "", color1: .speakerPurple, color2: .speakerPurple, selected: $emptyBoolBinding)
                                            .offset(x: getOffset(index: rowIdx))
                                            .onTapGesture {
                                                OpenedTagInvitationMatchedGeomtry = myTags.tags[tags.rows[rowIdx][columnIdx]]?.name ?? ""
                                                OpenedTagDescription = myTags.tags[tags.rows[rowIdx][columnIdx]]?.description ?? ""
                                                OpenedTagID = tags.rows[rowIdx][columnIdx]
                                                OpenedTagSentBy = myTags.tags[tags.rows[rowIdx][columnIdx]]?.sentBy ?? ""
                                                //
                                            }
                                    }
                                }
                                
                            }
                            
                        }
                        .padding()
                        .frame(width: screenWidth - 20)
                        .offset(x: offset)
                    }
                    
                    Spacer()
                } // VStack
                
                .padding(.top)
                Spacer()
                    .padding()
                HStack (alignment: .bottom) {
                    LinearGradient(gradient: .init(colors: [Color.speakerPurple.opacity(0.8), Color.speakerPink.opacity(0.8)]), startPoint: .bottomLeading, endPoint: .bottomTrailing)
                        .shadow(radius: 2)
                }
                .frame(width: screenWidth, height: 50)
                .padding(.bottom, screenHeight / 20.83) // 43
            }
            .padding(.top, 120)

            if OpenedTagInvitationMatchedGeomtry != "" {
                OpenedTagInvitationTabView(OpenedTagInvitationMatchedGeometry: $OpenedTagInvitationMatchedGeomtry, description: OpenedTagDescription, tagID: OpenedTagID, tagFriends: TagFriendsOO(tagID: OpenedTagID), tagSentBy: OpenedTagSentBy)
                    .padding(.top, 120)
            } 
        }
        .padding(.top, -120)
    }
    func getOffset(index: Int) -> CGFloat {
        let current = tags.rows[index].count
        // moving half of the width
        let offset = ((screenWidth - 40) / 3) / 2
        if index != 0 {
            let previous = tags.rows[index - 1].count
            if current == 1 {
                if previous == 2 {
                    return -offset
                }
            }
            if current == 1 {
                if previous == 3 {
                    return -offset
                }
            }
            if current == previous {
                return -offset
            }
        }
        return 0
    }
}

struct TagInvitationsTabView: View {
    @Binding var TagInvitationToTagHomeNavigation: String
    @State var selectedTab = "tag"
    var body: some View {
        if selectedTab == "tag" {
            ZStack {
                
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    TagInvitations(TagInvitationToTagHomeNavigation: $TagInvitationToTagHomeNavigation)
                        .tag("tag")
 
                }
                .edgesIgnoringSafeArea(.bottom) 
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    TagInvitationToTagHomeNavigation = ""
                }
        }
    }
}
