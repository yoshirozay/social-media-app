//
//  FriendsHome.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 3/7/22.
//


import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct FriendsHome: View {
    @Namespace var namespace
    @State var FriendProfileMatchedGeometry: String = ""
    @State var offset: CGFloat = 0
    @State var SearchFriendRequestMatchedGeometry = ""
    @State var SearchForFriendsMatchedGeometry = ""
    @State var SearchCurrentFriendsMatchedGeometry = ""
    @State var StrangerProfileMatchedGeometry = ""
    @State var StrangerProfileSelectedItem: Person!
    @Binding var AllFriendsMatchedGeometry: String
    @StateObject var preferences = PreferencesOO()
    @StateObject var functions = SettingFunctions()
    @StateObject var friendFunctions = FriendRequestsFunctions()
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @State var text = ""
    @State var emptyStringBinding = ""
    @State var ShareFriendMatchedGeometry = ""
    @State var showingAlert = false
    @State var deletingPersonID = ""
    @ObservedObject var newFriendRequest: UnreadFriendRequestsOO
    @State var MyProfileMatchedGeometry = ""
    @Binding var signOut: Bool
    @State var isSharedFriendPopUpShowing = false
    @State var isSuggestedFriendsShowing = false
    @ObservedObject var friendRequests: FriendRequestsOO
    @ObservedObject var suggestedFriends : SuggestedFriendsOO
    @Environment(\.colorScheme) var colorScheme
    @State var isQRConextMenuShowing = false
    @State var isProfileConextMenuShowing = false
    @StateObject var shareActivity = ShareActivityOO()
    @State var showQRScanner : Bool = false
    @State var hasSetKeyboardDismissMode: Bool = false
    @ObservedObject var currentTab: CurrentTab
    @ObservedObject var pushNotificationVM : PushNotificationVM
    @ObservedObject var themeController: ThemeController
    @State var buttonAlertType: ButtonAlertType = .none
//    @AppStorage("addAFriend") var addAFriendAlert : Bool = false
//    @State var addAFriendAlert : Bool = false
    var body: some View {
        ZStack {
            themeController.theme.primary
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack (spacing: 16) {
                    TitleHeader(title: "Friends") {
//                        AllFriendsMatchedGeometry = "house.fill"
                        currentTab.changeTab(tab: "house.fill")
                    }
                    Spacer()
                    Button(action: {
                        MyProfileMatchedGeometry = "0"
                        hideKeyboard()
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 32, height: 32)
                                .foregroundColor(Color.black)
                            WebImage(url: friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? ""]?.profilePicLink)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .background(Color.mainColor.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .buttonStyle(.borderless)
                    .padding(.trailing, 16)
                }
                .padding(.bottom, screenHeight > 870 ? screenHeight/89.6 : 0)
                SearchForStranger(StrangerProfileMatchedGeometry: $StrangerProfileMatchedGeometry, StrangerProfileSelectedItem: $StrangerProfileSelectedItem, themeController: themeController, friendsDictionary: friendsDictionary, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry)
                
                ZStack (alignment: .top) {
                    HStack {
                        Spacer()
                        Button(action: {
                            shareActivity.getDynamicLink(isAnEvent: false, eventID: "")
                        }){
                        Text("🔗  speakEZ.co/\(String((friendsDictionary.friendsDictionary[currentUserID ?? ""]?.username ?? "").dropFirst()))")
                        .foregroundColor(Color.mainColor.opacity(0.3))
                            .font(.headline)
                        }
                    }
                    .padding(.trailing)
                    .offset(y: iOS16 ? 5 : -6)
                ScrollView(showsIndicators: false)  {
                    if friendRequests.firstThreeRequests.isNotEmpty {
                        QuickFriendRequest(friendRequests: friendRequests, friendsDictionary: friendsDictionary, StrangerProfileMatchedGeometry: $StrangerProfileMatchedGeometry, StrangerProfileSelectedItem: $StrangerProfileSelectedItem, themeController: themeController)
                            .animation(.linear(duration: 0.2))
                    }
                    if suggestedFriends.firstThreeSuggestedFriends.isNotEmpty {
                        QuickAdd(suggestedFriends : suggestedFriends, friendRequests: friendRequests, friendsDictionary: friendsDictionary, StrangerProfileMatchedGeometry: $StrangerProfileMatchedGeometry, StrangerProfileSelectedItem: $StrangerProfileSelectedItem, themeController: themeController)
                            .animation(.none)
                    }
//                        .animation(.linear(duration: 0.2))
                    QuickFriend(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, ShareFriendMatchedGeometry: $ShareFriendMatchedGeometry, showingAlert: $showingAlert, deletingPersonID: $deletingPersonID, themeController: themeController)
                        .animation(.linear(duration: 0.2))
                }
                .introspectScrollView{ scrollView in
                    if hasSetKeyboardDismissMode == false{
#if os(iOS)
                        scrollView.keyboardDismissMode = .interactive
#endif
                        hasSetKeyboardDismissMode = true
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 26)
//                .padding(.bottom, iOS15 ? 0 : 40)
                }
                Spacer()
            }
//            .onAppear {
//                withAnimation {
//                    if addAFriendAlert == false {
//                        buttonAlertType = .addAFriend
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            addAFriendAlert = true
//                        }
//                    }
//                }
//            }
//            .padding(.top, 60)
            .blur(radius: isQRConextMenuShowing || isProfileConextMenuShowing || (shareActivity.qrCodeImageData != nil) ? 20 : 0)
            .disabled(isQRConextMenuShowing || isProfileConextMenuShowing || (shareActivity.qrCodeImageData != nil) ? true : false)
            .onTapGesture {
                withAnimation {
                    if isQRConextMenuShowing || isProfileConextMenuShowing != false {
                    isQRConextMenuShowing = false
                    isProfileConextMenuShowing = false
                    }
                }
            }
#if os(macOS)
            .padding(.top, 18)
#endif
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Remove \(friendsDictionary.friendsDictionary[deletingPersonID]?.name ?? "") from your friends list?"),
                               primaryButton: .destructive(Text("Delete")) {
                                friendFunctions.deleteFriend(deletedUserID: deletingPersonID)
                                   print("Deleting...")
                               },
                               secondaryButton: .cancel()
                           )
            }
            if FriendProfileMatchedGeometry != "" {
                FriendProfileHomeTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry, isFromOpenedPost: true, themeController: themeController)
#if os(macOS)
               .padding(.top, 80)
#endif
            }
            if MyProfileMatchedGeometry != "" , let userId = Auth.auth().currentUser?.uid {
                CurrentUserProfileTabView(ProfileMatchedGeometry: $MyProfileMatchedGeometry, id: userId,  signOut: $signOut, friendsDictionary: friendsDictionary, themeController: themeController)
//                    .padding(.top, 30)
            }
            if StrangerProfileMatchedGeometry != "" {
                StrangerProfileTabView(ProfileMatchedGeometry: $StrangerProfileMatchedGeometry, person: StrangerProfileSelectedItem, id: StrangerProfileSelectedItem.id)
            }
            if let person = pushNotificationVM.strangerUser {
                StrangerProfileTabView(ProfileMatchedGeometry: $pushNotificationVM.profileMatchedGeometry,
                                       person: person,
                                       id: pushNotificationVM.profileMatchedGeometry,addPNListener: false)
                .id(pushNotificationVM.profileMatchedGeometry)
                .zIndex(pushNotificationVM.zIndex(.newFriendRequest))
            }
            if ShareFriendMatchedGeometry != "" {
                ShareFriendTabView(SharePhotoMatchedGeometry: $ShareFriendMatchedGeometry, selectedFriend: ShareFriendMatchedGeometry, isSharedFriendPopUpShowing: $isSharedFriendPopUpShowing)
            }
            Group {
                if isQRConextMenuShowing {
                    QRContextMenu(isQRConextMenuShowing: $isQRConextMenuShowing, showQRScanner: $showQRScanner, shareActivity: shareActivity)
                }
                if isProfileConextMenuShowing {
                    ShareProfileContextMenu(isProfileConextMenuShowing: $isProfileConextMenuShowing, shareActivity: shareActivity)
                }
                if buttonAlertType != .none {
                    ButtonTapAlertController(buttonAlertType: $buttonAlertType, themeController: themeController)
                }
            }
            QRCodeViews
        }
        .ignoresSafeArea(edges: .bottom)
        .padding(.bottom, -10)
