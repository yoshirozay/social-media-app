//
//  NewMoment.swift
//  speakEZ
//
//  Created by Carson O'Sullivan on 2/13/22.
//

import SwiftUI
import Combine


struct NewMoment3: View {
    @State var content = ""
    @State var keyboard = KeyboardOO()
    @Binding var NewPostMatchedGeometry: String
    @State var isPhotoShowing = false
    @State var textViewMaxHeight: CGFloat = screenHeight/2 - 65
    @State var isNewMoment = true
    @Binding var selectedMedia: SelectedMedia?
    @State var ShowPhotoImagePicker = false
    @StateObject var myTags = MyTagsOO()
    @State var tagIDs = [String]()
    @State var isShowingMentions = false
    @State var mentionCount = [String]()
    @State var TagHomeNavigationMatchedGeometry = ""
    @State var OpenedTagNavigation = ""
    @Environment(\.colorScheme) var colorScheme
    @State var emptyStringBinding = ""
    @ObservedObject var timelinePosts : TimelinePostsOO
    @ObservedObject var friendsDictionary: FriendsDictionary
    @StateObject var soundManager = SoundManager()
    var body: some View {
        ZStack {
        ZStack (alignment: .bottom) {
            
            Group {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: screenWidth - 20, height: screenHeight/3)
                    .foregroundColor(Color.speakerPurple.opacity(1))
                //                .blur(radius: 1)
                    .clipShape(MomentShape())
                    .overlay(
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
                            .offset(y: -25))
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                HStack (alignment: .bottom) {
                    if let postImage = selectedMedia?.image  {
                        ZStack {
                            Image(uiImage: postImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .cornerRadius(5)
                            
                            Button(action: {
                                selectedMedia = nil
                            }) {
                                Image(systemName: "xmark.square")
                                    .foregroundColor(.speakerPurple)
                            }
                            .offset(x: 30, y: -30)
                        }
                        .offset(x: 20, y: -60)
                        
                    }
                    if let audioMessage = selectedMedia?.audioUrl {
                        RecordedAudioMoment(selectedMedia: $selectedMedia, soundManager: soundManager)
                    }
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
                    Spacer()
                }
                
                HStack (spacing: 20) {
                    Spacer()
                    MomentButton(imageName: "xmark"){
                        NewPostMatchedGeometry = ""
                        selectedMedia = nil
                    }
                    MomentButton(imageName: "lock", width: 24, height: 30){
                        TagHomeNavigationMatchedGeometry = "0"
//                        hideKeyboard()
                    }
                    ZStack {
                    RecordNewAudioMomentButton(soundManager: soundManager, selectedMedia: $selectedMedia)
                            .opacity(selectedMedia?.newMedia != nil ? 0.7 : 1.0)
                            .disabled(selectedMedia?.newMedia != nil ? true : false)
                        if let media = selectedMedia?.newMedia {
                        Rectangle()
                            .foregroundColor(Color.white)
                            .rotationEffect(Angle(degrees: 135.0))
                            .frame(width: 70, height: 2)
                        }
                    }
                    ZStack {
                    MomentButton(imageName: "camera", width: 35, height: 30){
                        ShowPhotoImagePicker = true
                    }
//                    .opacity(selectedMedia?.audioUrl != nil || soundManager.isRecording ? 0.7 : 1.0)
                        if selectedMedia?.audioUrl != nil || soundManager.isRecording {
                        Rectangle()
                            .foregroundColor(Color.white)
                            .rotationEffect(Angle(degrees: 135.0))
                            .frame(width: 60, height: 2)
                        }
                    }
                    .presentMediaPicker(isPresented: $ShowPhotoImagePicker, selectedMedia: $selectedMedia, text: $content, parentView: .post)
                    .disabled(selectedMedia?.audioUrl != nil || soundManager.isRecording ? true : false)
                    MomentButton(imageName: "paperplane", width: 28, height: 28){
                        
                        if content.trimWhitespacesAndNewlines().isNotEmpty || selectedMedia != nil {
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
                            timelinePosts.sendNewPost(content: content, selectedMedia: selectedMedia, mentionedIDs: mentionCount, tags: tagIDs)
                        }
                        content = ""
                        NewPostMatchedGeometry = ""
                        isShowingMentions = false
                        hideKeyboard()
                        withAnimation {
                            NewPostMatchedGeometry = ""
                        }
                        selectedMedia = nil
                        
                        tagIDs.removeAll()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            mentionCount.removeAll()
                            mentionCount.append("")
                        }

                    }
                    Spacer()
                }
                .frame(width: screenWidth - 100)
                .offset(x: -5, y: 25)
            }
            .opacity(TagHomeNavigationMatchedGeometry != "" || OpenedTagNavigation != "" ? 0 : 1)
            .disabled(TagHomeNavigationMatchedGeometry != "" || OpenedTagNavigation != "" ? true : false)
            .offset(y: -200)
            
                if TagHomeNavigationMatchedGeometry != "" {
                    TagHomeTabView(TagHomeNavigationMatchedGeometry: $TagHomeNavigationMatchedGeometry, tagIDs: $tagIDs, myTags: myTags, isFromTabView: false, themeController: ThemeController())
//                        .transition(.opacity)
                    //                    .padding(.bottom, iOS15 ? 0 : 40)
                    //                    .edgesIgnoringSafeArea(.top)
                    //                    .offset(y: 160)
                    
                    
                }
                if OpenedTagNavigation != "" {
                    OpenedTagTabView(OpenedTagToTagHomeNavigation: $OpenedTagNavigation, OpenedTagToNewPostNavigation: $emptyStringBinding, tagIDs: $tagIDs, myTags: MyTagsOO(), tagFriends: TagFriendsOO(tagID: OpenedTagNavigation), isFromNewMoment: true, themeController: ThemeController())
                    
                }
//
        }
//        .transaction { transaction in
//            transaction.animation = nil
//        }
        .edgesIgnoringSafeArea(.top)
        .padding(.top, iOS15 ? 0 : -50)
//            if isShowingMentions == true {
//                MentionAllFriendsView(friendsDictionary: friendsDictionary, content: $content, mentionCount: $mentionCount)
//                       .padding(.bottom, screenHeight/2)
//                       .offset(x: 25)
//                   }
    }
        .onChange(of: isCurrentViewVisible, perform: stopAndDeleteRecordingIfAny)
    }
    var isCurrentViewVisible: Bool {
        TagHomeNavigationMatchedGeometry.isEmpty &&
        OpenedTagNavigation.isEmpty &&
        !ShowPhotoImagePicker
    }
    func stopAndDeleteRecordingIfAny(isCurrentViewVisible: Bool){
        if isCurrentViewVisible == false {
            if soundManager.isRecording {
                soundManager.stopAndDelete()
            }
        }
    }
}



