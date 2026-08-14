//
//  OpenedTag.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 8/27/21.
// 
import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Combine

struct OpenedTag: View {
    @State var tagID: String
    @State var isAddingNewUserToTag = false
    @State var text = ""
    @State var InviteMessageName = ""
    @State var InviteMessageClassification = ""
    @Binding var tagIDs: [String]
    @Binding var OpenedTagToNewPostNavigation: String
    @Binding var OpenedTagToTagHomeNavigation: String
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var functions = CreateTagFunction()
    @State var invitationInformation = [String:String]()
    @ObservedObject var myTags: MyTagsOO
    @State var isOpenedFromPost = false
    @ObservedObject var tagFriends: TagFriendsOO
    @State var FriendProfileMatchedGeometry: String = ""
    @State var isEditingMembers = false
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    @State var isFromTabView = false
    var body: some View {
        ZStack {
            Color.mainColorInverse
                .ignoresSafeArea(.all)
            Color.speakerPurple.opacity(0.2)
                .ignoresSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {
                        if isAddingNewUserToTag == true {
                            withAnimation(.easeInOut) {
                                isAddingNewUserToTag.toggle()
                            }
                        } else {
                            OpenedTagToTagHomeNavigation = ""
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.speakerPink)
                    }.buttonStyle(.borderless)
                    
                    Button(action: {
                        withAnimation(.easeInOut) {
                            isAddingNewUserToTag.toggle()
                        }
                    }) {
                        Image(systemName: isAddingNewUserToTag ? "clear" : "plus.circle" )
                            .font(.title)
                            .foregroundColor(Color.speakerPink)
                        
                    }.buttonStyle(.borderless)
                    Spacer()
                    Text("\(myTags.tags[tagID]?.name ?? "")")
                        .foregroundColor(.speakerPurple)
                        .font(.largeTitle)
                        .shadow(radius: 1, x: 1, y: 1)
                        .padding(.trailing, isOpenedFromPost ? screenWidth/5 : 0)
                    
                    Spacer()
                    if isOpenedFromPost == false {
                        HStack (spacing: 10){
                            Button(action: {
                                if let firstIndex = tagIDs.firstIndex(of: tagID) {
                                    tagIDs.remove(at: firstIndex)
                                }
                                OpenedTagToNewPostNavigation = ""
                                OpenedTagToTagHomeNavigation = ""
                            }){
                                Image(systemName: "xmark")
                                    .padding(.trailing, 10)
                                    .font(.title2)
                                    .foregroundColor(.speakerPink)
                                    .padding(.top, 4)
                            }.buttonStyle(.borderless)
                            Button(action: {
                                if tagIDs.firstIndex(of: tagID) == nil {
                                    tagIDs.append(tagID)
                                }
                                OpenedTagToNewPostNavigation = ""
                                OpenedTagToTagHomeNavigation = ""
                            }){
                                Image(systemName: "checkmark")
                                    .padding(.trailing)
                                    .font(.title)
                                    .foregroundColor(.speakerPurple)
                            }.buttonStyle(.borderless)
                                .if(tutorialNumber == 12){$0.highPriorityGesture(DragGesture())}
                        }
                    }
                }
                HStack {
                    Text(myTags.tags[tagID]?.description ?? "")
                        .font(.headline)
                        .padding(.vertical, 5)
                        .multilineTextAlignment(.leading)
                      .foregroundColor(Color.mainColor)
                    
                    Spacer()
                }
                Divider()
                    .padding(.leading, -16)
                    .padding(.bottom, 10)
                
                if isAddingNewUserToTag == true {
                    Group {
                        HStack(spacing: 15) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundColor(Color.mainColor.opacity(0.3))
                            
                            TextField("Search current friends", text: self.$text)
                            if self.text != "" {
                                Button(action: {
                                    self.text = ""
                                }){
                                    Image(systemName: "clear")
                                        .font(.headline)
                                        .foregroundColor(.mainColor)
                                        .opacity(0.2)
                                } // BUTTON
                                .buttonStyle(.borderless)
                            }
                        }// HSTACK
                        .padding(10)
                        .background(Color.mainColorInverse)
                        .cornerRadius(10)
                        .shadow(radius: 2, x: 0, y: 1)
                        .padding(.trailing)
                    }
                    ScrollView(showsIndicators: false) {
                        LazyVStack() {
                            
                            ForEach(text == "" ? Array(friendsDictionary.friendsDictionary.values) : Array(friendsDictionary.friendsDictionary.values.filter{$0.username.lowercased().contains(self.text.lowercased())}), id: \.self) { item in
                                if tagFriends.friendIDs.firstIndex(of: item.id) == nil {
                                    SearchBarResults(id: item.id, size: 40)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            InviteMessageName = ""
                                            InviteMessageName = item.name
                                            invitationInformation["tagID"] = tagID
                                            invitationInformation["tagName"] = myTags.tags[tagID]?.name ?? ""
                                            invitationInformation["description"] = myTags.tags[tagID]?.description ?? ""
                                            invitationInformation["sentTo"] = item.id
                                            InviteMessageClassification = myTags.tags[tagID]?.name ?? ""
                                            hideKeyboard()
                                        }
                                    Divider()
                                }
                            }
                            .padding(.top, 5)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 40) // pushes last SearchBarResult up from underneat the safe area
                    }
                }
                if isAddingNewUserToTag != true {
                    
                    ScrollView(showsIndicators: false) {
                        LazyVStack() {
                            
                            HStack {
                                Text("KEY HOLDERS")
                                    .font(.headline)
                                  .foregroundColor(Color.mainColor)
                                Button(action: {
                                    withAnimation() {
                                        isEditingMembers.toggle()
                                    }
                                }){
                                    Image(systemName: "pencil.circle")
                                        .font(.callout)
                                        .foregroundColor(Color.speakerPink)
                                }.buttonStyle(.borderless)
                                Spacer()
                            }
                            ForEach(tagFriends.friendIDs, id: \.self) { friendID in
                                HStack {
                                    if isEditingMembers {
                                        Button(action: {
                                            
                                            guard let userId = Auth.auth().currentUser?.uid, userId != friendID else{
                                                return
                                            }
                                            removingTagInfo = RemovingTagInfo(
                                                tagName: myTags.tags[tagID]?.name ?? "" ,
                                                name:  friendsDictionary.friendsDictionary[friendID]?.name ?? "",
                                                tagID: tagID,
                                                sentTo: friendID)
                                        }){
                                            Image(systemName: "minus.circle")
                                                .foregroundColor(Color.speakerPink.opacity(0.7))
                                        }.buttonStyle(.borderless)
                                    }
                                    SearchBarResults(id: friendID, size: 40)
                                        .onTapGesture {
                                            withAnimation(.easeIn(duration: 0.3)) {
                                                FriendProfileMatchedGeometry = friendID
                                            }
                                        }
                                }
                                //                        Divider()
                            }
                        }
                    }
                    .padding(.top, -5)
                }
                Spacer()
                HStack (alignment: .bottom) {
                    LinearGradient(gradient: .init(colors: [Color.speakerPurple.opacity(0.8), Color.speakerPink.opacity(0.8)]), startPoint: .bottomLeading, endPoint: .bottomTrailing)
                        .shadow(radius: 2)
                }
                .frame(width: screenWidth, height: 50)