//        .padding(.top, -60)
    }
#if os(iOS)
    var QRCodeViews : some View {
        ZStack{

            if showQRScanner{
                QRScannerView(showQRScanner : $showQRScanner)
            }
            if let _ = shareActivity.qrCodeImageData {
                QRCodeView(qrCodeImageData: $shareActivity.qrCodeImageData)
            }
            if let _ = shareActivity.shareURL {
                ActivityViewController(shareURL: $shareActivity.shareURL )
            }

        }
    }
#endif
}

struct QuickFriendRequest: View {
//    let friendData: [PostModel] = Bundle.main.decode("posts.json")
    @ObservedObject var friendRequests: FriendRequestsOO
    @State var isFriendRequestsShowing = false
    @State var isAnimating = true
    @ObservedObject var friendsDictionary: FriendsDictionary
    @Binding var StrangerProfileMatchedGeometry: String
    @Binding var StrangerProfileSelectedItem: Person?
    @ObservedObject var themeController: ThemeController
    var body: some View {
        
        HStack {
            if friendRequests.firstThreeRequests.isNotEmpty {
            Text("FRIEND REQUESTS")
                .font(.headline)
                .foregroundColor(Color.black)
            Spacer()
            }
        }
        VStack {
            
            if isFriendRequestsShowing != true {
                ForEach(Array(friendRequests.firstThreeRequests.values.sorted(by: ({$0.name < $1.name }))), id: \.self){ item in
                    if friendsDictionary.friendsDictionary[item.id] == nil {
                    FriendRequestResults(person: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring()) {
                                StrangerProfileMatchedGeometry = "0"
                                StrangerProfileSelectedItem = item
                            }
                        }
                    Divider()
                    }
                }
                .padding(.horizontal, 5)
                .padding(.top, 5)


            } else {
                ForEach(Array(friendRequests.requests.values.sorted(by: ({$0.name < $1.name }))), id: \.self) { item in
                    if friendsDictionary.friendsDictionary[item.id] == nil {
                    FriendRequestResults(person: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.1)) {
                                StrangerProfileMatchedGeometry = "0"
                                StrangerProfileSelectedItem = item
                            }
                        }
                    Divider()
                    }
                }
                .padding(.horizontal, 5)
                .padding(.top, 5)
            }
            if friendRequests.requests.count > 3 {
            Button(action: {
                withAnimation {
                    isFriendRequestsShowing.toggle()
                }
            }){
                Text(isFriendRequestsShowing != true ? "View more" : "View less")
                    .font(.headline)
                    .foregroundColor(Color.black)
            }
            .opacity(isAnimating ? 1 : 0)
            .animation(.easeIn(duration: 0.2))
            .padding(.bottom, 10)
            .padding(.vertical, 2)
            }
        }
        .padding(.top, 8)
        .background(themeController.theme.secondary.clipShape(RoundedRectangle(cornerRadius: 20)))
        .padding(.bottom, 10)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation() {
                    isAnimating = true
                }
            }
        }
    }
}

