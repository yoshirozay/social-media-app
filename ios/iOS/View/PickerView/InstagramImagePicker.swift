//
//  InstagramImagePicker.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 5/7/21.
//

import SwiftUI
import Combine
import YPImagePicker 
import SDWebImageSwiftUI
import Shimmer
extension View {
    func presentMediaPicker(isPresented: Binding<Bool>,
                            newMedia : Binding<NewMedia?>  = Binding.constant(nil),
                            selectedMedia : Binding<SelectedMedia?>  = Binding.constant(nil),
                            text: Binding< String> = Binding.constant("") ,
                            parentView: ParentView) -> some View {
        self.modifier(MediaPicker(isPresented: isPresented,
                                  newMedia: newMedia,
                                  selectedMedia: selectedMedia,
                                  text: text,
                                  parentView: parentView ))
    }
}

class ShimerringVM : ObservableObject {
    
    @Published var isImageLoaded : Bool = false
    func imageLoadedSuccessfully(_ action: PlatformImage){
        DispatchQueue.main.async {
            self.isImageLoaded = true
        }
    }
    
}


struct ShimerringWebImage : View {
//    @StateObject var shimerringVM = ShimerringVM()
    let url : URL?
    @Environment(\.colorScheme) var colorScheme
//    var backgroundColor : Color = .speakerPurple.opacity(0.6)
    @ObservedObject var themeController: ThemeController
    var body: some View {
        SDWebImageSwiftUI.WebImage(url: url)
            .placeholder{
                themeController.theme.accent
//                (colorScheme == .light ? Color.speakerPurple.opacity(0.2) : Color.speakerPurple.opacity(0.2))
                
                    .shimmering2(bounce: true)
                //(active: !shimerringVM.isImageLoaded)
            }
//            .onSuccess(perform: shimerringVM.imageLoadedSuccessfully)
            .resizable() 
    }
    func resizable() -> some View{
        self
    }
}

