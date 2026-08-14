//
//  NewMoment2.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 10/3/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import Combine

struct NewMoment: View {
    @Binding var NewPostMatchedGeometry: String
    @State var OpenedPhotoMatchedGeometry: String = ""
    @State var LockMatchedGeometry = ""
    @State var OpenedLockMatchedGeometry = ""
    @Binding var selectedMedia: SelectedMedia?
    @StateObject var soundManager = SoundManager()
    @StateObject var myTags = MyTagsOO()
    @ObservedObject var timelinePosts : TimelinePostsOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @State var ShowPhotoImagePicker = false
    @StateObject var textBindingManager = TextBindingManager(limit: 420)
    @State var tagIDs = [String]()
    @State var mentionCount = [String]()
    @State var isShowingMentions = false
    @State var show: Bool = false
    @ObservedObject var currentTab: CurrentTab
    @Binding var audioAlert: Bool
    @State var buttonAlertType: ButtonAlertType = .none
    @Binding var cameraAlert: Bool
    @AppStorage("createLockAlert") var createLockAlert : Bool = false
    @ObservedObject var themeController: ThemeController
    @Binding var hasCreatedAMoment: Bool
    @Binding var newProfilePhoto: NewMedia?
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
            .overlay (
                VStack (spacing: 10) {
                    HStack (spacing: 16) {
                        TitleHeader(title: "Moment") {
//                            NewPostMatchedGeometry = "house.fill"
                            currentTab.changeTab(tab: "house.fill")
                        }
                        Spacer()
                    }
                    ZStack (alignment: .topTrailing) {
                        ZStack (alignment: .bottomTrailing) {
                            HStack (alignment: .top, spacing: 5) {
                                NewMomentBody(friendsDictionary: friendsDictionary, textBindingManager: textBindingManager, soundManager: soundManager, selectedMedia: $selectedMedia, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, mentionCount: $mentionCount, themeController: themeController, newProfilePhoto: $newProfilePhoto)
                                SendMomentControls(soundManager: soundManager, ShowPhotoImagePicker: $ShowPhotoImagePicker, selectedMedia: $selectedMedia, audioAlert: $audioAlert, buttonAlertType: $buttonAlertType, cameraAlert: $cameraAlert, themeController: themeController)
                                    .offset(y: 28)
                            }
                            .padding(.horizontal, 3)
                            Button(action: {
                                if createLockAlert != false {
                                withAnimation {
                                        if tagIDs.isEmpty {
                                            LockMatchedGeometry = "0"
                                        } else {
                                            OpenedLockMatchedGeometry = tagIDs.first ?? ""
                                        }
                                        show.toggle()
                                        hideKeyboard()
                                    }
                                } else {
                                    withAnimation {
                                        hideKeyboard()
                                        buttonAlertType = .createLock
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            createLockAlert = true
                                        }
                                    }
                                }
                            }) {
                                ZStack {
                                    if tagIDs.isEmpty {
                                        Image(systemName: "lock.open.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(Color.white)
                                    } else {
                                        ZStack {
                                            Image(systemName: "lock.fill")
                                                .font(.largeTitle)
                                                .foregroundColor(Color.black)
                                                .offset(y: -7)
                                        }
                                    }
                                }
                            }
                            .offset(x: -46, y: 20)
                        }
                        
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
                                timelinePosts.sendNewPost(content: textBindingManager.text, selectedMedia: selectedMedia, mentionedIDs: mentionCount, tags: tagIDs)
                            }
                            textBindingManager.clearText()
                            isShowingMentions = false
                            hideKeyboard()
                            withAnimation {
//                                NewPostMatchedGeometry = "house.fill"
                                currentTab.changeTab(tab: "house.fill")
                            }
                            selectedMedia = nil
                            hasCreatedAMoment = true
                            tagIDs.removeAll()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                mentionCount.removeAll()
                                mentionCount.append("")
                            }
                            
                        }
                        .offset(x: 3, y: -55)
                    }
                    .padding(.top, 8)
                    Spacer()
                }
            )
            .blur(radius: buttonAlertType != .none ? 10 : 0)
            .disabled(buttonAlertType != .none ? true : false)

            if OpenedPhotoMatchedGeometry != "" {
                OpenedRegularPhoto(photo: selectedMedia?.image, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry)
            }
            if buttonAlertType != .none {
                ButtonTapAlertController(buttonAlertType: $buttonAlertType, themeController: themeController) 
            }
        }
        .presentMediaPicker(isPresented: $ShowPhotoImagePicker, selectedMedia: $selectedMedia, text: $textBindingManager.text, parentView: .message)
        .fullSwipePop(show: $show) {
            ZStack {
                if LockMatchedGeometry != "" {
                    TagHome(TagHomeNavigationMatchedGeometry: $LockMatchedGeometry,
                            tagIDs: $tagIDs,
                            tags: TagsObservable(tagsDictionary: myTags),
                            myTags: myTags,
                            selectedTagName: $tagIDs, show: $show, themeController: themeController)
                } else if OpenedLockMatchedGeometry != "" {
                    OpenedTag2(tagID: OpenedLockMatchedGeometry, tagIDs: $tagIDs, OpenedTagToNewPostNavigation: .constant(""), OpenedTagToTagHomeNavigation: .constant(""), myTags: myTags, tagFriends: TagFriendsOO(tagID: OpenedLockMatchedGeometry), show: $show, themeController: themeController)
                }
            }
        }
    }
}

