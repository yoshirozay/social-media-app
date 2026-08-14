//
//  NewMoment.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/13/22.
//

import SwiftUI
import Combine
import SDWebImageSwiftUI

struct EditMoment: View {
    @State var content: String = ""
     let postData: PostModel
    @State var keyboard = KeyboardOO()
    @State var textViewMaxHeight: CGFloat = screenHeight/2 - 65
 
    @State var ShowPhotoImagePicker = false
    @StateObject var myTags = MyTagsOO()
    @State var tagIDs: [String]
    @State var isShowingMentions = false
    @State var mentionCount = [""]
    @State var TagHomeNavigationMatchedGeometry = ""
    @State var OpenedTagNavigation = ""
    @Environment(\.colorScheme) var colorScheme
    @State var emptyStringBinding = ""
    @EnvironmentObject var timelinePosts : TimelinePostsOO
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @Binding var showUpdatePost : PostModel?
    @State var oldPostMedia : OldPostMedia
    @State var selectedMedia: SelectedMedia?
    @EnvironmentObject var alert : AlertOO
    @StateObject var soundManager = SoundManager()
    var textScrollView : some View{
            ScrollView(showsIndicators: false) {
                
                ZStack (alignment: .top) {
                    if content.isEmpty {
                        
                        TextField("Share a moment!",text : .constant(""))
                            .foregroundColor(Color.mainColor.opacity(0.8))
                            .font(.title3)
                            .padding(.leading,5)
//                                        .animation(.none)
                            .offset(x: 2, y: 8)
#if os(macOS)
                            .textFieldStyle(.plain)
#endif
                    }
                    ExpandingTextView(text: $content, maxHeight: $textViewMaxHeight, isFirstResponder: true, isNewMoment: true)
                        .offset(x: 4)
                        .frame(width: screenWidth - 20)
                        .onReceive(Just(content)) { content in
                            if content.contains("@") {
                                isShowingMentions = true
                            } else {
                                mentionCount.removeAll()
                                isShowingMentions = false
                            }
                        }
                    TextEditor(text: $content)
                        .font(.title2)
                        .onReceive(Just(content)) { content in
                            if content.contains("@") {
                                isShowingMentions = true
                            } else {
                                mentionCount.removeAll()
                                isShowingMentions = false
                            }
                        }
                        .offset(x: 2)
                    
                        .frame(width: screenWidth - 20, height: screenHeight/3 - 65)
                        .foregroundColor(Color.mainColor.opacity(0.01))
                }
                
                
            }
                .opacity(0.5)
                .frame(width: screenWidth - 30, height: screenHeight/3 - 60)
                .background(Color.mainColorInverse.opacity(0.8)
                           )
                .cornerRadius(10, corners: [.topLeft, .topRight])
                .offset(y: -25)
                .transaction { transaction in
                    transaction.animation = nil
                }
    }
   
    var mediaView : some View{
        HStack(alignment: .bottom) {
            if let selectedMedia = selectedMedia{
                if let newMedia = selectedMedia.newMedia {
                    ZStack{
                        SelectedImageView {
                            Image(uiImage: newMedia.image).resizable()
                        } action: {
                            unSelectMedia()
                        }
                        if let videoUrl = newMedia.videoUrl  {
                            PostVideoThumbnailView(VideoThumbnailVM : VideoThumbnailVM(videoDirURL: videoUrl), buttonSize: 20)
                                .offset(x: 20, y: -60)
                        }
                    }
                } else if let _ = selectedMedia.audioUrl {
                    RecordedEditAudioMoment(soundManager: soundManager, selectedMedia: $selectedMedia, oldPostMedia: $oldPostMedia, isNewAudio: true)
                }
            } else if !oldPostMedia.isEmpty {
                if let photoURL = (oldPostMedia.photoLink ?? oldPostMedia.thumbnailUrl) {
                    ZStack {
                        SelectedImageView {
                            WebImage(url: photoURL).resizable()
                        } action: {
                            unSelectMedia()
                        }
                        oldPostMedia.videoUrl.map { videoUrl in
                            PostVideoThumbnailView(VideoThumbnailVM : VideoThumbnailVM(videoFirebaseURL : videoUrl), buttonSize: 20)
                                .offset(x: 20, y: -60)
                        }
                    }
                } else if let _ = oldPostMedia.audioUrl {
                    RecordedEditAudioMoment(soundManager: soundManager, selectedMedia: $selectedMedia, oldPostMedia: $oldPostMedia)
                }
            }
        } 
    }
    func unSelectMedia(){
        oldPostMedia.empty()
        selectedMedia = nil
    }
    