extension WebImage{
    func shimmerLoadding() -> WebImage{
        self//.modifier(ImageShimmerLoading())
//        self.mo
    }
}
public struct Shimmer2: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration = 1.5
    var bounce = false

    public func body(content: Content) -> some View {
        content
            .modifier(AnimatedMask(phase: phase).animation(
                Animation.linear(duration: duration)
                    .repeatForever(autoreverses: bounce)
            ))
            .onAppear { phase = 0.8 }
    }

    /// An animatable modifier to interpolate between `phase` values.
    struct AnimatedMask: AnimatableModifier {
        var phase: CGFloat = 0

        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }

        func body(content: Content) -> some View {
            content
                .mask(GradientMask(phase: phase).scaleEffect(3))
        }
    }

    /// A slanted, animatable gradient between transparent and opaque to use as mask.
    /// The `phase` parameter shifts the gradient, moving the opaque band.
    struct GradientMask: View {
        let phase: CGFloat
        let centerColor = Color.white
        let edgeColor = Color.white.opacity(0.3)

        var body: some View {
            LinearGradient(gradient:
                Gradient(stops: [
                    .init(color: edgeColor, location: phase),
                    .init(color: centerColor, location: phase + 0.1),
                    .init(color: edgeColor, location: phase + 0.2)
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

public extension View {
    /// Adds an animated shimmering effect to any view, typically to show that
    /// an operation is in progress.
    /// - Parameters:
    ///   - active: Convenience parameter to conditionally enable the effect. Defaults to `true`.
    ///   - duration: The duration of a shimmer cycle in seconds. Default: `1.5`.
    ///   - bounce: Whether to bounce (reverse) the animation back and forth. Defaults to `false`.
    @ViewBuilder func shimmering2(
        active: Bool = true, duration: Double = 1.5, bounce: Bool = false
    ) -> some View {
        if active {
            modifier(Shimmer2(duration: duration, bounce: bounce))
        } else {
            self
        }
    }
}
/*
 WebImage(url: friendsDictionary.friendsDictionary[id]?.profilePicLink)
     .placeholder(content: {
        Color.gray .shimmering(active: !hasProfileImageLoaded, duration: 1.5, bounce: false)
     })
     .onSuccess { image, data, cacheType in
         DispatchQueue.main.async {
             hasProfileImageLoaded = true
         }
            // Success
            // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
        }
 */
struct ImageShimmerLoading<WebImage>: ViewModifier  {
  
    func body(content: Content) -> some View {
        content
    }
}
struct MediaPicker: ViewModifier {
    @Environment(\.hideStatusBar) var hideStatusBar
    @Binding var isPresented : Bool
    @Binding var newMedia : NewMedia?
    @Binding var selectedMedia : SelectedMedia?
    @Binding var text : String
    var parentView : ParentView
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented, onDismiss: {
                hideStatusBar.wrappedValue = false
            })  {
                InstagramImagePicker( newMedia: $newMedia,selectedMedia: $selectedMedia, text : $text ,parentView : parentView)
                    .statusBar(hidden: true)
                    .ignoresSafeArea(.all)
            }
    }
}


struct InstagramImagePicker: UIViewControllerRepresentable {
   @Environment(\.presentationMode) var presentationMode
    @Binding var newMedia: NewMedia?
    @Binding var selectedMedia: SelectedMedia?
    @Binding var text : String
    @Environment(\.hideStatusBar) var hideStatusBar

    var parentView : ParentView = ParentView.other
    
    var canGetVideo : Bool {
        parentView != .userProfile 
    }

    var isFromSendToScreen : Bool{
        parentView == .sendTo
    }
    
   typealias UIViewControllerType = NewYPImagePicker
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<InstagramImagePicker>) -> NewYPImagePicker {
        if parentView != .userProfile {
            /// if we do it in the CreateProfile2 will just re-inits it self
           hideStatusBar.wrappedValue = true
        }
        var config = getNewYPImagePickerConfig()
        if parentView == .userProfile || parentView == .message  {
            config.startOnScreen = YPPickerScreen.library
        }
        let picker = NewYPImagePicker(configuration: config)
        picker.parentView = parentView
        picker.text = text
        
        picker.didGetEditedImage {  media   in
            
            hideStatusBar.wrappedValue = false
            guard let media = media else {
                return
            }
            let newImage = media.image
            
             print("compressing selected image please wait . . . ")
            DispatchQueue.global(qos: .userInitiated).async  {
                newImage.getCompressedImage { comperssedImage in
                    if let comperssedImage = comperssedImage {
                        DispatchQueue.main.async {
                            print("image has been compressed ")
                            ///dont need an NewMedia init just assaign to newMedia
                           let newMedia = NewMedia(image: comperssedImage,
                                                videoUrl: media.videoUrl ,
                                                description: media.description,
                                                isFromCamera: media.isFromCamera)
                            self.newMedia = newMedia
                            self.selectedMedia?.deleteCacheOfSelectedMediaIfAny()
                            self.selectedMedia = SelectedMedia(newMedia: newMedia)
                            dismiss()
                        }
                    }
                }
            }
        }
       
        return picker
    }
     
   func updateUIViewController(_ uiViewController: NewYPImagePicker, context: UIViewControllerRepresentableContext<InstagramImagePicker>) {
//    print("updateUIViewController")
 
   }
    
    func getNewYPImagePickerConfig() ->  YPImagePickerConfiguration{
        NewYPImagePicker.getConfig(canGetVideo: canGetVideo) 
    }
      
    func dismiss(){
        
        if let mediaDescription  = newMedia?.description,
           !mediaDescription.isEmpty{
            print(mediaDescription)
            text = mediaDescription
        }
        
        if let mediaDescription  = selectedMedia?.newMedia?.description,
           !mediaDescription.isEmpty{
            print(mediaDescription)
            text = mediaDescription
        }
        
        if !isFromSendToScreen{
            presentationMode.wrappedValue.dismiss()
        }
    }
}



struct InstagramImagePickerView: View  {
    @Binding var newMedia: NewMedia?
  //FIXME: - we will be selectedMedia  in future instead of newMedia
//    @Binding var selectedMedia : SelectedMedia?
    @Binding var text : String
    @EnvironmentObject var allChats : AllMessagesOO
    @Environment(\.hideStatusBar) var hideStatusBar
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @ObservedObject var themeController: ThemeController
    var body: some View{
        ZStack{
            
            InstagramImagePicker(  newMedia: $newMedia,selectedMedia: .constant(nil), text: $text, parentView : .sendTo)
                .statusBar(hidden: true)
                .ignoresSafeArea(.all)
            ZStack{
                if let _ = newMedia?.image  {
                    ZStack{
                        PhotoMessage( media: $newMedia, presentationMode : presentationMode, themeController: themeController)
                            .environmentObject(allChats)
                            .animation(.easeInOut(duration: 0.3))
                    }.transition(.move(edge: .trailing))
                    .ignoresSafeArea( edges: .bottom)
                }
            }.transition(.move(edge: .trailing))
        }
    }
}
extension Data{
    var possibleImage : UIImage?{
        UIImage(data: self)
    }
}
