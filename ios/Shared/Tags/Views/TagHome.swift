//
//  TagHome.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 8/27/21.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Combine

struct TagHome: View {
    @State var SelectedTagMatchedGeometry = ""
    @State var SelectedTagDescription = ""
    @State var NewTagMatchedGeometry = ""
    @State var TagInvitationMatchedGeometry = ""
    @Binding var TagHomeNavigationMatchedGeometry: String
    @Binding var tagIDs: [String]
    @StateObject var tags : TagsObservable
    @ObservedObject var myTags: MyTagsOO
    @StateObject var functions = CreateTagFunction()
    @State var offset: CGFloat = 0
    @Binding var selectedTagName: [String]
    @State var falseBinding = false
    @State var trueBinding = true
    @State var isLoading = true
    @State private var showingAlert = false
    @State var deletedTagName = ""
    @State var deletedTagID = ""
    let columns = [GridItem(), GridItem()]
    
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    @State var isFromTabView = false
    @Environment(\.colorScheme) var colorScheme
    @Binding var show: Bool
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack (alignment: .bottomLeading) {
            themeController.theme.primary
            VStack(spacing: 0)  {
                HStack (spacing: 0) {
                    Button(action: {
                        withAnimation {
                            TagHomeNavigationMatchedGeometry = ""
                            show.toggle()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding(.leading)
                    }.buttonStyle(.borderless)
//                    Button(action: {
//                        withAnimation {
//                        NewTagMatchedGeometry = "0"
//                        }
//                    }){
//                        HStack {
//                            Image(systemName: "plus.circle")
//                                .font(.title)
//                                .foregroundColor(Color.speakerPink.opacity(1))
//                                .padding(.leading)
//
//                        }
//                    }.buttonStyle(.borderless)

                    Spacer()
                    
                    Text("LOCKS")
                        .font(.title)
                        .fontWeight(.bold)
                      .foregroundColor(Color.black)
                        .padding(.trailing, 42)
                    
                    Spacer()
                    
//                    Button(action: {
//
//                        TagHomeNavigationMatchedGeometry = ""
//                    }){
//                        Text("Done")
//                            .font(.title3)
//                            .fontWeight(.semibold)
//                            .foregroundColor(Color.speakerPink.opacity(1))
//                            .padding(.trailing)
//                    }.buttonStyle(.borderless)
                    
                }
                .padding(.bottom)
                 
//                Spacer()
                ScrollView (showsIndicators: false) {
                LazyVStack() {
//                    ScrollView (showsIndicators: false) {
                        VStack(spacing: -14) {
                            ForEach(tags.rows.indices, id: \.self) { rowIdx in
                                
                                HStack(spacing: 6) {
                                    ForEach(Array(tags.rows[rowIdx].indices), id: \.self) { columnIdx in
                                        let (tagId,tag) = tags.getTagInfo(rowIdx: rowIdx, columnIdx: columnIdx)
                                        let isDummy = tag?.isDummy==true
                                        IndividualTag(tagName: tag?.name ?? "",
                                                      selected: tagIDs.contains( tagId) != false ? $trueBinding : $falseBinding,  isDummy : isDummy, themeController: themeController)
                                            .offset(x: getOffset(index: rowIdx))
                                            .onTapGesture { 
//                                                withAnimation (.spring()) {
//                                                SelectedTagMatchedGeometry = tagId
                                                withAnimation {
                                                    if tagIDs.firstIndex(of: tag?.id ?? "") == nil {
                                                        tagIDs.append(tag?.id ?? "")
                                                    }
                                                    TagHomeNavigationMatchedGeometry = ""
                                                    show.toggle()
                                                }
//                                                }
                                            }
                                            .if(!isDummy) {
                                                $0.contextMenu {
                                                    VStack { 
                                                        Button(action: {
                                                            showingAlert = true
                                                            deletedTagName = tag?.name ?? ""
                                                            deletedTagID = tag?.id ?? ""
                                                        }) {
                                                            Text("Delete")
                                                        }
                                                        Button(action: {
                                                            SelectedTagMatchedGeometry = tagId
                                                            
                                                        }) {
                                                            Text("Edit")
                                                        }
                                                    }
                                                }
                                            }.disabled(isDummy)
                                    }
                                }
                                
                            }
                            
                        }
                        .padding()
                        .frame(width: screenWidth - 20)
                        .offset(x: offset)
                    }
                    
//                    Spacer()
                } // VStack
//                .padding(.bottom)
                
//                .padding(.top)
//                Spacer()
//                    .padding()
//                if tags.rows.count == 0 && isLoading == false {
//                    VStack (spacing: 10) {
//                    Text("NO LOCKS")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(Color.mainColor.opacity(0.2))
//                        .onTapGesture {
//                            NewTagMatchedGeometry = "0"
//                        }
//                        
//                    Button(action: {
//                        withAnimation {
//                        NewTagMatchedGeometry = "0"
//                        }
//                    }){
//                        HStack {
//                            Image(systemName: "arrow.right")
//                                .font(.largeTitle)
//                                .foregroundColor(Color.mainColor.opacity(0.2))
//                            
//                        }
//                    }.buttonStyle(.borderless)
//                    }
//                    .padding(.bottom, screenHeight/2)
//                }
               
              
//                HStack (alignment: .bottom) {
//                    LinearGradient(gradient: .init(colors: [Color.speakerPurple.opacity(0.8), Color.speakerPink.opacity(0.8)]), startPoint: .bottomLeading, endPoint: .bottomTrailing)
//                        .shadow(radius: 2)
//                }
//                .frame(width: screenWidth, height: 50)
//#if os(macOS)
//                .onTapGesture{}
//#endif
//#if os(iOS)
//                //                .padding(.bottom, phoneHeight / 20.83) // 43
//                                .padding(.bottom, isFromTabView && iOS15 == false ? 35 : 0)
//                                .padding(.bottom, iOS15 && screenHeight > 800 ? -35 : 0)
//                //                .padding(.bottom, phoneHeight < 800 ? -23 : 0)
//                                .padding(.bottom, screenHeight < 800 && iOS15 == false ? 0 : 0)
//#endif
//
            }
//            .ignoresSafeArea(.all)
            .alert(isPresented: $showingAlert) {
                Alert(
                               title: Text("Are you sure you want to delete \(deletedTagName)?"),
                               primaryButton: .destructive(Text("Delete")) {
                                   print("Deleting...")
                                functions.deleteTag(tagID: deletedTagID)
                               },
                               secondaryButton: .cancel()
                           )
      
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.02) {
                    withAnimation(){
                        isLoading = false
                    }
                }
            }
            .padding(.top, 120)
//            .padding(.top, iOS15 ? 0 : 50)
            ZStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            NewTagMatchedGeometry = "0"
                        }
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 101, height: 101)
                                .foregroundColor(themeController.theme.accent.opacity(0.7))
                            Circle()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color.mainColorInverse.opacity(0.2))
                            Text("+")
                                .font(.system(size: 100))
                                .fontWeight(.light)