#if os(macOS)
                .onTapGesture{}
#endif
                
#if os(iOS)  
                .padding(.bottom, isFromTabView && iOS15 == false ? 35 : 0)
                .padding(.bottom, screenHeight < 800 && iOS15 == false ? 0 : 0)
                //                .padding(.bottom, phoneHeight / 20.83) // 43
                .padding(.bottom, iOS15 && screenHeight > 800 ? -35 : 0)
#endif
                .padding(.leading, -16)
            }
            .padding(.leading)
            .padding(.top, 120)
            if InviteMessageName != "" {
                SendClassificationInvite(name: InviteMessageName, classification: InviteMessageClassification, InviteMessageName: $InviteMessageName, functions: functions, friendsDictionary: friendsDictionary, invitationInformation: invitationInformation)
                    .padding(.top, 120)
            }
            if FriendProfileMatchedGeometry != "" {
                FriendProfileAllFriendsTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry)
                    .padding(.top, 60)
#if os(macOS)
                    .padding(.top, 60)
#endif
            }
            if removingTagInfo.isEmpty == false {
                RemoveFromTagAlert(functions: functions,
                                   tagFriends : tagFriends,
                                   removingTagInfo: $removingTagInfo)
                    .padding(.top, 120)
            }
            
        }
        .padding(.top, -120)
        //        .if(tutorialNumber == 12){$0.highPriorityGesture(DragGesture())}
        
    }
    
    @State var removingTagInfo = RemovingTagInfo()
    
    struct RemovingTagInfo {
        
        var tagName : String = ""
        var name : String = ""
        var tagID : String = ""
        var sentTo : String = ""
        
        var isEmpty : Bool {
            tagID.isEmpty
        }
        mutating func removeAll() {
            tagName = ""
            name = ""
            tagID = ""
            sentTo = ""
        }
    }
    
}

