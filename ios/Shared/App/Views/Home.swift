//
//  Home.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/16/21.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage


struct HomeController: View {
    @Binding var signOut: Bool// remove when successfully connected new Login
    @EnvironmentObject var firstLogin: FirstLoginOO
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @EnvironmentObject var sharedPerson : DynamicViewsNavigationOO
    @StateObject var allChats : AllMessagesOO
    @StateObject var intro : IntroVideoOO
    @StateObject var notifications = NotificationsOO()
    @StateObject var eventModel = EventModelOO()
    @StateObject var myTags = MyTagsOO()
    @StateObject var themeController = ThemeController()
    @State var newMedia: SelectedMedia?
    @State var emptyStringBinding = ""
    @State var emptyStringArrayBinding = [String]()
    @EnvironmentObject var currentTab: CurrentTab
 
    let persistenceController = PersistenceController.shared
    
    
    var homeView : some View {
#if os(iOS)
        HomeTabView(allChats: allChats, newMedia: $newMedia,
                    pushNotificationVM: PushNotificationVM(timelinePosts: timelinePosts, allMessagesOO: allChats, eventModel: eventModel), signOut: $signOut, NewPostMatchedGeometry: $emptyStringBinding, timelinePosts: timelinePosts, eventModel: eventModel, currentTab: currentTab, myTags: myTags, themeController: themeController)
//        HomeTabView(newMedia: $newMedia,
//                    pushNotificationVM: pushNotificationVM, signOut: $signOut, NewPostMatchedGeometry: $emptyStringBinding, timelinePosts: timelinePosts, eventModel: eventModel, currentTab: currentTab)
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
#elseif os(macOS)
        MacOSHome(signOut: $signOut)
#endif
    }
    
    var body: some View {
        ZStack{
            if firstLogin.accountHasBeenCreated {
                
                homeView
                    .environmentObject(allChats)
                    .environmentObject(notifications)
#if os(iOS)
                if sharedPerson.didGetDynamicLink {
                    DynamicLinkViews(friendsDictionary: friendsDictionary, eventModel: eventModel, themeController: themeController)
                }
#endif
            }
            else{
                introController
                //                   ZStack{
                //                       (Color.speakerPink)
                //                       VStack{
                //                           Spacer()
                //                           Text("Loading...").font(.largeTitle).foregroundColor(.white)
                //                           Spacer()
                //                           ProgressViewPurpleCircular().scaleEffect(4)
                //                           Spacer()
                //                       }
                //                   }.ignoresSafeArea()
            }
            
            if intro.showIntroController {
                introController
            }
            //           else if intro.showVideo {
            //               IntroVideoView(intro: intro)
            //           }
            
        }
    }
    
    var introController : some View{
        IntroductionController(friendsDictionary: friendsDictionary,
                               allChats: allChats,
                               timelinePosts: timelinePosts,
                               signOut: $signOut,
                               newMedia: $newMedia,
                               persistenceController: persistenceController,
                               intro: intro,
                               notifications: notifications,
                               firstLogin: firstLogin)
    }
    @State var showVerifyPhoneView : Bool = false
    
    @StateObject var phoneTestVM = UserPhoneTestVM()
    //    @State var showContacts : Bool = false
    var userContactsView : some View {
        ZStack{
            VStack(alignment: .leading){
                Spacer()
                HStack{
                    
                    Button(action: {
                        //                        showContacts.toggle()
                        if let _ = currentUser?.providerData.first(where: {$0.providerID == "phone"}) {
                            currentUser?.unlink(fromProvider: "phone", completion: { _, _ in})
                        }
                    }) {
                        //                        Image(systemName:  phoneTestVM.userPhoneNumber == nil ? "phone.fill.arrow.up.right" :  "doc.text.magnifyingglass")
                        Text("")
                            .foregroundColor(.white).padding()
                            .background(Color.blue)
                        //                            .clipShape(Circle())
                    }
                    Spacer()
                }
            }.padding()
            //            if showContacts {
            //                if phoneTestVM.userPhoneNumber == nil {
            //                    VerifyPhoneNumber(showContacts : $showContacts)
            //                }else{
            //                    UserContactsView(showContacts : $showContacts)
            //                }
            //            }
        }
    }
    
    
}
struct Home: View {
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    @State var NotificationstMatchedGeometry = ""
    @State var AllFriendsMatchedGeometry = ""
    @State var AllMessagesMatchedGeometry = ""
    @Binding var NewPostMatchedGeometry: String
    @State var isNavigationMenuShowing = true
    @State var FriendProfileMatchedGeometry: String = ""
    @State var isDeletePostAlertShowing: Bool = false
    @State var deletedPost : PostModel?
    @Binding var signOut: Bool
    @StateObject var newFriendRequest = UnreadFriendRequestsOO()
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @EnvironmentObject var allChats : AllMessagesOO
    @EnvironmentObject var notifications : NotificationsOO
    @Environment(\.colorScheme) var colorScheme
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var OpenedPhotoSelectedItem: URL?
    @State var isFirstResponder: Bool = false
    @Binding var newMedia: SelectedMedia?
#if os(macOS)
    @Binding var selectedTab: String
#endif 
    @State var isLoading = true
    @StateObject var friendRequests = FriendRequestsOO()
    @ObservedObject var suggestedFriends: SuggestedFriendsOO
    @StateObject var postVM = PostVM()
    @State var showUpdatePost : PostModel? = nil
    @Binding var notificationInfo: NotificationBanner?
    @Binding var selectedGroupChat : ChatModel?
    @ObservedObject var pushNotificationVM : PushNotificationVM
    @ObservedObject var eventModel: EventModelOO
    @ObservedObject var currentTab: CurrentTab
    @ObservedObject var myTags: MyTagsOO
    @ObservedObject var themeController: ThemeController
    @State var newProfilePhoto: NewMedia?
    //under menu button tutorial view
    
    
    //    var fullTutorialView : some View {
    //        ZStack{
    //            if tutorialNumber == 3 {
    //                MyPeopleIntroTutorialView()
    //            }else if tutorialNumber == 8 {
    //                SwipeToCreateAMomentTutorialView()
    //            }else if tutorialNumber == 14 {
    //                OnlyYouCanSeeThisIcon14thTutorialView()
    //            }else if tutorialNumber == 15,
    //                     let firstPost = timelinePosts.postInfoValues.first?.post {
    //                TapToOpen15thTutorialView(firstPost : firstPost ,
    //                                          OpenedPostSel ectedItem : $Open edPostSelectedItem ,
    //                                          OpenedPostMatched Geometry : $OpenedPostM atchedGeometry)
    //            }else if tutorialNumber == 19 {
    //                TapToDelete19thTutorialView()
    //                    .onTapGesture {
    //                        deletedPost = timelinePosts.postInfoValues.first?.post
    //                                    isDeletePostAlertShowing = true
    //                                    tutorialNumber = 20
    //                    }
    ////                (action : {
    ////                    deletedPost = timelinePosts.postInfoValues.first
    ////                    isDeletePostAlertShowing = true
    ////                })
    //            } else if tutorialNumber == 20 {
    //                AlertDeleteButton20thTutorialView()
    //            }else if tutorialNumber == 21 {
    //                SwipeArrowTutorialView(direction: .left)
    //            }else if tutorialNumber == 22 {
    //                EndOfOnboarding23thTutorialView()
    //            }
    //
    //        }
    //    }
    