struct MomentButton: View {
    var imageName: String
    var width: CGFloat = 25
    var height: CGFloat = 25
    var action: () -> Void
    var body: some View {
        ZStack {
            LinearGradient(gradient: .init(colors: imageName != "paperplane" && imageName != "xmark" ? [Color.speakerPurple.opacity(0.8), Color.speakerPink.opacity(0.8)] : [Color.red.opacity(0.8), Color.speakerPink.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .frame(width: imageName == "waveform" ? 70 : imageName == "camera" || imageName == "lock" ? 60 : 50, height: imageName == "waveform" ? 70 : imageName == "camera" || imageName == "lock" ? 60 : 50)
                .clipShape(Circle())
                
            Button(action: { action() }, label: {
              
                Image(systemName: imageName)
                    .resizable()
                    .frame(width: width, height: height)
                
//
            })
            .foregroundColor(.white)
        }
    }
}


struct MomentShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        return Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height - 50))
            //            path.addCurve(to: CGPoint(x: 0, y: rect.height - 50),
            //                          control1: CGPoint(x: 0, y: 0),
            //                          control2: CGPoint(x: 0, y: 0))
            
            // Custom Inner Rectangle Shape
            
            let midWidth = rect.width / 2
            //            path.addLine(to: CGPoint(x: midWidth - 150, y: rect.height))
            //            path.addLine(to: CGPoint(x: midWidth - 120, y: rect.height - 50))
            path.addLine(to: CGPoint(x: midWidth + 170, y: rect.height - 50))
            path.addLine(to: CGPoint(x: midWidth + 220, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        }
    }
    
    
    
}