//                                .foregroundColor(colorScheme == .light ? Color.accent.opacity(1) : Color.softWhite)
                                .foregroundColor(Color.mainColorInverse)
                                .padding(.bottom)

                        }
                        .padding(.leading)
                    }
//                    .padding(.bottom, iOS15 ? 0 : 60)
                }
            }
            .padding(.bottom)
            .padding(.trailing)
            Group {

                
            if SelectedTagMatchedGeometry != "" {
                OpenedTagTabView(OpenedTagToTagHomeNavigation: $SelectedTagMatchedGeometry, OpenedTagToNewPostNavigation: $TagHomeNavigationMatchedGeometry, tagIDs: $tagIDs, myTags: myTags, tagFriends: TagFriendsOO(tagID: SelectedTagMatchedGeometry), isFromTabView: isFromTabView, themeController: themeController)
                    .transition(.opacity)
//                    .padding(.top, iOS15 ? 0 : 50)
            }
 
            if NewTagMatchedGeometry != "" {
                CreateTagTabView(CreateTagMatchedGeometry: $NewTagMatchedGeometry, myTag: myTags, functions: functions, themeController: themeController)
                    .transition(.opacity)
//                    .padding(.top, iOS15 ? 0 : 50)
                    .frame(width: screenWidth, height: screenHeight-66)
            }

            }  .padding(.top, 120)

        }
       
#if os(iOS)
        .padding(.top, -120)
#elseif os(macOS)
        .padding(.top, -50)
#endif
        .highPriorityGesture( tutorialNumber == 9 ? DragGesture() : nil )
        
    }
    
    func getOffset(index: Int) -> CGFloat {
        let current = tags.rows[index].count
        // moving half of the width 
#if os(macOS)
        let screenWidth = IndividualTag.screenWidth 
#endif
        let offset = ((screenWidth - 40) / 3) / 2
        if index != 0 {
            let previous = tags.rows[index - 1].count
            if current == 1 {
                if previous == 2 {
                    return 0
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

struct TagHomeTabView: View {
    @Binding var TagHomeNavigationMatchedGeometry: String
    @Binding var tagIDs: [String]
    @State var selectedTab = "tag"
    @ObservedObject var myTags: MyTagsOO
    @State var isFromTabView = false
    @ObservedObject var themeController: ThemeController
    var body: some View {
        if selectedTab == "tag" {
            ZStack {
//                Color.mainColorInverse
//                    .ignoresSafeArea(.all)
                let tagHome = TagHome(TagHomeNavigationMatchedGeometry: $TagHomeNavigationMatchedGeometry,
                                      tagIDs: $tagIDs,
                                      tags: TagsObservable(tagsDictionary: myTags),
                                      myTags: myTags,
                                      selectedTagName: $tagIDs,
                                      isFromTabView: isFromTabView, show: .constant(false), themeController: themeController)
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    tagHome
                        .tag("tag")
//                        .padding(.top, -60)
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                tagHome
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    TagHomeNavigationMatchedGeometry = ""
                }
        }
    }
}