struct SendMomentButton: View {
    @ObservedObject var themeController: ThemeController
    var action: () -> Void
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                Circle()
                    .frame(width: 64, height: 64)
                    .foregroundColor(themeController.theme.accent)
                    .shadow(color: themeController.theme.accent, radius: 10)
                Image(systemName: "paperplane")
                    .font(.title)
                    .foregroundColor(Color.white)
            }
        }
    }
}

struct SendMomentControls: View {
    @ObservedObject var soundManager: SoundManager
    @Binding var ShowPhotoImagePicker: Bool
    @Binding var selectedMedia: SelectedMedia?
    @State var isFromNewUserTimeline = false
    @Binding var audioAlert: Bool
    @Binding var buttonAlertType: ButtonAlertType
    @Binding var cameraAlert: Bool
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            if isFromNewUserTimeline {
                HStack(spacing: 8) {
                    
                    RecordNewAudioMomentButton2(soundManager: soundManager, selectedMedia: $selectedMedia, audioAlert: $audioAlert, buttonAlertType: $buttonAlertType, themeController: themeController)
                    
                    SendMomentControlButton(imageName: "camera", themeController: themeController) {
                        if cameraAlert != false {
                            ShowPhotoImagePicker = true
                        } else {
                            withAnimation() {
                                buttonAlertType = .camera
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    cameraAlert = true
                                }
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    
                    RecordNewAudioMomentButton2(soundManager: soundManager, selectedMedia: $selectedMedia, audioAlert: $audioAlert, buttonAlertType: $buttonAlertType, isFromNewUserTimeline: false, themeController: themeController)
                    
                    SendMomentControlButton(imageName: "camera", themeController: themeController) {
                        if cameraAlert != false {
                            ShowPhotoImagePicker = true
                        } else {
                            withAnimation() {
                                hideKeyboard()
                                buttonAlertType = .camera
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    cameraAlert = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SendMomentControlButton: View {
    var imageName = "lock"
    @ObservedObject var themeController: ThemeController
    var action: () -> Void
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(themeController.theme.accent)
                Image(systemName: imageName)
                    .font(.title3)
                    .foregroundColor(Color.white)
            }
        }
    }
}
struct NewMomentBody: View {
    @State var textViewMaxHeight: CGFloat = screenWidth/1.3
    @ObservedObject var friendsDictionary : FriendsDictionary
    @ObservedObject var textBindingManager : TextBindingManager
    @ObservedObject var soundManager: SoundManager
    @Binding var selectedMedia: SelectedMedia?
    @Binding var OpenedPhotoMatchedGeometry: String
    @Binding var mentionCount: [String]
    @State var isShowingMentions = false
    @State var isFromNewUserTimeline = false
    @ObservedObject var themeController: ThemeController
    @StateObject var functions = EditProfileFunction()
    @Binding var newProfilePhoto: NewMedia?
    @State var isShowingImagePicker = false
    @State var isChangePhotoAlertShowing = false
    var body: some View {
        EmptyView()
            .frame(width: isFromNewUserTimeline ? screenWidth - 32 : screenWidth/1.1662, height: screenWidth/1.189)
            .overlay(
                ZStack (alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 23)
                        .stroke(Color.mainColorInverse, lineWidth: 0.001)
                        .background(themeController.theme.secondary.cornerRadius(23))
                    ZStack (alignment: .bottomLeading) {
                        TextEditor(text: $textBindingManager.text)
                            .font(.subheadline.weight(.light))
                            .frame(width: screenWidth/1.18, height: (screenWidth/1.189 - 220))
                            .offset(x: -10)
                            .foregroundColor(Color.mainColorInverse.opacity(0.01))
                            .colorMultiply(.mainColorInverse.opacity(0.001))
                            .onReceive(Just(textBindingManager.text)) { text in
                                if text.contains("@") {
                                    isShowingMentions = true
                                } else {
                                    mentionCount.removeAll()
                                    isShowingMentions = false
                                }
                            }
                        //                        if let postImage = selectedMedia?.image  {
                        if let media = selectedMedia  {
                            ZStack(alignment: .topTrailing) {
                                if let video = media.newMedia?.videoUrl, let postImage = media.image {
                                    Image(uiImage: postImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 90, height: 107.7)
                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                                        .rotation3DEffect(.degrees(3), axis: (x: 0, y: 1, z: 0))
                                        .padding(.leading, 10)
                                        .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
                                        .onTapGesture {
                                            hideKeyboard()
                                        }
                                    RegularVideoThumbnailView(thumbnail: postImage, buttonSize: 40, selectedMedia: selectedMedia)
                                        .offset(x: -18, y: 32)
                                }
                                if media.newMedia?.videoUrl == nil {
                                    if let postImage = media.image  {
                                        
                                        Image(uiImage: postImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 90, height: 107.7)
                                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                                            .rotation3DEffect(.degrees(3), axis: (x: 0, y: 1, z: 0))
                                            .padding(.leading, 10)
                                            .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
                                            .onTapGesture {
                                                OpenedPhotoMatchedGeometry = "0"
                                                hideKeyboard()
                                            }
                                        
                                    }
                                }
                                if let audio = media.audioUrl {
                                    RecordedAudioMoment2(selectedMedia: $selectedMedia, soundManager: soundManager, themeController: themeController)
                                }
                                if media.audioUrl == nil {
                                    Button(action: {
                                        withAnimation {
                                            selectedMedia = nil
                                        }
                                    }){
                                        ZStack {
                                            Circle()
                                                .frame(width: 23, height: 23)
                                                .foregroundColor(Color.white)
                                                .overlay (
                                                    Circle()
                                                        .frame(width: 20, height: 20)
                                                        .foregroundColor(themeController.theme.primary)
                                                )
                                            Image(systemName: "xmark")
                                                .font(.caption)
                                                .foregroundColor(Color.white)
                                        }
                                    }
                                    .offset(x: 5, y: -5)
                                    
                                }
                            }
                            .offset(x: screenWidth/17 - 3, y: -screenWidth/33)
                            .offset(y: 5)
                        }
                        HStack (alignment: .top) {
                            VStack {
                                if let userImage = newProfilePhoto?.image {
                                    Image(uiImage: userImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 142, height: 170)
                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
                                        .rotation3DEffect(.degrees(3), axis: (x: 0, y: 1, z: 0))
                                        .padding(10)
                                        .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
                                        .onTapGesture {
//                                            isShowingImagePicker = true
                                            isChangePhotoAlertShowing = true
                                        }
                                } else {
                                            WebImage(url: friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? ""]?.profilePicLink)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 142, height: 170)
                                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
                                                .rotation3DEffect(.degrees(3), axis: (x: 0, y: 1, z: 0))
                                                .padding(10)
                                                .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
                                                .onTapGesture {
                                                    isChangePhotoAlertShowing = true
                                                }
                                        }
                                Text("\(textBindingManager.text.count) / 420")
                                    .font(.subheadline)
                                    .fontWeight(.light)
                                    .foregroundColor(textBindingManager.text.count < 419 ? themeController.theme.accent : .plumWeb)
                                    .offset(y: -12)
                            }
                            .presentMediaPicker(isPresented: $isShowingImagePicker, newMedia: $newProfilePhoto ,parentView: .userProfile)
                            .onChange(of: newProfilePhoto) { _ in
                                if let newPhoto = newProfilePhoto {
                                    let name = friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? ""]?.name
                                    let username = (friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? ""]?.username)!.dropFirst()
                                    let bio = friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? ""]?.bio ?? ""
                                    let uid = Auth.auth().currentUser?.uid ?? ""
                                    let photo = newPhoto.image
                                    let token = friendsDictionary.friendsDictionary[Auth.auth().currentUser?.uid ?? ""]?.token ?? ""
                                    
                                    let updatedProfile = UserProfile(name: name!, username: String(username), bio: bio, uid: uid, photo: photo, token: token)
                                    functions.updateProfile(updatedProfile: updatedProfile)
                                    print("USERNAME = \(String(username))")
                                }
                            }
                            ZStack (alignment: .topLeading) {
                                if textBindingManager.text.isEmpty {
                                    Text(isFromNewUserTimeline ? "Say hellooo!!" : "Keep it casual!")
                                        .foregroundColor(Color.black.opacity(0.3))
                                        .font(.subheadline)
                                        .fontWeight(.light)
                                        .offset(x: -2, y: 8)
                                }
                                
                                TextEditor(text: $textBindingManager.text)
                                    .font(.subheadline.weight(.light))
                                    .frame(width: screenWidth/2.25, height: screenWidth/1.3)
                                    .offset(x: -10)
                                    .foregroundColor(Color.mainColorInverse.opacity(0.01))
                                    .colorMultiply(.mainColorInverse.opacity(0.001))
                                    .onReceive(Just(textBindingManager.text)) { text in
                                        if text.contains("@") {
                                            isShowingMentions = true
                                        } else {
                                            mentionCount.removeAll()
                                            isShowingMentions = false
                                        }
                                    }
                                ExpandingTextView(text: $textBindingManager.text, maxHeight: $textViewMaxHeight, isFirstResponder: isFromNewUserTimeline ? false : true, isNewMoment: true)
                                    .offset(x: -10)
                                    .frame(width: screenWidth/2.25)
                                    .onReceive(Just(textBindingManager.text)) { text in
                                        if text.contains("@") {
                                            isShowingMentions = true
                                        } else {
                                            mentionCount.removeAll()
                                            isShowingMentions = false
                                        }
                                    }
                            }
                            .padding(.top, 20)
                        }
                        
                        
                    }
                    if isShowingMentions == true {
                        MentionAllFriendsView(friendsDictionary: friendsDictionary, content: $textBindingManager.text, mentionCount: $mentionCount, themeController: themeController)
                            .offset(x: 25, y: 100)
                    }
                }
            )
            .alert(isPresented: $isChangePhotoAlertShowing) {
                Alert(
                    title: Text("Change profile picture?"),
                    primaryButton: .destructive(Text("Yes")) {
                        isShowingImagePicker = true
                    },
                    secondaryButton: .cancel()
                )
            }
    }
}