    func dismissOpenedPost(){
        postVM.dismissOpenedPost()
    }
    
    @State var friendProfileSelectedItem = ""
    var body: some View {
        ZStack (alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
//            Color.mainColor.opacity(colorScheme == .light ? 0.05 : 0.05)
            Color.mainColorInverse
                .edgesIgnoringSafeArea(.all)
            TimelineMainView2(friendProfileSelectedItem : $friendProfileSelectedItem,
                              FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                              isDeletePostAlertShowing: $isDeletePostAlertShowing,
                              deletedPost: $deletedPost,
                              OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry,
                              OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,
                              isFirstResponder: $isFirstResponder, showUpdatePost: $showUpdatePost,
                              mentionedUserVM: MentionedUserVM(friendsDictionary: timelinePosts.friendsDictionary),
                              currentTab: currentTab, pushNotificationVM: pushNotificationVM, audioAlert: .constant(false), cameraAlert: .constant(false), themeController: themeController, hasCreatedAMoment: .constant(false), newProfilePhoto: $newProfilePhoto)
            
            //                .edgesIgnoringSafeArea(.top)
            .padding(.horizontal, -28)
            .clipped()
            .blur(radius: NewPostMatchedGeometry == "" ? 0 : 10)
            .disabled(NewPostMatchedGeometry == "" ? false : true)
            
            
            
            if FriendProfileMatchedGeometry == "" && showUpdatePost == nil {
                arcMenu
                    .disabled(NewPostMatchedGeometry == "" ? false : true)
                    .opacity(NewPostMatchedGeometry == "" ? 1.0 : 0.0)
                
            }
            Group {
                //                if isReportPostPopUpShowing != false {
                //                    ReportPostPopUp(isReportPostPopUpShowing: $isReportPostPopUpShowing, postID: reportedPostID, reportedUser: reportedUserID)
                //                }
                if  let commentLikeVM = postVM.commentLikeVM  {
                    
                    OpenedPostTabView(
                        isFirstResponder: isFirstResponder,
                        commentLikeVM : commentLikeVM,
                        postVM: postVM, showUpdatePost: $showUpdatePost, myTags: myTags)
                    .ignoresSafeArea(.all)
                    
                    //                        .onAppear() {
                    //                            isFirstResponder = true
                    //                        }
                    //                        .transition(.opacity)
                }
                if NotificationstMatchedGeometry != "" {
//                    EventHomeController(EventMatchedGeometryEffect: $NotificationstMatchedGeometry, friendsDictionary: timelinePosts.friendsDictionary, eventModel: eventModel, pushNotificationVM: pushNotificationVM)
                    //                    NotificationsTabView(NotificationstMatchedGeometry: $NotificationstMatchedGeometry, newFriendRequest: newFriendRequest)
                    //                        .onAppear() {
                    ////                            isNavigationMenuShowing = false
                    //                            dismissOpenedPost()
                    //                        }
                    //                        .environmentObject(notifications)
                }
                if AllFriendsMatchedGeometry != "" {
                    AllFriendsTabView(AllFriendsMatchedGeometry: $AllFriendsMatchedGeometry, newFriendRequest: newFriendRequest, signOut: $signOut, friendRequests: friendRequests, suggestedFriends: suggestedFriends, pushNotificationVM: pushNotificationVM, themeController: themeController)
                        .onAppear() {
                            //                            isNavigationMenuShowing = false
                            dismissOpenedPost()
                        }
                    
                }
                if OpenedPhotoMatchedGeometry != "" {
                    OpenPhotoTabView(OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, photo: OpenedPhotoSelectedItem, isFromTimeline: true)
                        .padding(.top, -60)
                    
                }
                if AllMessagesMatchedGeometry != "" {
                    AllMessagesTabView(AllMessagesMatchedGeometry: $AllMessagesMatchedGeometry, pushNotificationVM: pushNotificationVM)
                        .onAppear() {
                            //                            isNavigationMenuShowing = false
                            dismissOpenedPost()
                        }
                }
                if NewPostMatchedGeometry != "" {
                    NewMomentTabView(NewPostMatchedGeometry: $NewPostMatchedGeometry, selectedMedia: $newMedia, timelinePosts: timelinePosts)
                        .onAppear() {
                            //                            isNavigationMenuShowing = false
                            dismissOpenedPost()
                            OpenedPhotoMatchedGeometry = ""
                        }
                    
                    //                    NewPostTabView(NewPostMatchedGeometry: $NewPostMatchedGeometry)
                    //                        .onAppear() {
                    //                            isNavigationMenuShowing = false
                    //                            OpenedPostMatchedGeom etry = ""
                    //                        }
                }
                //                if mentionedUserVM.presentTapView{
                //                    UserMentionTabView(mentionedUserVM: mentionedUserVM)
                //                }
            }  // Matched Geometry Effects / Button Navigation
            //            fullTutorialView
            //            .opacity(isLoading ? 0.0001 : 1)
            //            if isLoading {
            //                LoadingScreen()
            //                    .onAppear() {
            //                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            ////                            withAnimation(.easeOut(duration: 0.3)){
            //                                isLoading = false
            ////                            }
            //                        }
            //                    }
            //            }
        }
        .alert(isPresented: $isDeletePostAlertShowing) {
            var destructionAction = deletePost
            var cancelAlertButton = Alert.Button.cancel()
            if tutorialNumber == 20 {
                destructionAction = {
                    tutorialNumber = 21
                    deletePost()
                }
                cancelAlertButton = .cancel( nil)
            }
            
            return Alert(
                title: Text("Delete this Moment?"),
                primaryButton: .destructive(Text("Delete"),action : destructionAction ),
                secondaryButton: cancelAlertButton
            )
        }
    }
    