struct QuickAdd: View { 
    @State var isSuggestedShowing = false
    @ObservedObject var suggestedFriends : SuggestedFriendsOO
    @ObservedObject var friendRequests: FriendRequestsOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var isAnimating = true
    @Binding var StrangerProfileMatchedGeometry: String
    @Binding var StrangerProfileSelectedItem: Person?
    @ObservedObject var themeController: ThemeController
    func viewAllOrAllContactsTapped(){  
        withAnimation {
            isSuggestedShowing.toggle()
        }
        suggestedFriends.askForPermissionAndFetchContacts()
    }
    var body: some View {
        
        HStack {
            if suggestedFriends.firstThreeSuggestedFriends.isNotEmpty {
            Text("SUGGESTED FRIENDS")
                .font(.headline)
                .foregroundColor(Color.black)
            Spacer()
            
            
            if suggestedFriends.areContactsAvailable == false {
                Button(action: {
                    //now where we weill for now show the
                    viewAllOrAllContactsTapped()
                }){
                    HStack (spacing: 4) {
                        Text("ALL CONTACTS")
                            .font(.caption2)
                        Text(">")
                            .font(.caption)
                            .offset(y: -1)
                    }
                }
                .foregroundColor(Color.black)
                .padding(.trailing, 2)
            }
            }
        }
        VStack {
            if isSuggestedShowing == false {
                ForEach(Array(suggestedFriends.allSuggestedFriends.prefix(3).sorted(by: ({$0.user.username < $1.user.username }))), id: \.self){ item in
//                ForEach(Array(suggestedFriends.firstThreeSuggestedFriends.sorted(by: ({$0.user.username < $1.user.username }))), id: \.self){ item in
                    if friendsDictionary.friendsDictionary[item.user.id] == nil {
                    FriendRequestResults(person: item.user)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring()) {
                                StrangerProfileMatchedGeometry = "0"
                                StrangerProfileSelectedItem = item.user
                            }
                        }
//                        .contextMenu {
//                            Button(action :{
//                                SuggestedFriendsOO.removeSuggestFriend(removedUserID: item.user.id)
//                            }) {
//                            Text("Remove")
//                            }
//                        }
                    Divider()
                    }
                }
                .padding(.horizontal, 5)
                .padding(.top, 5)

            } else {
                if suggestedFriends.areContactsAvailable {
                    ForEach(Array(suggestedFriends.allSuggestedFriends.sorted(by: ({$0.user.username < $1.user.username }))), id: \.self){ suggestedFriend in
                        SuggestedFriendRow(suggestedFriend: suggestedFriend)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    StrangerProfileMatchedGeometry = "0"
                                    StrangerProfileSelectedItem = suggestedFriend.user
                                }
                            }
                            .contextMenu {
                                Button(action :{
                                    SuggestedFriendsOO.removeSuggestFriend(removedUserID: suggestedFriend.user.id)
                                }) {
                                Text("Remove")
                                }
                            }
                        Divider()
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, 5) 
                } else {
                    ForEach(Array(suggestedFriends.allSuggestedFriends.sorted(by: ({$0.user.username < $1.user.username }))), id: \.self){ item in
                        FriendRequestResults(person: item.user)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    StrangerProfileMatchedGeometry = "0"
                                    StrangerProfileSelectedItem = item.user
                                }
                            }
                            .contextMenu {
                                Button(action :{
                                    SuggestedFriendsOO.removeSuggestFriend(removedUserID: item.user.id)
                                }) {
                                Text("Remove")
                                }
                            }
                    }
                    .padding(.horizontal, 5)
                    .padding(.top, 5)

                }
            }
            if suggestedFriends.allSuggestedFriends.count > 3 {
            Button(action: {
                viewAllOrAllContactsTapped()
            }){
                Text(isSuggestedShowing != true ? "View more" : "View less")
                    .font(.headline)
                    .foregroundColor(Color.black)
            }
            .opacity(isAnimating ? 1 : 0)
            .animation(.easeIn(duration: 0.2))
            .padding(.bottom, 10)
            .padding(.vertical, 2)
            }
        }
        .padding(.top, 8)
        .background(themeController.theme.secondary.clipShape(RoundedRectangle(cornerRadius: 20)))
        .padding(.bottom, 10)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation() {
                    isAnimating = true
                }
            }
        }
    }
}