    var tagScrollView: some View{
        HStack(alignment: .bottom){
        if tagIDs.isNotEmpty {
#if os(iOS)
            let width = selectedMedia?.image == nil ? screenWidth  - 85 : screenWidth - 170
#elseif os(macOS)
            let width = selectedMedia?.image == nil ? screenWidth - 20 : screenWidth - 170
#endif
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack (spacing: 5) {
                    ForEach(tagIDs, id: \.self) { item in
                        if item != "" {
                            ZStack {
                                LinearGradient(gradient: .init(colors:  [.speakerPurple.opacity(0.4), .speakerPink.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                                    .frame(width: 80, height: 85)
                                    .clipShape(Hexagon())
                                
                                LinearGradient(gradient: .init(colors: [Color.mainColorInverse.opacity(0.65), Color.mainColorInverse.opacity(0.65)]), startPoint: .top, endPoint: .bottom)
                                    .frame(width: 75, height: 80)
                                    .clipShape(Hexagon())
                                LinearGradient(gradient: .init(colors: colorScheme == .light ? [Color.speakerPink.opacity(0.1), Color.blue.opacity(0.01)] : [Color.speakerPink.opacity(0.2), Color.blue.opacity(0.01)] ), startPoint: .top, endPoint: .bottom)
                                    .frame(width: 75, height: 80)
                                    .clipShape(Hexagon())
                                
                                Text("\(myTags.tags[item]?.name ?? "")")
                                    .foregroundColor(.mainColor)
                                    .font(.title2)
                            }
                            .onTapGesture {
                                OpenedTagNavigation = item
                            }
                        }
                    }
                }
                
            }
            .offset(x: screenWidth/20, y: -50)
            .frame(width: width, height: 100)
        }
       }
    }
    
    struct SliceView : View {
        let width: CGFloat
        var body: some View {
            ZStack{
                Circle().foregroundColor(.black.opacity(0.0001))
                    .frame(width: width)
                Rectangle()
                    .foregroundColor(Color.white)
                    .rotationEffect(Angle(degrees: 135.0))
                    .frame(width: width, height: 2)
            } .frame(width: width, height: width)
        }
    }
     
    var allButtons : some View{
        HStack (spacing: 20) {
            Spacer()
            MomentButton(imageName: "xmark"){
                showUpdatePost = nil
                selectedMedia = nil
            }
            MomentButton(imageName: "lock", width: 24, height: 30){
                TagHomeNavigationMatchedGeometry = "0"
//                        hideKeyboard()
            } 
            RecordNewAudioMomentButton(soundManager: soundManager, selectedMedia: $selectedMedia)
//                    .opacity(selectedMedia?.newMedia != nil ? 0.7 : 1.0)
//                    .disabled(selectedMedia?.newMedia != nil ? true : false)
                  
            ZStack {
            MomentButton(imageName: "camera", width: 35, height: 30){
                ShowPhotoImagePicker = true
            }
                if soundManager.isRecording {
                    SliceView(width: 60)
                }
            }
            .presentMediaPicker(isPresented: $ShowPhotoImagePicker, selectedMedia: $selectedMedia, text: $content, parentView: .post)
            MomentButton(imageName: "paperplane", width: 28, height: 28){
                
                if content.trimWhitespacesAndNewlines().isNotEmpty || !oldPostMedia.isEmpty || selectedMedia != nil {
                    if !mentionCount.isEmpty {
                                     for item in mentionCount {
                                         if content.contains(friendsDictionary.friendsDictionary[item]?.username ?? "") {
                                         } else {
                                             if let firstIndex = mentionCount.firstIndex(of: item) {
                                             mentionCount.remove(at: firstIndex)
                                             }
                                         }
                                     }

                                 }
                    timelinePosts.modifyMoment(oldPost: postData,
                                               content: content,
                                               oldPostMedia: oldPostMedia,
                                               mentionedIDs: mentionCount,
                                               tags: tagIDs,
                                               selectedMedia: selectedMedia)
                }else{
                    alert.alertDetail = "Moment cannot be empty"
                } 
                content = ""
                showUpdatePost = nil
                isShowingMentions = false
                hideKeyboard()
//                oldPostMedia.selectedMedia = nil
                selectedMedia = nil
                tagIDs.removeAll()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    mentionCount.removeAll()
                    mentionCount.append("")
                }

            }
            .overlay(
                soundManager.isRecording.falseIsNil.map { _ in SliceView(width: 50) }
            )
           
            Spacer()
        }
        .frame(width: screenWidth - 100)
        .offset(x: -5, y: 25)
    }
    
    var body: some View {
        ZStack {
        ZStack (alignment: .bottom) {
            
            Group {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: screenWidth - 20, height: screenHeight/3)
                    .foregroundColor(Color.speakerPurple.opacity(1))
                //                .blur(radius: 1)
                    .clipShape(MomentShape())
                    .overlay(textScrollView)
                
                HStack (alignment: .bottom) {
                    mediaView
                    tagScrollView
                    Spacer()
                }
//                .padding(.leading, 30)
                allButtons
            }
            .opacity(TagHomeNavigationMatchedGeometry != "" || OpenedTagNavigation != "" ? 0 : 1)
            .disabled(TagHomeNavigationMatchedGeometry != "" || OpenedTagNavigation != "" ? true : false)
            .offset(y: -200)
            
                if TagHomeNavigationMatchedGeometry != "" {
                    TagHomeTabView(TagHomeNavigationMatchedGeometry: $TagHomeNavigationMatchedGeometry, tagIDs: $tagIDs, myTags: myTags, isFromTabView: false, themeController: ThemeController())
                    
                }
                if OpenedTagNavigation != "" {
                    OpenedTagTabView(OpenedTagToTagHomeNavigation: $OpenedTagNavigation, OpenedTagToNewPostNavigation: $emptyStringBinding, tagIDs: $tagIDs, myTags: MyTagsOO(), tagFriends: TagFriendsOO(tagID: OpenedTagNavigation), isFromNewMoment: true, themeController: ThemeController())
                    
                }
       

        }
 
        .edgesIgnoringSafeArea(.top)
        .padding(.top, iOS15 ? 0 : -50)
            if isShowingMentions == true {
//                MentionAllFriendsView(friendsDictionary: friendsDictionary, content: $content, mentionCount: $mentionCount)
//                       .padding(.bottom, screenHeight/2)
//                       .offset(x: 25)
                   }
        }
        .onChange(of: selectedMedia) { val in
            if let _ = val {
                oldPostMedia.empty()
            }
        }
    }
   
}

