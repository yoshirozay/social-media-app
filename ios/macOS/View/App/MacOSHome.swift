//
//  MacOSHome.swift
//  speakEZ (macOS)
//
//  Created by Ahmad naeem on 11/19/21.
//


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SDWebImageSwiftUI


struct MacOSHome: View {
    
    @State var emptyStringBinding = ""
    @State var selectedTab = "home"
    @Binding var signOut: Bool
    @StateObject var newFriendRequest = UnreadFriendRequestsOO()
    @EnvironmentObject var allChats: AllMessagesOO
    @EnvironmentObject var notifications : NotificationsOO
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    
    var body: some View {
        ZStack {
            HStack {
                VStack{
                    getNavButtonFor(Constant.notifications).background(
                            ZStack{
                                if notifications.newNotifications.isNotEmpty {
                                    bubbleView.disabled(true)
                                }
                            }
                        )
                    
                    getNavButtonFor(Constant.friends).background(
                        ZStack{
                            if newFriendRequest.newRequest {
                                bubbleView.disabled(true)
                            }
                        }
                    )
                    
                    getNavButtonFor(Constant.allMessages).background(
                        ZStack{
                            if allChats.doesUserHaveAMessage {
                                bubbleView.disabled(true)
                            }
                        }
                    )
                    getNavButtonFor(Constant.newPost)
                    getNavButtonFor(Constant.home)
                    Spacer()
                    getNavButtonFor(Constant.profile)
                }
                .padding(.leading)
                .padding(.vertical,20)
                .frame(width: SideMenuConstant.width)
                tabView
            }
        }
        .ignoresSafeArea(.all)
    }
    
    var bubbleView : some View {
        Circle()
            .foregroundColor(.red)
            .frame(width: 10, height: 10)
            .padding(.leading,20)
            .padding(.top,9)
    }
    
    func getNavButtonFor(_ detail : Detail) -> MacOSNavigationButton{
        MacOSNavigationButton(detail: detail,  selectedTab: $selectedTab)
    }
    
    var tabView : some View {
        
            TabView(selection: $selectedTab) {
                
            NewPost(NewPostMatchedGeometry: $emptyStringBinding, selectedTab: $selectedTab)
                    .setMainViewFrame()
                .tag(Constant.newPost.selectionKey)
                
                Home(signOut: $signOut,selectedTab : $selectedTab)
                    .setMainViewFrame()
                .tag(Constant.home.selectionKey)
                
            
            AllMessages(AllMessagesMatchedGeometry: $emptyStringBinding, selectedTab: $selectedTab)
                    .setMainViewFrame()
                .tag(Constant.allMessages.selectionKey)
                
            
            Notifications(NotificationstMatchedGeometry: $emptyStringBinding, newFriendRequest: newFriendRequest)
                .tag(Constant.notifications.selectionKey)
                .setMainViewFrame()
                .environmentObject(notifications)
            
            AllFriends(AllFriendsMatchedGeometry: $emptyStringBinding, newFriendRequest: newFriendRequest, signOut: $signOut)
                  .setMainViewFrame()
                .tag(Constant.friends.selectionKey)
                 //FIXME: - i think it would be better to have a state with user id and we update it using a listern or somthing similar.
            if let userId = Auth.auth().currentUser?.uid {
                CurrentUserProfile(ProfileMatchedGeometry: $emptyStringBinding, postData: FriendsPostsOO(id: userId), id: userId, signOut: $signOut,isFromMacOSHome : true)
                    .setMainViewFrame()
                    .tag(Constant.profile.selectionKey)
            }
//            Color.black.padding(.bottom,-5)
        }
        .onChange(of: selectedTab) { tab in
            if tab == Constant.allMessages.selectionKey {
                allChats.markAllUnreadMessagesRead()
            }else if tab == Constant.notifications.selectionKey {
                notifications.readNotification()
            }
        }
        .frame(width: screenWidth,height: screenHeight)
    }
    
    func getZIndex(_ detail : MacOSHome.Detail) -> Double{
        selectedTab ==  detail.selectionKey ? 100 : 0
    }
    
}

extension MacOSHome {
    