struct MentionAllFriendsView: View {
    @ObservedObject var friendsDictionary: FriendsDictionary
    @Binding var content: String
    @Binding var mentionCount: [String]
    @ObservedObject var themeController: ThemeController
    var body: some View {
        let people = friendsDictionary.friendsDictionary.values.filter{$0.username.lowercased().contains(self.content.components(separatedBy: "@")[content.indicesOf(string: "@").count].lowercased())}
        if !people.isEmpty {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(people, id: \.self) { item in
                        MentionFriends(id: item.id)
                            .onTapGesture {
                                
                                let indicies = content.indicesOf(string: "@")
                                let endIndex = content.endIndex
                                let index = content.index(content.startIndex, offsetBy: indicies[indicies.endIndex-1])
                                content.removeSubrange(index..<endIndex)
                                content.append(item.username + " ")
                                mentionCount.append(item.id)
                                
                            }
                            .padding(.horizontal, 10)
                        Rectangle()
                            .frame(width: 293, height: 2)
                            .foregroundColor(Color.mainColorInverse)
                    }
                }
                .background(themeController.theme.accent
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .padding(.vertical, -10)
                )
                .padding(.top, 2)
                .padding(.horizontal, 2)
                .background(Color.mainColorInverse
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .padding(.vertical, -10)
                )
                
                
                .padding(.top, 20)
            }
            .contentShape(Rectangle())
            .frame(width: 300, height: 300)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        }
    }
}