struct QuickFriend: View {
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @State var isAllFriendsShowing = false
    @State var isAnimating = true
    @Binding var FriendProfileMatchedGeometry: String
    @Binding var ShareFriendMatchedGeometry: String
    @Binding var showingAlert: Bool
    @Binding var deletingPersonID: String
    @ObservedObject var themeController: ThemeController
    var body: some View {
        
        HStack {
            Text("ALL FRIENDS")
                .font(.headline)
                .foregroundColor(Color.black)
            Spacer()
            Text("\(friendsDictionary.friendsDictionary.count - 2)/150")
                .font(.caption2)
                .foregroundColor(Color.black)
                .padding(.trailing, 5)
            
        }
        VStack {
            if isAllFriendsShowing != true {
                   ForEach(Array(friendsDictionary.firstTenFriends.values.sorted(by: ({$0.name < $1.name }))), id: \.self){ item in
                       if item.id != TristanUserID {
            SearchBarResults(id: item.id)
                               .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring()) {
                FriendProfileMatchedGeometry = item.id
                hideKeyboard()
            }
        }
        .padding(.horizontal, 5)
        .padding(.top, 5)
               
                       
                .contextMenu {
                    VStack {
                        Button(action: {
                            ShareFriendMatchedGeometry = item.id
    
                        }) {
                            Text("Share")
                                .font(.headline)
                        }.buttonStyle(.borderless)
                        Button(action: {
                            showingAlert = true
                            deletingPersonID =
                                item.id
                          
                        }) {
                            Text("Delete")
                        }.buttonStyle(.borderless)


                    }
                }
                       Divider()
            

                       }
    }
            } else {
                ForEach(Array(friendsDictionary.friendsDictionary.values.sorted(by: ({$0.name < $1.name }))), id: \.self){ item in
                    if item.id != TristanUserID {
         SearchBarResults(id: item.id)
     .onTapGesture {
         withAnimation(.spring()) {
             FriendProfileMatchedGeometry = item.id
                hideKeyboard()
         }
     }
     .padding(.horizontal, 5)
     .padding(.top, 5)
                    
             .contextMenu {
                 VStack {
//                     Button(action: {
//                         ShareFriendMatchedGeometry = item.id
// 
//                     }) {
//                         Text("Share")
//                             .font(.headline)
//                     }.buttonStyle(.borderless)
                     Button(action: {
//                            showingAlert = true
//                            deletingPersonID =
//                                item.id
                       
                     }) {
                         Text("Delete")
                     }.buttonStyle(.borderless)


                 }
             }
         
                    Divider()
                }
 }
            }
            if friendsDictionary.friendsDictionary.count > 11 {
            Button(action: {
                withAnimation {
                    isAllFriendsShowing.toggle()
                }
            }){
                Text(isAllFriendsShowing != true ? "View more" : "View less")
                    .font(.headline)
                    .foregroundColor(Color.black)
            }
            .opacity(isAnimating ? 1 : 0)
            .animation(.easeIn(duration: 0.2))
            .padding(.bottom, 10)
            .padding(.vertical, 2)
            }
        }
        .padding(.top, 8)
        .background(themeController.theme.secondary.clipShape(RoundedRectangle(cornerRadius: 20)))
        .padding(.bottom, 10)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation() {
                    isAnimating = true
                }
            }
        }
    }
}