    struct Constant {
        static let newPost = Detail(title: "New Post", selectionKey: "newPost", imageName: "speak")
        static let home = Detail(title: "Home", selectionKey: "home", imageName: "home")
        static let allMessages = Detail(title: "Messages", selectionKey: "allMessages", imageName: "chat-bubble")
        static let notifications = Detail(title: "Notifications", selectionKey: "notifications", imageName: "notification")
        static let friends = Detail(title: "Friends", selectionKey: "friends", imageName: "hexagon")
        static let profile = Detail(title: "Profile", selectionKey: "profile", imageName: "user")
    }
    
    struct Detail : Equatable {
        let title : String
        let selectionKey : String
        let imageName : String
    }
}

extension View {
  fileprivate func setMainViewFrame() -> some View {
      return self.frame(width: screenWidth,height: screenHeight).padding(.bottom,25).padding(.leading,-5)
    }
}

extension NSImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> NSImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
    
        let newImage = NSImage(size: scaledImageSize)
        newImage.lockFocus()
        self.draw(in: NSMakeRect(0, 0, scaledImageSize.width, scaledImageSize.height),
                  from: NSMakeRect(0, 0, self.size.width, self.size.height),
                  operation: NSCompositingOperation.sourceOver,
                  fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = scaledImageSize
        return newImage
    }
    
 
//    func compressUnderMegaBytes(megabytes: CGFloat) -> NSImage? {
//
//        var compressionRatio = 1.0
//        guard let tiff = self.tiffRepresentation, let imageRep = NSBitmapImageRep(data: tiff) else { return nil }
//        var compressedData = imageRep.representation(using: .jpeg, properties: [.compressionFactor : compressionRatio])!
//        while CGFloat(compressedData.count) > megabytes * 1024 * 1024 {
//            compressionRatio = compressionRatio * 0.9
//            compressedData = imageRep.representation(using: .png, properties:  [.compressionFactor : compressionRatio])!
//            if compressionRatio <= 0.4 {
//                break
//            }
//        }
//        return NSImage(data: compressedData)
//    }
}

struct AllFriends: View {
    
    @Namespace var namespace
    @State var FriendProfileMatchedGeometry: String = ""
    @State var FriendProfileID: String = ""
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
    @State var text = ""
    @State var emptyStringBinding = ""
    @State var ShareFriendMatchedGeometry = ""
    @State private var showingAlert = false
    @State var deletingPersonID = ""
    @ObservedObject var newFriendRequest: UnreadFriendRequestsOO
    @State var MyProfileMatchedGeometry = ""
    @Binding var signOut: Bool
    @State var isSharedFriendPopUpShowing = false
    @State var isSuggestedFriendsShowing = false
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0

    var body: some View {
        ZStack {
            Color.mainColorInverse
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack (spacing: 16) {
#if os(iOS)
                    Button(action: {
                        AllFriendsMatchedGeometry = ""
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .padding(.leading)
                    }.buttonStyle(.borderless)
#endif
 
                    Text("Friends")

                        .fontWeight(.bold)
                        .font(screenWidth < 400 ? .title2 : .title)
#if os(macOS)
                    .padding(.leading,10)
#endif

                    Spacer()
                    HStack (spacing: 0) {
                        ZStack {
                        HeaderButton(image: "person.fill.questionmark") {
                            if newFriendRequest.newRequest == true {
                                friendFunctions.readFriendRequest()
                            }
                            SearchFriendRequestMatchedGeometry = "0"
                            hideKeyboard()
                        }
                            Circle()
                                .frame(width: 10, height: 10)
                                .offset(x: 10, y: 10)
                                .foregroundColor(newFriendRequest.newRequest == true ? Color.blue.opacity(0.7) : Color.blue.opacity(0.0))
                        }
                        .matchedGeometryEffect(id: UUID(), in: namespace, isSource: false)
                   
                        HeaderButton(image: "list.bullet") {
                            isSuggestedFriendsShowing = true

                        }
                        .matchedGeometryEffect(id: UUID(), in: namespace, isSource: false)
                        ZStack {
                        Circle()
                            .frame(width: 33, height: 33)
                            .foregroundColor(friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? "" ]?.profileCircle)
//                                .foregroundColor(Color.mainColor)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.clear.opacity(1), Color.clear.opacity(1)]), startPoint: .leading, endPoint: .trailing))
                            .clipShape(Circle())
                        Button(action: {
                            MyProfileMatchedGeometry = "0"
                            hideKeyboard()
                        }) {
                            WebImage(url: friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? ""]?.profilePicLink)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .background(Color.mainColor.opacity(0.1))
                                .clipShape(Circle())
                        }.buttonStyle(.borderless)
                        }
                        .padding(.leading, 14)
                    } // HSTACK
                    .padding(.horizontal, 16)
                }
              .foregroundColor(Color.mainColor)
                ZStack {
                    SearchForSomeone(StrangerProfileMatchedGeometry: $StrangerProfileMatchedGeometry, StrangerProfileSelectedItem: $StrangerProfileSelectedItem, friendsDictionary: friendsDictionary)
                    .padding(.top, 5)
                    .padding(.bottom, 5)
                    .padding(.bottom, iOS15 ? 15 : 0)
                    
                Text("\(friendsDictionary.friendsDictionary.count-2)/150")
                    .fontWeight(.bold)
                    .font(.footnote)
                    .opacity(0.3)
                    .offset(x: screenWidth/3 + 15, y: 40)

                }
                
                        List{
                            ForEach(Array(friendsDictionary.friendsDictionary.values.sorted(by: ({$0.name < $1.name }))), id: \.self){ item in
                                SearchBarResults(id: item.id)
                            .matchedGeometryEffect(id: UUID(), in: namespace, isSource: false)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    FriendProfileMatchedGeometry = "0"
                                    FriendProfileID = item.id
                                    hideKeyboard()
                                }
                            }
                                    .padding(.vertical, 2)
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
                                

                    
                        }

                    }
                        .listStyle(InsetListStyle())