struct NewMomentTabView: View {
    @Binding var NewPostMatchedGeometry: String
    @State var selectedTab = "AllMessages"
    @Binding var selectedMedia: SelectedMedia?
    @ObservedObject var timelinePosts : TimelinePostsOO
    var body: some View {
        if selectedTab == "AllMessages" {
            ZStack {
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("none")
                    NewMoment3(NewPostMatchedGeometry: $NewPostMatchedGeometry, selectedMedia: $selectedMedia, timelinePosts: timelinePosts, friendsDictionary: timelinePosts.friendsDictionary)
                        .tag("AllMessages")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    NewPostMatchedGeometry = ""
                }
        }
        
    }
}

struct RecordNewAudioMomentButton : View {
    @StateObject var soundManager = SoundManager()
    @Binding var selectedMedia : SelectedMedia?
    @Environment(\.colorScheme) var colorScheme
    @State var isFromMessages = true
    var body: some View {
        ZStack {
            LinearGradient(gradient: .init(colors: soundManager.isRecording ?  colorScheme == .light ? [Color.speakerPurple.opacity(0.8), Color.speakerPink.opacity(0.8)] : [Color.speakerPurple.opacity(0.8), Color.speakerPink.opacity(0.8)] : [Color.speakerPink.opacity(0.8), Color.speakerPurple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .frame(width: 70, height: 70)
                .clipShape(Circle())
            
            if soundManager.isRecording {
                AnimatedWaveformView(color: .white, animated: true, doesHaveOutterRing: false)
                .frame(width: 70, height: 70)
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
                    .frame(width: 70, height: 70)
                    .onTapGesture {
                        withAnimation {
#if os(iOS)
        let impactLight = UIImpactFeedbackGenerator(style: .soft)
                        impactLight.impactOccurred()
#endif
                            selectedMedia?.newMedia = nil
                            selectedMedia?.deleteCacheOfSelectedMediaIfAny()
                            soundManager.recordAudio()
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

struct RecordedAudioMoment : View {
    @Binding var selectedMedia: SelectedMedia?
    @StateObject private var audioPlayerVM: RecordedAudioPlayerVM = RecordedAudioPlayerVM()
    @ObservedObject var soundManager: SoundManager
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
            ZStack {
                Rectangle()
                    .frame(width: 70, height: 80)
                    .foregroundColor(colorScheme == .light ?
                                                       Color.speakerPurple.opacity(0.2) : Color.speakerPurple.opacity(0.2))
                    .clipShape(Rectangle())
                    .cornerRadius(10)
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
                Button(action: {
                    withAnimation {
                    audioPlayerVM.stopAndDelete(audioDirURL:  selectedMedia?.audioUrl)
                    selectedMedia = nil
                    }
                }) {
                    Image(systemName: "clear")
                        .contentShape(Rectangle())
                        .foregroundColor(Color.speakerPurple.opacity(1))
                }  .buttonStyle(.borderless)
                    .offset(x: 30, y: -30)
            }
            .onAppear() {
                audioPlayerVM.playRecordingIfNotPlaying(audioUrl: selectedMedia?.audioUrl)
            }
            .offset(x: 20, y: -60)
            Spacer()

    }
}