    var arcMenu : some View {
        
#if os(iOS)
        let arcMenu = ArcMenu2(isNavigationMenuShowing: $isNavigationMenuShowing,
                               NotificationstMatchedGeometry: $NotificationstMatchedGeometry,
                               AllFriendsMatchedGeometry: $AllFriendsMatchedGeometry,
                               AllMessagesMatchedGeometry: $AllMessagesMatchedGeometry,
                               NewPostMatchedGeometry: $NewPostMatchedGeometry,
                               newRequest: $newFriendRequest.newRequest )
#elseif os(macOS)
        let arcMenu = ArcMenu(isNavigationMenuShowing: $isNavigationMenuShowing,
                              NotificationstMatchedGeometry: $NotificationstMatchedGeometry,
                              AllFriendsMatchedGeometry: $AllFriendsMatchedGeometry,
                              AllMessagesMatchedGeometry: $AllMessagesMatchedGeometry,
                              NewPostMatchedGeometry: $NewPostMatchedGeometry,
                              newRequest: $newFriendRequest.newRequest,
                              selectedTab : $selectedTab)
#endif
        return arcMenu
            .environmentObject(allChats)
            .environmentObject(notifications)
        //            .padding(.trailing, -15)
        //            .padding(.bottom, iOS15 ? -20 : 10)
        //            .padding(.bottom, iOS15 && screenHeight < 800 ? 30 : 0)
            .offset(x: 75, y: screenHeight < 800 ? 60 : 25)
    }
    
    func deletePost(){
        if let post = deletedPost{
            timelinePosts.delete(post: post)
        }
        isDeletePostAlertShowing = false
        print("Deleting...")
        
    }
}


struct NavigationButton: View {
    @Environment(\.colorScheme) var colorScheme
    var imageName: String
    var height: CGFloat = 24
    var width: CGFloat = 24
    var backgroundColor: Color = .supportingColor
    var backgroundColor2: Color = .speakerPink
    var backgroundColor3: Color = Color.blue
    var isOnlyMessagesShowing: Bool = false
    var isOnlyFriendRequestShowing: Bool = false
    var action: () -> Void
    