//                        .padding(.horizontal, -8)
                        .padding(.horizontal, iOS15 ? 10 : -8)
//                        .listRowInsets(EdgeInsets(top: 0, leading: -10, bottom: 0, trailing: 0))
//                        .padding(.bottom, 0)
                        .padding(.horizontal, iOS15 ? -20: 0)
                        .padding(.top, iOS15 ? -20 : 0)
                        .padding(.top, iOS15 ? 0 : 8)
                        .padding(.bottom, iOS15 ? 0 : 60)
                        .padding(.horizontal, iOS15 ? 0 : -4)
//                        .animation(.easeIn)
            } .padding(.top, 60)
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
            
            Group {
                 //FIXME: - need to check do we still need SearchForSomeoneTabView or not
//                if isSuggestedFriendsShowing != false {
//                    SearchForSomeoneTabView(isSuggestedFriendsShowing: $isSuggestedFriendsShowing)
//                }
                if isSharedFriendPopUpShowing != false {
                    SharedPopUp(isShowingPopUp: $isSharedFriendPopUpShowing)
                        
                }
                if FriendProfileMatchedGeometry != "" {
                    FriendProfileAllFriendsTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileID)
#if os(macOS)
                   .padding(.top, 80)
#endif
                }
                
                if MyProfileMatchedGeometry != "" , let userId = Auth.auth().currentUser?.uid {
                    CurrentUserProfileTabView(ProfileMatchedGeometry: $MyProfileMatchedGeometry, id: userId,  signOut: $signOut, friendsDictionary: friendsDictionary)
                        .padding(.top, 60)
                }
                
                if SearchFriendRequestMatchedGeometry != "" {
                    FriendRequestsTabView(searchFriendRequestMatchedGeometry: $SearchFriendRequestMatchedGeometry)
                }
                if StrangerProfileMatchedGeometry != "" {
                    StrangerProfileTabView(ProfileMatchedGeometry: $StrangerProfileMatchedGeometry, person: StrangerProfileSelectedItem, id: StrangerProfileSelectedItem.id)
                }
                if ShareFriendMatchedGeometry != "" {
                    ShareFriendTabView(SharePhotoMatchedGeometry: $ShareFriendMatchedGeometry, selectedFriend: ShareFriendMatchedGeometry, isSharedFriendPopUpShowing: $isSharedFriendPopUpShowing)
                }

            } // MatchedGeometryEffects
            if tutorialNumber == 4  {
                SwipeArrowTutorialView(direction: .right)
                    .onDisappear {
                        if tutorialNumber == 4 {
                            tutorialNumber = 5
                        }
                    }
            }
        }
        .padding(.top, -60)
        
    }
    func getOffset(index: Int) -> CGFloat {
        
#if os(macOS)
        let screenWidth = IndividualTag.screenWidth
#endif
        let current = allFriends.rows[index].count
        // moving half of the width
        let offset = ((screenWidth - 10) / 3) / 2
        if index != 0 {
            let previous = allFriends.rows[index - 1].count
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