struct OpenedTagTabView: View {
    @Binding var OpenedTagToTagHomeNavigation: String
    @Binding var OpenedTagToNewPostNavigation: String
    @Binding var tagIDs: [String]
    @State var selectedTab = "tag"
    @ObservedObject var myTags: MyTagsOO
    @State var isOpenedFromPost = false
    @StateObject var tagFriends = TagFriendsOO(tagID: "")
    @State var isFromTabView = false
    @State var isFromNewMoment = false
    @ObservedObject var themeController: ThemeController
    var body: some View {
        if selectedTab == "tag" {
            
            
            
            let openedTag =  OpenedTag2(tagID: OpenedTagToTagHomeNavigation, tagIDs: $tagIDs, OpenedTagToNewPostNavigation: $OpenedTagToNewPostNavigation, OpenedTagToTagHomeNavigation: $OpenedTagToTagHomeNavigation, isFromNewMoment: isFromNewMoment, myTags: myTags, isOpenedFromPost: isOpenedFromPost, tagFriends: tagFriends, show: .constant(false), themeController: themeController)
            ZStack {
                //                Color.mainColorInverse
                //                    .ignoresSafeArea(.all)
#if os(iOS)
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    openedTag
                        .tag("tag")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
#elseif os(macOS)
                openedTag
#endif
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    OpenedTagToTagHomeNavigation = ""
                }
        }
    }
}