    var body: some View {
        if colorScheme == .light {
            ZStack {
                Button(action: { action() }, label: {
                    Image(imageName)
                        .resizable()
                        .frame(width: width, height: height)
                        .padding(16)
                }).buttonStyle(.borderless)
                    .background(LinearGradient(gradient: .init(colors: [Color.speakerPurple.opacity(0.8), Color.speakerPink.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(color: Color.mainColor.opacity(0.7), radius: 30, x: 0.0, y: 0.0)
                if imageName == "filter" {
                    ZStack {
                        Circle()
                            .frame(width: 17, height: 17)
                            .offset(x: 30, y: 25)
                            .foregroundColor(isOnlyMessagesShowing == false ? backgroundColor2 : backgroundColor2.opacity(0.0))
                        Circle()
                            .frame(width: 17, height: 17)
                            .offset(x: 20, y: 25)
                            .foregroundColor(isOnlyMessagesShowing == false ? backgroundColor : backgroundColor2)
                        Circle()
                            .frame(width: 17, height: 17)
                            .offset(x: isOnlyFriendRequestShowing == false ? 10 : 20, y: 25)
                            .foregroundColor(backgroundColor3)
                    }
                } else if imageName == "notification" {
                    Circle()
                        .frame(width: 13, height: 13)
                        .offset(x: 20, y: 20)
                        .foregroundColor(backgroundColor)
                } else if imageName == "chat-bubble" {
                    Circle()
                        .frame(width: 13, height: 13)
                        .offset(x: 20, y: 20)
                        .foregroundColor(backgroundColor2)
                } else if imageName == "hexagon" {
                    Circle()
                        .frame(width: 13, height: 13)
                        .offset(x: 20, y: 20)
                        .foregroundColor(backgroundColor3)
                }
            }
        } else {
            ZStack{
                Button(action: { action() }, label: {
                    Image(imageName)
                        .resizable()
                        .frame(width: width, height: height)
                        .padding(16)
                }).buttonStyle(.borderless)
                    .background(LinearGradient(gradient: .init(colors: [Color.speakerPurple.opacity(0.8), Color.speakerPink.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .shadow(color: Color.mainColor.opacity(0.3), radius: 30, x: 0.0, y: 0.0)
                if imageName == "filter" {
                    ZStack {
                        Circle()
                            .frame(width: 17, height: 17)
                            .offset(x: 30, y: 25)
                            .foregroundColor(isOnlyMessagesShowing == false ? backgroundColor2 : backgroundColor2.opacity(0.0))
                        Circle()
                            .frame(width: 17, height: 17)
                            .offset(x: 20, y: 25)
                            .foregroundColor(isOnlyMessagesShowing == false ? backgroundColor : backgroundColor2)
                    }
                } else if imageName == "notification" {
                    Circle()
                        .frame(width: 13, height: 13)
                        .offset(x: 20, y: 20)
                        .foregroundColor(backgroundColor)
                } else if imageName == "chat-bubble" {
                    Circle()
                        .frame(width: 13, height: 13)
                        .offset(x: 20, y: 20)
                        .foregroundColor(backgroundColor2)
                } else if imageName == "hexagon" {
                    Circle()
                        .frame(width: 13, height: 13)
                        .offset(x: 20, y: 20)
                        .foregroundColor(backgroundColor3)
                }
                
            }
        }
        
    }
}


struct Home2: View {
    @State var NotificationstMatchedGeometry = ""
    @State var AllFriendsMatchedGeometry = ""
    @State var AllMessagesMatchedGeometry = ""
    @Binding var NewPostMatchedGeometry: String
    @State var isNavigationMenuShowing = true
    @State var FriendProfileMatchedGeometry: String = ""
    @State var isDeletePostAlertShowing: Bool = false
    @State var deletedPost : PostModel?
    @Binding var signOut: Bool
    @StateObject var newFriendRequest = UnreadFriendRequestsOO()
    @EnvironmentObject var timelinePosts: TimelinePostsOO
    @ObservedObject var allChats : AllMessagesOO
    @EnvironmentObject var notifications : NotificationsOO
    @Environment(\.colorScheme) var colorScheme
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var OpenedPhotoSelectedItem: URL?
    @State var isFirstResponder: Bool = false
    @Binding var newMedia: SelectedMedia?
#if os(macOS)
    @Binding var selectedTab: String
#endif
    @State var isLoading = true
    @StateObject var friendRequests = FriendRequestsOO()
    @ObservedObject var suggestedFriends: SuggestedFriendsOO
    @StateObject var postVM = PostVM()
    @State var showUpdatePost : PostModel? = nil
    @Binding var notificationInfo: NotificationBanner?
    @Binding var selectedGroupChat : ChatModel?
    @ObservedObject var pushNotificationVM : PushNotificationVM
    @ObservedObject var eventModel: EventModelOO
    @ObservedObject var currentTab: CurrentTab

    @State var friendProfileSelectedItem = ""
    @AppStorage("audioAlert") var audioAlert : Bool = false
    @AppStorage("cameraAlert") var cameraAlert : Bool = false
    @ObservedObject var themeController: ThemeController
    @AppStorage("hasCreatedAMoment") var hasCreatedAMoment : Bool = false
    @State var newProfilePhoto: NewMedia?
    var body: some View {
        ZStack {
            VStack(spacing: 0)  {
                tabView
                //            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .padding(.horizontal, 16)
                
                HStack (spacing: 0) {
                    ForEach(["house.fill", "person", "plus", "message", "squareshape.split.2x2"], id: \.self) { item in
                        TabBarButton(image: item, currentTab: currentTab, isSystemImage: item != "calendar", themeController: themeController)
                    }
                }
                .padding(.horizontal)
                //            .padding(.bottom, 20)
                .background(Color.black)
            }
            //            if  let commentLikeVM = postVM.commentLikeVM  {
            //
            //                OpenedPostTabView(
            //                    isFirstResponder: isFirstResponder,
            //                    commentLikeVM : commentLikeVM,
            //                    postVM: postVM, showUpdatePost: $showUpdatePost)
            //                .padding(.horizontal)
            //
            //            }
        }
        .onChange(of: colorScheme, perform: { value in
                themeController.lightOrDark(light: colorScheme == .light ? false : true)
        })
        .alert(isPresented: $isDeletePostAlertShowing) {
            var destructionAction = deletePost
            var cancelAlertButton = Alert.Button.cancel()

                cancelAlertButton = .cancel( nil)
            
            
            return Alert(
                title: Text("Delete this Moment?"),
                primaryButton: .destructive(Text("Delete"),action : destructionAction ),
                secondaryButton: cancelAlertButton
            )
        }
        .ignoresSafeArea(.all)
        
    }
    var tabView: some View {
        VStack {
            if iOS15 {
                TabView(selection: $currentTab.currentTab) {
                    TimelineMainView2(friendProfileSelectedItem : $friendProfileSelectedItem,
                                      FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                                      isDeletePostAlertShowing: $isDeletePostAlertShowing,
                                      deletedPost: $deletedPost,
                                      OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry,
                                      OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,
                                      isFirstResponder: $isFirstResponder, showUpdatePost: $showUpdatePost,
                                      mentionedUserVM: MentionedUserVM(friendsDictionary: timelinePosts.friendsDictionary),
                                      currentTab: currentTab, pushNotificationVM: pushNotificationVM, audioAlert: $audioAlert, cameraAlert: $cameraAlert, themeController: themeController, hasCreatedAMoment: $hasCreatedAMoment, newProfilePhoto: $newProfilePhoto)
                    .ignoresSafeArea(.all)
                    .edgesIgnoringSafeArea(.bottom)
                    .tag("house.fill")
                    .onAppear{ hideKeyboard()}
                    FriendsHome(AllFriendsMatchedGeometry: .constant(""), newFriendRequest: newFriendRequest, signOut: $signOut, friendRequests: friendRequests, suggestedFriends: suggestedFriends, currentTab: currentTab, pushNotificationVM: pushNotificationVM, themeController: themeController)
                        .tag("person")
                        .onAppear{ hideKeyboard()}
                    NewMoment(NewPostMatchedGeometry: .constant(""), selectedMedia: $newMedia, timelinePosts: timelinePosts, friendsDictionary: timelinePosts.friendsDictionary, currentTab: currentTab, audioAlert: $audioAlert, cameraAlert: $cameraAlert, themeController: themeController, hasCreatedAMoment: $hasCreatedAMoment, newProfilePhoto: $newProfilePhoto)
                        .tag("plus")
                    AllMessages(AllMessagesMatchedGeometry: .constant(""), allChats: allChats, selectedTab: .constant(""), isFromArcMenu: true, currentTab: currentTab, pushNotificationVM: pushNotificationVM, themeController: themeController)
                        .ignoresSafeArea(.all)
                        .edgesIgnoringSafeArea(.bottom)
                        .tag("message")
                        .onAppear{ hideKeyboard()}
                    EventHome(EventMatchedGeometryEffect: .constant(""), eventModel: eventModel, friendsDictionary: timelinePosts.friendsDictionary, CreateEventMatchedGeometry: "", currentTab: currentTab, pushNotificationVM: pushNotificationVM, themeController: themeController)
                        .tag("squareshape.split.2x2")
                        .onAppear{ hideKeyboard()}
                    
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            } else {
                TabView(selection: $currentTab.currentTab) {
                    TimelineMainView2(friendProfileSelectedItem : $friendProfileSelectedItem,
                                      FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry,
                                      isDeletePostAlertShowing: $isDeletePostAlertShowing,
                                      deletedPost: $deletedPost,
                                      OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry,
                                      OpenedPhotoSelectedItem: $OpenedPhotoSelectedItem,
                                      isFirstResponder: $isFirstResponder, showUpdatePost: $showUpdatePost,
                                      mentionedUserVM: MentionedUserVM(friendsDictionary: timelinePosts.friendsDictionary),
                                      currentTab: currentTab, pushNotificationVM: pushNotificationVM, audioAlert: $audioAlert, cameraAlert: $cameraAlert, themeController: themeController, hasCreatedAMoment: $hasCreatedAMoment, newProfilePhoto: $newProfilePhoto)
                    .ignoresSafeArea(.all)
                    .edgesIgnoringSafeArea(.bottom)
                    .tag("house.fill")
                    //                .onAppear{ hideKeyboard()}
                    FriendsHome(AllFriendsMatchedGeometry: .constant(""), newFriendRequest: newFriendRequest, signOut: $signOut, friendRequests: friendRequests, suggestedFriends: suggestedFriends, currentTab: currentTab, pushNotificationVM: pushNotificationVM, themeController: themeController)
                        .tag("person")
                    //                    .onAppear{ hideKeyboard()}
                    NewMoment(NewPostMatchedGeometry: .constant(""), selectedMedia: $newMedia, timelinePosts: timelinePosts, friendsDictionary: timelinePosts.friendsDictionary, currentTab: currentTab, audioAlert: $audioAlert, cameraAlert: $cameraAlert, themeController: themeController, hasCreatedAMoment: $hasCreatedAMoment, newProfilePhoto: $newProfilePhoto)
                        .tag("plus")
                    AllMessages(AllMessagesMatchedGeometry: .constant(""), allChats: allChats ,selectedTab: .constant(""), isFromArcMenu: true, currentTab: currentTab, pushNotificationVM: pushNotificationVM, themeController: themeController)
                        .ignoresSafeArea(.all)
                        .edgesIgnoringSafeArea(.bottom)
                        .tag("message")
                    //                    .onAppear{ hideKeyboard()}
                    EventHome(EventMatchedGeometryEffect: .constant(""), eventModel: eventModel, friendsDictionary: timelinePosts.friendsDictionary, CreateEventMatchedGeometry: "", currentTab: currentTab, pushNotificationVM: pushNotificationVM, themeController: themeController)
                        .tag("squareshape.split.2x2")
                    //                    .onAppear{ hideKeyboard()}
                }
                // Fallback on earlier versions
            }
        }
    }
    var arcMenu : some View {
        
#if os(iOS)
        let arcMenu = ArcMenu2(isNavigationMenuShowing: $isNavigationMenuShowing,
                               NotificationstMatchedGeometry: $NotificationstMatchedGeometry,
                               AllFriendsMatchedGeometry: $AllFriendsMatchedGeometry,
                               AllMessagesMatchedGeometry: $AllMessagesMatchedGeometry,
                               NewPostMatchedGeometry: $NewPostMatchedGeometry,
                               newRequest: $newFriendRequest.newRequest )
#elseif os(macOS)
        let arcMenu = ArcMenu(isNavigationMenuShowing: $isNavigationMenuShowing,
                              NotificationstMatchedGeometry: $NotificationstMatchedGeometry,
                              AllFriendsMatchedGeometry: $AllFriendsMatchedGeometry,
                              AllMessagesMatchedGeometry: $AllMessagesMatchedGeometry,
                              NewPostMatchedGeometry: $NewPostMatchedGeometry,
                              newRequest: $newFriendRequest.newRequest,
                              selectedTab : $selectedTab)
#endif
        return arcMenu
            .environmentObject(allChats)
            .environmentObject(notifications)
        //            .padding(.trailing, -15)
        //            .padding(.bottom, iOS15 ? -20 : 10)
        //            .padding(.bottom, iOS15 && screenHeight < 800 ? 30 : 0)
            .offset(x: 75, y: screenHeight < 800 ? 60 : 25)
    }
    
    func deletePost(){
        if let post = deletedPost{
            timelinePosts.delete(post: post)
        }
        isDeletePostAlertShowing = false
        print("Deleting...")
        
    }
    func dismissOpenedPost(){
        postVM.dismissOpenedPost()
    }
    
}

struct TabBarButton: View {
    var image: String
    @ObservedObject var currentTab: CurrentTab
    @State var isSystemImage = false
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController
    var body: some View {
        
        ZStack {
            if isSystemImage {
                Image(systemName: image)
                    .font(.title2)
                    .foregroundColor(currentTab.currentTab == image ? themeController.theme.accent : .white)
            } else {
                Image(currentTab.currentTab == image ? (colorScheme == .light ? "eventLight" : "eventDark") : "eventWhite")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
        }
        .offset(y: iOS15 && screenHeight < 700 ? 0 : -10)
        .frame(width: screenWidth/5, height: 66)
        .contentShape(Rectangle())
        .onTapGesture {
            currentTab.changeTab(tab: image)
        }
    }
}

class CurrentTab: ObservableObject {
    @Published var currentTab = "house.fill"
    @Published var showPost = false
    @Published var friendID = String()
    @Published var showConversation = false
    func changeTab(tab: String) {
        self.currentTab = tab
    }
    func openConversation(id: String) {
        withAnimation {
            self.currentTab = "message"
            self.friendID = id
            self.showConversation = true
        }
    }
    func openPost() {
        withAnimation {
            showPost = true
        }
    }
    func hidePost() {
        withAnimation {
            showPost = false
        }
    }
}


struct HomeTabView: View {
    @ObservedObject var allChats: AllMessagesOO
    @State var emptyStringBinding = ""
    @State var selectedTab = "home"
    @Binding var newMedia: SelectedMedia?
    @StateObject var pushNotificationVM : PushNotificationVM
//    @ObservedObject var pushNotificationVM: PushNotificationVM
    @Binding var signOut: Bool
    @Binding var NewPostMatchedGeometry: String
    @AppStorage("tutorialNumber") var tutorialNumber : Int = 0
    @ObservedObject var timelinePosts: TimelinePostsOO
    @State var notificationInfo: NotificationBanner?
    @State var selectedGroupChat : ChatModel?
    @ObservedObject var eventModel: EventModelOO
    @ObservedObject var currentTab: CurrentTab
    @ObservedObject var myTags: MyTagsOO
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack (alignment: .top) {

            Home2(NewPostMatchedGeometry: $NewPostMatchedGeometry, signOut: $signOut, allChats: allChats, newMedia: $newMedia, suggestedFriends: SuggestedFriendsOO(friendsDictionary: timelinePosts.friendsDictionary), notificationInfo: $notificationInfo, selectedGroupChat: $selectedGroupChat, pushNotificationVM: pushNotificationVM, eventModel: eventModel, currentTab: currentTab, themeController: themeController)
 
                        .highPriorityGesture(tutorialNumber < 6 && tutorialNumber > 0  ? DragGesture() : nil)
                        .transition(.slide)
                        .tag("home")

//            PushNotificationView(pushNotificationVM: pushNotificationVM, currentTab: currentTab, myTags: myTags)
            EmptyPushNotificationView(pushNotificationVM: pushNotificationVM, currentTab: currentTab)
                NotificationBannerControllerView(friendsDictionary: timelinePosts.friendsDictionary, pnBannerViewModel: PNBannerViewModel(allMessagesOO: allChats, timelinePosts: timelinePosts, eventModel: eventModel), pushNotificationVM: pushNotificationVM, themeController: themeController)
            }
            .edgesIgnoringSafeArea(.all)
//            .environmentObject(pushNotificationVM)
 
            .onChange(of: selectedTab) { tab in
                if tab == "allMessages"{
                    allChats.markAllUnreadMessagesRead()
                }
            }
    }
     
}

struct NewUserTimeline: View {
    @State var mentionCount = [String]()
    @State var StrangerProfileMatchedGeometry = ""
    @State var StrangerProfileSelectedItem: Person!
    @StateObject var shareActivity = ShareActivityOO()
    @ObservedObject var timelinePosts : TimelinePostsOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @StateObject var soundManager = SoundManager()
    @StateObject var textBindingManager = TextBindingManager(limit: 420)
    @State var selectedMedia: SelectedMedia?
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var ShowPhotoImagePicker = false
    @StateObject var keyboard = KeyboardOO()
    @Binding var audioAlert: Bool
    @Binding var cameraAlert: Bool
    @State var buttonAlertType: ButtonAlertType = .none
    @ObservedObject var themeController: ThemeController
    @State var FriendProfileMatchedGeometry: String = ""
    @Binding var hasCreatedAMoment: Bool
    @Binding var newProfilePhoto: NewMedia?
//    @ObservedObject var themeController: ThemeController
//    @State var buttonAlertType: ButtonAlertType = .audioMessage
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
            }
            .introspectScrollView{ scrollView in
                
#if os(iOS)
                scrollView.keyboardDismissMode = .interactive
#endif
            }
            .background(themeController.theme.primary.ignoresSafeArea())
            .ignoresSafeArea(edges: .bottom)
            .padding(.bottom, -10)
            .overlay(
            VStack (alignment: .leading) {
//                if keyboard.value == 0 {
                ZStack {
                    TitleHeader(title: "") {
                    }
                    .hidden()
                    Text("GET STARTED")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.leading, 5)
                        .padding(.horizontal)
                }
//                }
                .padding(.bottom, screenHeight > 870 ? screenHeight/89.6 : 0)
                .padding(.bottom, 8)
                    VStack (alignment: .trailing) {
                        SearchForStranger(StrangerProfileMatchedGeometry: $StrangerProfileMatchedGeometry, StrangerProfileSelectedItem: $StrangerProfileSelectedItem, themeController: themeController, friendsDictionary: friendsDictionary, FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry)
                        
                        Button(action: {
                            shareActivity.getDynamicLink(isAnEvent: false, eventID: "")
                        }){
                            Text("🔗  speakEZ.co/\(String((friendsDictionary.friendsDictionary[currentUserID ?? ""]?.username ?? "").dropFirst()))")
                                .foregroundColor(Color.mainColor.opacity(0.3))
                                .font(.headline)
                        }
                        .padding(.leading, 21)
                        .padding(.horizontal)
                        .padding(.top, iOS16 ? 5 : -6)
                        .padding(.bottom, 3)
                    }

                ZStack(alignment: .bottomTrailing) {
                    NewMomentBody(friendsDictionary: friendsDictionary, textBindingManager: textBindingManager, soundManager: soundManager, selectedMedia: $selectedMedia, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, mentionCount: $mentionCount, isFromNewUserTimeline: true, themeController: themeController, newProfilePhoto: $newProfilePhoto)
                    HStack (spacing: 14) {
                        SendMomentControls(soundManager: soundManager, ShowPhotoImagePicker: $ShowPhotoImagePicker, selectedMedia: $selectedMedia, isFromNewUserTimeline: true, audioAlert: $audioAlert, buttonAlertType: $buttonAlertType, cameraAlert: $cameraAlert, themeController: themeController)
                        SendMomentButton(themeController: themeController) {
                            
                            if textBindingManager.text.trimWhitespacesAndNewlines().isNotEmpty || selectedMedia != nil {
                                if !mentionCount.isEmpty {
                                    for item in mentionCount {
                                        if textBindingManager.text.contains(friendsDictionary.friendsDictionary[item]?.username ?? "") {
                                        } else {
                                            if let firstIndex = mentionCount.firstIndex(of: item) {
                                                mentionCount.remove(at: firstIndex)
                                            }
                                        }
                                    }
                                    
                                }
                                timelinePosts.sendNewPost(content: textBindingManager.text, selectedMedia: selectedMedia, mentionedIDs: mentionCount, tags: [String]())
                            }
                            textBindingManager.clearText()
                            hideKeyboard()
                            selectedMedia = nil
                            hasCreatedAMoment = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                mentionCount.removeAll()
                                mentionCount.append("")
                            }
                            
                        }
                    }
                    .offset(y: 30)
                }
                .padding(.horizontal)
                
//                .padding(.top, 16)
                Spacer()
            }
            )
            .padding(.top, iOS15 == true && iOS16 != true ? screenHeight < 870 ? 53 : 48 : 0)
            .padding(.top, iOS16 ? screenHeight < 930 ? 53 : 63 : 0)
            .padding(.top, iOS15 ? 0 : 53)
            .blur(radius: buttonAlertType != .none ? 10 : 0)
            .disabled(buttonAlertType != .none ? true : false)

            if StrangerProfileMatchedGeometry != "" {
                StrangerProfileTabView(ProfileMatchedGeometry: $StrangerProfileMatchedGeometry, person: StrangerProfileSelectedItem, id: StrangerProfileSelectedItem.id)
            }
            if FriendProfileMatchedGeometry != "" {
                FriendProfileHomeTabView(FriendProfileMatchedGeometry: $FriendProfileMatchedGeometry, id: FriendProfileMatchedGeometry, isFromOpenedPost: true, themeController: themeController)
            }
            if OpenedPhotoMatchedGeometry != "" {
                OpenedRegularPhoto(photo: selectedMedia?.image, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry)
            }
            if let _ = shareActivity.shareURL {
                ActivityViewController(shareURL: $shareActivity.shareURL )
            }
            if buttonAlertType != .none {
                ButtonTapAlertController(buttonAlertType: $buttonAlertType, themeController: themeController)
            }
        }
        .presentMediaPicker(isPresented: $ShowPhotoImagePicker, selectedMedia: $selectedMedia, text: $textBindingManager.text, parentView: .message)


        .frame(width: screenWidth, height: screenHeight-66, alignment: .top)
        .background(themeController.theme.primary.ignoresSafeArea())
    }
}


#if os(iOS)
let screenWidth = UIScreen.width
let screenHeight = UIScreen.height
#endif


struct ButtonTapAlertController: View {
    @Binding var buttonAlertType: ButtonAlertType
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            switch buttonAlertType {
            case .audioMessage:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Audio makes moments more personal.",
                             "Tap the “audiowave” button to start recording and again to stop."], themeController: themeController)
            case .audioComment:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Your friends want to hear your voice.",
                             "Tap the “audiowave” button to start recording and again to stop."], themeController: themeController)
            case .camera:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Every picture tells a story.",
                             "Tap the “camera” button to include a photo or video in your moment."], themeController: themeController)
            case .cameraComment:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Comments and photos go hand-in-hand.",
                             "Tap the “camera” button to include a photo or video in your comment."], themeController: themeController)
            case .createLock:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 3,
                textPrompt: ["Locks add additional privacy to your moments.",
                             "Only friends within your “lock” can see your locked moment.",
                             "There is no limit to the number of locks you can create."], themeController: themeController)
            case .lockedMoment:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 4,
                textPrompt: ["Unlocked moments are signified by an “opened lock”.",
                             "This means the moment can be seen by all the author’s friends.",
                             "Locked moments are signified by a “lock” symbol.",
                             "This means only a select few of the author’s friends may see the moment."], themeController: themeController)
            case .activeMoments:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Active moments rise to the top of the timeline.",
                             "Commenting on a moment pushes it to the top of everyone’s timeline."], themeController: themeController)
            case .notifications:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Notifications shouldn’t be overwhelming.",
                             "Pause a moment’s notifications by holding down its text."], themeController: themeController)
            case .likedMoment:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 1,
                               textPrompt: ["See who liked a Moment by holding down the 💝 button."], themeController: themeController)
            case .friendRequests:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Remember, you only have 150 seats in your speakeasy.",
                            "But you have the flexibility and power to escort individuals out."], themeController: themeController)
            case .likeOrComment:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Moments you've liked will have a colored heart.",
                             "And moments you've commented on will have a colored bubble."], themeController: themeController)
            case .anonymousMode:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Anonymous Mode lets you be incognito to non-friends.",
                             "You can turn this setting on in Edit Profile."], themeController: themeController)
            case .messagesCamera:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Send a single photo to multiple friends, separately.",
                             "Selected recipients will receive your media in separate conversations."], themeController: themeController)
            case .themes:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Change the colorway of your app.",
                             "App themes can be selected by pressing the pencil icon."], themeController: themeController)
            case .addAFriend:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Your speakeasy's capacity is 150 people.",
                             "Adding a friend gives them access to your moments and vice versa."], themeController: themeController)
            case .firstMoment:
                ButtonTapAlert(buttonAlertType: $buttonAlertType, numberOfSlides: 2,
                textPrompt: ["Your speakeasy is made up of Moments.",
                             "Create a moment to unlock your timeline. Only friends can see your moments."], themeController: themeController)
            case .none:
                EmptyView()
            }
        }
    }
}