struct RecordedAudioMoment2 : View {
    @Binding var selectedMedia: SelectedMedia?
    @StateObject private var audioPlayerVM: RecordedAudioPlayerVM = RecordedAudioPlayerVM()
    @ObservedObject var soundManager: SoundManager
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var themeController: ThemeController
    var body: some View {
            ZStack {
                Rectangle()
                    .frame(width: 90, height: 107.7)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                    .rotation3DEffect(.degrees(3), axis: (x: 0, y: 1, z: 0))
                    .padding(.leading, 10)
                    .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
                    .foregroundColor(themeController.theme.primary
                    )
                Button(action: {
                    audioPlayerVM.playRecordingIfNotPlaying(audioUrl: selectedMedia?.audioUrl)
                }){
                    ZStack {
//                        Circle()
//                            .frame(width: 60 - 10, height: 60 - 10)
//                            .foregroundColor(Color.mainColorInverse.opacity(0.6))
                        if audioPlayerVM.playRecording {
                            AnimatedWaveformView(color: .white, renderingMode: .hierarchical, animated: true, doesHaveOutterRing: false)
                                .frame(width: 70, height: 70)
                                .scaledToFit()
                        } else {
                            AnimatedWaveformView(color: .white, renderingMode: .hierarchical, animated: false, doesHaveOutterRing: false)
                                .frame(width: 70, height: 70)
                                .scaledToFit()
                        }
                    }
                }.disabled(soundManager.isRecording)
                    .offset(x: 5)
                Button(action: {
                    withAnimation {
                    audioPlayerVM.stopAndDelete(audioDirURL:  selectedMedia?.audioUrl)
                    selectedMedia = nil
                    }
                }) {
                    ZStack {
                        Circle()
                            .frame(width: 23, height: 23)
                            .foregroundColor(Color.white)
                            .overlay (
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(themeController.theme.primary)
                            )
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundColor(Color.white)
                    }

                }
                .buttonStyle(.borderless)
                .offset(x: 45, y: -50)
            }
            .onAppear() {
                audioPlayerVM.playRecordingIfNotPlaying(audioUrl: selectedMedia?.audioUrl)
            }
//            .offset(x: 20, y: -60)
//            Spacer()

    }
}