struct OpenedTag2: View {
    @State var tagID: String
    @State var isAddingNewUserToTag = false
    @State var text = ""
    @Binding var tagIDs: [String]
    @Binding var OpenedTagToNewPostNavigation: String
    @Binding var OpenedTagToTagHomeNavigation: String
    @State var isEditingMembers = true
    @State var isFromNewMoment = false
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var functions = CreateTagFunction()
    @ObservedObject var myTags: MyTagsOO
    @State var isOpenedFromPost = false
    @StateObject var tagFriends = TagFriendsOO(tagID: "")
    @State var FriendProfileMatchedGeometry: String = ""
    @Binding var show: Bool
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.primary
                .ignoresSafeArea(.all)
            VStack {
                HStack {
                        Button(action: {
                            withAnimation {
                                OpenedTagToTagHomeNavigation = ""
                                show.toggle()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    Spacer()
                    Text("\(myTags.tags[tagID]?.name ?? "")")
                        .foregroundColor(.black)
                        .font(.largeTitle)
//                        .padding(.leading, 40)
                    Spacer()

                        HStack (spacing: 0) {
                            
                            Button(action: {
                                if let firstIndex = tagIDs.firstIndex(of: tagID) {
                                    tagIDs.remove(at: firstIndex)
                                }
                                withAnimation {
                                    OpenedTagToNewPostNavigation = ""
                                    OpenedTagToTagHomeNavigation = ""
                                    show.toggle()
                                }
                                
                            }) {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                            .opacity(tagIDs.firstIndex(of: tagID) != nil ? 1 : 0)
                            .disabled(tagIDs.firstIndex(of: tagID) != nil ? false : true)
//                            Button(action: {
//                                if tagIDs.firstIndex(of: tagID) == nil {
//                                    tagIDs.append(tagID)
//                                }
//                                withAnimation {
//                                    OpenedTagToNewPostNavigation = ""
//                                    OpenedTagToTagHomeNavigation = ""
//                                    show.toggle()
//                                }
//                            }) {
//                                Image(systemName: "checkmark")
//                                    .padding(.trailing)
//                                    .font(.title2)
//                                    .foregroundColor(Color.black)
//                            }
                        }
                        .padding(.trailing)
                        
                    }
                .padding(.bottom, 20)
                
                
                
                ScrollView(showsIndicators: false) {
                    VStack (spacing: 10) {
                    LockMembers(isAddingNewUserToTag: $isAddingNewUserToTag, tagFriends: tagFriends, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, friendsDictionary: friendsDictionary, removingTagInfo: $removingTagInfo, functions: functions, tagID: tagID, myTags: myTags, themeController: themeController)
                    //                        .animation(.spring())
                        .padding(.bottom, 20)
                    VStack() {
                        //                        Group {
                        Button(action: {
                            withAnimation() {
                                isAddingNewUserToTag.toggle()
                                isEditingMembers.toggle()
                            }
                        }){
                            HStack {
                                Text("ADD MEMBERS")
                                    .font(.headline)
                                    .foregroundColor(Color.black)
                                
                                Image(systemName: "plus.circle")
                                    .font(.callout)
                                    .foregroundColor(themeController.theme.accent)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        //                            .padding(.bottom, 20)
                        if isAddingNewUserToTag {
                            VStack{
                                ForEach(Array(friendsDictionary.friendsDictionary.keys), id: \.self) { friendID in
                                    if tagFriends.friendIDs.firstIndex(of: friendID) == nil {
                                        HStack {
                                            //
                                            Button(action: {
                                                
                                                functions.inviteToTag(tagID: tagID ,
                                                                      sentTo: [friendID])
                                                tagFriends.addFriend(id: friendID)
                                            }){
                                                Image(systemName: "plus.circle")
                                                    .foregroundColor(themeController.theme.accent.opacity(0.7))
                                            }
                                            SearchBarResults(id: friendID, size: 40)
                                                .onTapGesture {
                                                    withAnimation(.easeIn(duration: 0.3)) {
                                                        FriendProfileMatchedGeometry = friendID
                                                        //                                                            hideKeyboard()
                                                    }
                                                }
                                        }
                                        Divider()
                                    }
                                    //                                }
                                }
                            }
                            
                        }
                        //                        }
                        
                    }
                }
                }
//                .padding(.bottom, 50)
                Spacer()
            }
            .padding(.leading)
//            .padding(.top, iOS15 ? 0 : 60)
            .edgesIgnoringSafeArea(.bottom)
            if FriendProfileMatchedGeometry != "" {
                FriendProfileHomeTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry, themeController: themeController)
                //                    .padding(.top, 60)
#if os(macOS)
                    .padding(.top, 60)
#endif
            }
        }
//        .animation(.easeIn(duration: 0.1))

    }
    @State var removingTagInfo = RemovingTagInfo()
    
    struct RemovingTagInfo {
        
        var tagName : String = ""
        var name : String = ""
        var tagID : String = ""
        var sentTo : String = ""
        
        var isEmpty : Bool {
            tagID.isEmpty
        }
        mutating func removeAll() {
            tagName = ""
            name = ""
            tagID = ""
            sentTo = ""
        }
    }
}

struct LockMembers: View {
    @Binding var isAddingNewUserToTag: Bool
    @State var isAllLockMembersShowing = false
    @ObservedObject var tagFriends: TagFriendsOO
    @Binding var FriendProfileMatchedGeometry: String
    @State var isChevronShowing = false
    @State var removeUserAlert = false
    @ObservedObject var friendsDictionary: FriendsDictionary
    @Binding var removingTagInfo : OpenedTag2.RemovingTagInfo
    @ObservedObject var functions: CreateTagFunction
    @State var tagID = ""
    @ObservedObject var myTags: MyTagsOO
    @ObservedObject var themeController: ThemeController
    var body: some View {
        VStack {
            Button(action: {
                withAnimation() {
                    isAddingNewUserToTag.toggle()
                }
            }){
                HStack {
                    Text("MEMBERS")
                        .font(.headline)
                      .foregroundColor(Color.black)
                    Image(systemName: "pencil.circle")
                        .font(.callout)
                        .foregroundColor(themeController.theme.accent)
                }
                Spacer()
            }
            
            if isAllLockMembersShowing != true {
                ForEach(tagFriends.firstSevenFriendIDs.unique(), id: \.self) { friendID in
                    
                    HStack {
                        Button(action: {
                            if friendID != Auth.auth().currentUser?.uid {
                            removingTagInfo = OpenedTag2.RemovingTagInfo(
                                tagName: myTags.tags[tagID]?.name ?? "" ,
                                name:  friendsDictionary.friendsDictionary[friendID]?.name ?? "",
                                tagID: tagID,
                                sentTo: friendID)
                            removeUserAlert = true
                            }
                        }){
                            Image(systemName: "minus.circle")
                                .foregroundColor(themeController.theme.accent.opacity(0.7))
                        }
                        SearchBarResults(id: friendID, size: 40)
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    FriendProfileMatchedGeometry = friendID
                                }
                            }
                    }
                    Divider()
                }
            } else {
                ForEach(tagFriends.friendIDs.unique(), id: \.self) { friendID in
                    
                    HStack {
                        Button(action: {
                            if friendID != Auth.auth().currentUser?.uid {
                            removeUserAlert = true
                          removingTagInfo = OpenedTag2.RemovingTagInfo(
                        tagName: myTags.tags[tagID]?.name ?? "" ,
                        name:  friendsDictionary.friendsDictionary[friendID]?.name ?? "",
                        tagID: tagID,
                        sentTo: friendID)
                            }
                        }){
                            Image(systemName: "minus.circle")
                                .foregroundColor(themeController.theme.accent.opacity(0.7))
                        }
                        SearchBarResults(id: friendID, size: 40)
                            .onTapGesture {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    FriendProfileMatchedGeometry = friendID
                                }
                            }
                    }
                    Divider()
                }
            }
            if isChevronShowing && tagFriends.friendIDs.count > 7 {
            Button(action: {
                withAnimation {
                    isAllLockMembersShowing.toggle()
                }
            }){
                Image(systemName: "chevron.right")
                    .rotationEffect(Angle(degrees: isAllLockMembersShowing ? 270 : 90))
                    .font(.headline)
                    .foregroundColor(themeController.theme.accent)
                    .shadow(color: Color.mainColorInverse.opacity(1), radius: 5, x:0 , y:0)
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
            .padding(.vertical, 2)
            }
        }         .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    isChevronShowing = true
                }
            }
            }
        .alert(isPresented: $removeUserAlert) {
              Alert (
                title: Text("Remove \(removingTagInfo.name) from \(removingTagInfo.tagName)?"),
                primaryButton: .destructive(Text("Yes")) {
                    functions.removeFromTag(tagID: removingTagInfo.tagID,
                                            sentTo: [removingTagInfo.sentTo])
                    tagFriends.removeFriend(id: removingTagInfo.sentTo)
                    withAnimation() {
                        removingTagInfo.removeAll()
                    }
                } ,
                secondaryButton: .cancel() {
                    removingTagInfo.removeAll()
                }
            )
        }
    }
}