enum ButtonAlertType {
    case audioMessage
    case camera
    case createLock
    case activeMoments
    case notifications
    case likedMoment
    case friendRequests
    case likeOrComment
    case audioComment
    case cameraComment
    case lockedMoment
    case anonymousMode
    case messagesCamera
    case themes
    case addAFriend
    case firstMoment
    case none
}

struct ButtonTapAlert: View {
    @Binding var buttonAlertType: ButtonAlertType
    @State var slideNumber = 1
    var numberOfSlides = 2
    @State var textPrompt = [String]()
    @ObservedObject var themeController: ThemeController
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text(textPrompt[slideNumber-1])
                    .font(.system(size: slideNumber > 1 ? (numberOfSlides != 4 ? 22 : (slideNumber == 3 ? 28 : 22)) : 28, weight: .bold))
//                    .font(.system(size: slideNumber > 1 ? 22 : 28, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .padding(.top, 6)
                    .padding(.horizontal, 10)
                    .offset(y: buttonAlertType == .anonymousMode && slideNumber == 1 ? -10 : 0)
            }
            .frame(width: 330, height: 144, alignment: .topLeading)
            VStack {
                ZStack {
                    switch numberOfSlides {
                    case 1:
                        Button(action: {
                            withAnimation(.linear(duration: 0.2)) {
                                buttonAlertType = .none
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif

                            }
                        }) {
                            Text("DONE")
                                .foregroundColor(Color.mainColorInverse)
                                .font(.headline)
                        }
                    case 2:
                        ZStack {
                            switch slideNumber {
                            case 2:
                                Button(action: {
                                    withAnimation(.linear(duration: 0.2)) {
                                        buttonAlertType = .none
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                                    }
                                }) {
                                    Text("DONE")
                                        .foregroundColor(Color.white)
                                        .font(.headline)
                                }
                            default:
                                Button(action: {
                                    slideNumber = 2
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                                }) {
                                    Text("NEXT")
                                        .foregroundColor(Color.white)
                                        .font(.headline)
                                }
                            }
                        }
                    case 3:
                        ZStack {
                            switch slideNumber {
                            case 3:
                                Button(action: {
                                    withAnimation(.linear(duration: 0.2)) {
                                        buttonAlertType = .none
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                                    }
                                }) {
                                    Text("DONE")
                                        .foregroundColor(Color.mainColorInverse)
                                        .font(.headline)
                                }
                            case 2:
                                Button(action: {
                                    withAnimation {
                                        slideNumber = 3
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                                    }
                                }) {
                                    Text("NEXT")
                                        .foregroundColor(Color.mainColorInverse)
                                        .font(.headline)
                                }
                            default:
                                Button(action: {
                                    slideNumber = 2
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                                }) {
                                    Text("NEXT")
                                        .foregroundColor(Color.mainColorInverse)
                                        .font(.headline)
                                }
                            }
                        }
                    case 4:
                        ZStack {
                            switch slideNumber {
                            case 4:
                                Button(action: {
                                    withAnimation(.linear(duration: 0.2)) {
                                        buttonAlertType = .none
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                                    }
                                }) {
                                    Text("DONE")
                                        .foregroundColor(Color.mainColorInverse)
                                        .font(.headline)
                                }
                            case 3:
                                Button(action: {
                                    withAnimation(.linear(duration: 0.2)) {
                                        slideNumber = 4
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                                    }
                                }) {
                                    Text("NEXT")
                                        .foregroundColor(Color.mainColorInverse)
                                        .font(.headline)
                                }
                            case 2:
                                Button(action: {
                                    withAnimation {
                                        slideNumber = 3
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                                    }
                                }) {
                                    Text("NEXT")
                                        .foregroundColor(Color.mainColorInverse)
                                        .font(.headline)
                                }
                            default:
                                Button(action: {
                                    slideNumber = 2
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                                }) {
                                    Text("NEXT")
                                        .foregroundColor(Color.mainColorInverse)
                                        .font(.headline)
                                }
                            }
                        }
                    default:
                        Text("")
                    }
                }
                .frame(width: 88, height: 46)
                .background(themeController.theme.accent.opacity(0.8))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.mainColorInverse, lineWidth: 2)
                )
            }
            .frame(width: 330, height: 106)
            .background(themeController.theme.accent.opacity(0.9))
        }
        .frame(width: 330, height: 250)
        .background(themeController.theme.accent.opacity(buttonAlertType == .anonymousMode ? 0.9 : 0.8))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.mainColorInverse, lineWidth: 2)
                .shadow(color: Color.mainColorInverse.opacity(0.25), radius: 4)
        )
    }
}