struct QRContextMenu: View {
    @Binding var isQRConextMenuShowing: Bool
    @Binding var showQRScanner: Bool
    @ObservedObject var shareActivity: ShareActivityOO
    var body: some View {
        ZStack {
            
            HStack {
                ZStack {
                 
                    VStack (alignment: .leading) {
                        
                        Button(action: {
                            shareActivity.getDynamicLinkQRCode(isAnEvent: false)
                            isQRConextMenuShowing = false
                        }){
                            HStack {
                                Text("Show your QR Code")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .offset(y: -1)
                                    .foregroundColor(Color.mainColor)
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }.buttonStyle(.borderless)
                        Divider()
                        Button(action: {
                            isQRConextMenuShowing = false
                            showQRScanner = true
                        }){
                            HStack {
                                Text("Scan their QR Code")
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
            .shadow(color: Color.mainColor.opacity(0.1), radius: 20, x: 0, y: 0)
        }
    }
}
struct ShareProfileContextMenu: View {
    @Binding var isProfileConextMenuShowing: Bool
    @ObservedObject var shareActivity: ShareActivityOO
    var body: some View {
        ZStack {
            
            HStack {
                ZStack {
                 
                    VStack (alignment: .leading) {
                        
                        Button(action: {
                            shareActivity.getDynamicLink(isAnEvent: false, eventID: "")
                            isProfileConextMenuShowing = false
                        }){
                            HStack {
                                Text("Share My Profile")
                                    .font(.body)
                                    .fontWeight(.medium)
                                //                            .fontWeight(.light)
                                    .foregroundColor(Color.mainColor)
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }.buttonStyle(.borderless)

                    }
                }
            }
            .frame(width: screenWidth/1.5, height: 50)
            .background(Color.mainColorInverse
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))))
            .shadow(color: Color.mainColor.opacity(0.1), radius: 20, x: 0, y: 0)
        }
    }
}


struct AllFriendsTabView: View {
    @Binding var AllFriendsMatchedGeometry: String
    @State var selectedTab = "allFriends"
    @State var emptyBoolBinding = false
    @ObservedObject var newFriendRequest: UnreadFriendRequestsOO
    @Binding var signOut: Bool
    @ObservedObject var friendRequests: FriendRequestsOO
    @ObservedObject var suggestedFriends : SuggestedFriendsOO
    @ObservedObject var pushNotificationVM : PushNotificationVM
    @ObservedObject var themeController: ThemeController
    var body: some View {
        if selectedTab == "allFriends" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
//                    AllFriends(AllFriendsMatchedGeometry: $AllFriendsMatchedGeometry, newFriendRequest: newFriendRequest, signOut: $signOut)
                    FriendsHome(AllFriendsMatchedGeometry: $AllFriendsMatchedGeometry, newFriendRequest: newFriendRequest, signOut: $signOut, friendRequests: friendRequests, suggestedFriends: suggestedFriends, currentTab: CurrentTab(), pushNotificationVM: pushNotificationVM, themeController: themeController)
                        .tag("allFriends")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
        
            }
            .ignoresSafeArea(edges: .top)
        } else {
//            Hom e(signOut: $emptyBoolBinding)
            EmptyView()
                .onAppear() {
                    AllFriendsMatchedGeometry = ""
                }
        }
        
    }
}
 