struct EditMomentTabView: View { 
    @Binding var showUpdatePost : PostModel?
    
    @State var selectedTab = "AllMessages"
    var body: some View {
        if selectedTab == "AllMessages",  let postData = showUpdatePost{
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    EditMoment(content: postData.content,
                               postData: postData,
                               tagIDs: postData.tags,
                               showUpdatePost: $showUpdatePost,
                               oldPostMedia : OldPostMedia(oldPost: postData))
                        .tag("AllMessages")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    showUpdatePost = nil
                }
        }
        
    }
}
///so this will only be used so we can add old media values of an object that user want to change. so when user remove an old value, we will remove it from here. and at the end when user will tap to update the object, we will use this object to get the media that user removed.
struct OldPostMedia {
 //MARK: - these vars will represent new selected media
  
//    var selectedMedia : SelectedMedia? = nil
    //MARK: - these vars will represent old media
    var photoLink : URL?
    var thumbnailUrl : URL?
    var videoUrl : URL?
    var audioUrl : URL?
    init(oldPost : PostModel) {
        self.photoLink = oldPost.photoLink
        self.thumbnailUrl = oldPost.thumbnailUrl
        self.videoUrl = oldPost.videoUrl
        self.audioUrl = oldPost.audioUrl
    }
    
    var mediaKind : NewMedia.Kind?{
        if let _ = audioUrl {
            return .audio
        }else if let _ = photoLink{
            return .image
        }else if let _ = videoUrl,
                 let _ = thumbnailUrl {
            return .video
        }
        return nil
    }
    