struct RecordNewAudioMomentButton2 : View {
    @StateObject var soundManager = SoundManager()
    @Binding var selectedMedia : SelectedMedia?
    @Environment(\.colorScheme) var colorScheme
    @State var isFromMessages = true
    @Binding var audioAlert: Bool
    @Binding var buttonAlertType: ButtonAlertType
    @State var isFromNewUserTimeline = true
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(soundManager.isRecording ? .white : themeController.theme.accent)
                .onTapGesture {
                    if soundManager.isRecording {
                        withAnimation {
    #if os(iOS)
            let impactLight = UIImpactFeedbackGenerator(style: .soft)
                            impactLight.impactOccurred()
    #endif
                            soundManager.stopRecorder()
                        }
                    } else {
                        withAnimation {
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                            if audioAlert != false {
                                selectedMedia?.newMedia = nil
                                selectedMedia?.deleteCacheOfSelectedMediaIfAny()
                                soundManager.recordAudio()
                            } else {
                                withAnimation {
                                    buttonAlertType = .audioMessage
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        audioAlert = true
                                    }
                                    if isFromNewUserTimeline != true {
                                        hideKeyboard()
                                    }
                                }
                            }
                        }
                    }
                }
            if soundManager.isRecording {
                AnimatedWaveformView(color: .black, animated: true, doesHaveOutterRing: false)
                .frame(width: 40, height: 40)
                .onTapGesture {
                    withAnimation {
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                        soundManager.stopRecorder()
                    }
                }
            } else {
                AnimatedWaveformView(color: .white, animated: false, doesHaveOutterRing: false)
                    .frame(width: 40, height: 40)
                    .onTapGesture {
                        withAnimation {
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                            if audioAlert != false {
                                selectedMedia?.newMedia = nil
                                selectedMedia?.deleteCacheOfSelectedMediaIfAny()
                                soundManager.recordAudio()
                            } else {
                                withAnimation {
                                    buttonAlertType = .audioMessage
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        audioAlert = true
                                    }
                                }
                            }
                        }
                    }
            }
    }.onReceive(soundManager.recoredAudioURLPublisher) { recordedAudioURL in
                if let recordedAudioURL = recordedAudioURL{
                    selectedMedia = SelectedMedia(audioUrl: recordedAudioURL)
                }else if let _ = selectedMedia?.audioUrl {
                    selectedMedia = nil
                }
            }
    }
}