    mutating func empty(){
//        selectedMedia = nil
        photoLink = nil
        thumbnailUrl = nil
        videoUrl = nil
        audioUrl = nil
    }
    //this way we can tell if a post had media or does user has selected new media or not
    var isEmpty : Bool {
        photoLink == nil &&
        audioUrl == nil &&
       (thumbnailUrl == nil || videoUrl == nil)
    }
}

struct RecordedEditAudioMoment : View {
    @StateObject private var audioPlayerVM: RecordedAudioPlayerVM = RecordedAudioPlayerVM()
    @ObservedObject var soundManager: SoundManager
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedMedia: SelectedMedia?
    @Binding var oldPostMedia : OldPostMedia
    @State var isNewAudio = false
    @State var hasAudioPlayedOnce = false
    var body: some View {
            ZStack {
                Rectangle()
                    .frame(width: 70, height: 80)
                    .foregroundColor(colorScheme == .light ?
                                                       Color.speakerPurple.opacity(0.2) : Color.speakerPurple.opacity(0.2))
                    .clipShape(Rectangle())
                    .cornerRadius(10)
                Button(action: {
                    if isNewAudio {
                    audioPlayerVM.playRecordingIfNotPlaying(audioUrl: selectedMedia?.audioUrl)
                    } else {
                        audioPlayerVM.playRecordingIfNotPlaying(audioUrl: oldPostMedia.audioUrl)
                    }
                }){
                    ZStack {
//                        Circle()
//                            .frame(width: 60 - 10, height: 60 - 10)
//                            .foregroundColor(Color.mainColorInverse.opacity(0.6))
                        if audioPlayerVM.playRecording {
                            AnimatedWaveformView(color: isNewAudio ? Color.speakerPurple : Color.white, renderingMode: .hierarchical, animated: true, doesHaveOutterRing: false)
                                .frame(width: 70, height: 70)
                                .scaledToFit()
                        } else {
                            AnimatedWaveformView(color: isNewAudio ? Color.speakerPurple : Color.white, renderingMode: .hierarchical, animated: false, doesHaveOutterRing: false)
                                .frame(width: 70, height: 70)
                                .scaledToFit()
                                .onAppear() {
                                    if isNewAudio && hasAudioPlayedOnce == false {
                                    audioPlayerVM.playRecordingIfNotPlaying(audioUrl: selectedMedia?.audioUrl)
                                        hasAudioPlayedOnce = true
                                    }
                                }
                        }
                    }
                }.disabled(soundManager.isRecording)
                Button(action: {
                    withAnimation {
                        if isNewAudio {
                        audioPlayerVM.stopAndDelete(audioDirURL: selectedMedia?.audioUrl)
                            selectedMedia?.audioUrl = nil
                        } else {
                        oldPostMedia.empty()
                        }
                    }
                }) {
                    Image(systemName: "clear")
                        .contentShape(Rectangle())
                        .foregroundColor(Color.speakerPurple.opacity(1))
                }  .buttonStyle(.borderless)
                    .offset(x: 30, y: -30)
            }

            .offset(x: 20, y: -60)
            Spacer()

    }
}
struct SelectedImageView<Content: View>: View {
    @ViewBuilder var content: Content
    let action: ()->()
    var body: some View {
        ZStack {
            content
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .cornerRadius(5)
            
            Button(action: action) {
                Image(systemName: "xmark.square")
                    .foregroundColor(.speakerPurple)
            }
            .offset(x: 30, y: -30)
        }
        .offset(x: 20, y: -60)
    }
}
