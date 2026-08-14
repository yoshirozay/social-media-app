//
//  OpenedPhoto.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 4/18/22.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct OpenedPhoto: View {
    @State var photo: URL?
    @Binding var OpenedPhotoMatchedGeometry: String
    @State var isFromTimeline = false
    @State private var scale: CGFloat = 1
    @State var isSavedMessageShowing = false
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            WebImage(url: photo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .zoomable(scale: $scale)
                .contextMenu {
                    Button(action: {
                        saveMediaInPhotosAlbum()
                    }) {
                        Text("Save Photo")
                    }
                }
                .overlay (
                    ZStack {
                    if isSavedMessageShowing {
                    Text("Saved")
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                        .onAppear() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                isSavedMessageShowing = false
                                }
                            }
                        }
                    }
                    }
                )
            VStack () {
                HStack {
                    Button(action: {
                        OpenedPhotoMatchedGeometry = ""
                        
                    }) {
                        ZStack {
#if os(iOS)
                            Color.white.opacity(0.2)
#endif
                        Image(systemName: "chevron.left")
                            .font(.largeTitle)

                            .foregroundColor(.speakerPurple)
                            .padding(.horizontal, 5)
                        }
                        .frame(width: 20, height: 20)
//                        .padding(.leading)
                        
                    }.buttonStyle(.borderless)
                    .padding(.top, 80)
                    Spacer()
                }
                .padding()
                Spacer()
            }
//            .opacity(isFromTimeline == true ? 1 : 0)
//            .disabled(isFromTimeline == true ? false : true)
        }
      
        .highPriorityGesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onEnded({ value in
            if value.translation.width > 80 {
                                       // right
//                withAnimation(.easeOut(duration: 0.3)) {
                    OpenedPhotoMatchedGeometry = ""
//                }
                                   }
                                if value.translation.height > 80 {
                                    // down
//                                    withAnimation(.easeOut(duration: 0.3)) {
                                        OpenedPhotoMatchedGeometry = ""
//                                    }

                                }
                            }))
    }
    func saveMediaInPhotosAlbum(){
        DispatchQueue.global(qos: .background).async {
               do
                {
                    let data = try Data.init(contentsOf: (photo ?? URL.init(string:"url"))!)
                      DispatchQueue.main.async {
                          let image: UIImage? = UIImage(data: data) ?? UIImage(systemName: "")
                          
                          NewMedia.saveInPhotosAlbum(newMedia: NewMedia(image: image!)) {  error in
                              print(error?.localizedDescription ?? "media saved in PhotosAlbum")
                              withAnimation(.easeIn(duration: 0.5)) {
                                  isSavedMessageShowing = true
                              }
                          }
                      }
                }
               catch {
                      // error
                     }
        }

        
    }
}

struct OpenPhotoTabView: View {
    @Binding var OpenedPhotoMatchedGeometry: String
    @State var selectedTab = "tag"
    @State var photo: URL?
    @State var isFromTimeline: Bool
    var body: some View {
        if selectedTab == "tag" {
            ZStack {
                
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    OpenedPhoto(photo: photo, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, isFromTimeline: isFromTimeline)
                        .tag("tag")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    OpenedPhotoMatchedGeometry = ""
                }
        }
    }
}

struct OpenedGIF: View {
    @State var gifURL: String
    @Binding var OpenedGIFMatchedGeometry: String
    @State private var scale: CGFloat = 1
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            AnimatedImage(url: URL(string: gifURL))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .zoomable(scale: $scale)
            VStack () {
                HStack {
                    Button(action: {
                        OpenedGIFMatchedGeometry = ""
                        
                    }) {
                        ZStack {
#if os(iOS)
                            Color.white.opacity(0.2)
#endif
                        Image(systemName: "chevron.left")
                            .font(.largeTitle)

                            .foregroundColor(.speakerPurple)
                            .padding(.horizontal, 5)
                        }
                        .frame(width: 20, height: 20)
//                        .padding(.leading)
                        
                    }.buttonStyle(.borderless)
                    .padding(.top, 80)
                    Spacer()
                }
                .padding()
                Spacer()
            }
//            .opacity(isFromTimeline == true ? 1 : 0)
//            .disabled(isFromTimeline == true ? false : true)
        }
      
        .highPriorityGesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onEnded({ value in
            if value.translation.width > 80 {
                                       // right
//                withAnimation(.easeOut(duration: 0.3)) {
                OpenedGIFMatchedGeometry = ""
//                }
                                   }
                                if value.translation.height > 80 {
                                    // down
//                                    withAnimation(.easeOut(duration: 0.3)) {
                                    OpenedGIFMatchedGeometry = ""
//                                    }

                                }
                            }))
    }
}

struct OpenedGIFTabView: View {
    @Binding var OpenedGIFMatchedGeometry: String
    @State var selectedTab = "tag"
    var body: some View {
        if selectedTab == "tag" {
            ZStack {
                
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    OpenedGIF(gifURL: OpenedGIFMatchedGeometry, OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry)
                        .tag("tag")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    OpenedGIFMatchedGeometry = ""
                }
        }
    }
}

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct OpenedPhoto: View {
    @State var photo: URL?
    @Binding var OpenedPhotoMatchedGeometry: String
    @State var isFromTimeline = false
    @State private var scale: CGFloat = 1
    @State var isSavedMessageShowing = false
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            WebImage(url: photo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .zoomable(scale: $scale)
                .contextMenu {
                    Button(action: {
                        saveMediaInPhotosAlbum()
                    }) {
                        Text("Save Photo")
                    }
                }
                .overlay (
                    ZStack {
                    if isSavedMessageShowing {
                    Text("Saved")
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                        .onAppear() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                isSavedMessageShowing = false
                                }
                            }
                        }
                    }
                    }
                )
            VStack () {
                HStack {
                    Button(action: {
                        OpenedPhotoMatchedGeometry = ""
                        
                    }) {
                        ZStack {
#if os(iOS)
                            Color.white.opacity(0.2)
#endif
                        Image(systemName: "chevron.left")
                            .font(.largeTitle)

                            .foregroundColor(.speakerPurple)
                            .padding(.horizontal, 5)
                        }
                        .frame(width: 20, height: 20)
//                        .padding(.leading)
                        
                    }.buttonStyle(.borderless)
                    .padding(.top, 80)
                    Spacer()
                }
                .padding()
                Spacer()
            }
//            .opacity(isFromTimeline == true ? 1 : 0)
//            .disabled(isFromTimeline == true ? false : true)
        }
      
        .highPriorityGesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onEnded({ value in
            if value.translation.width > 80 {
                                       // right
//                withAnimation(.easeOut(duration: 0.3)) {
                    OpenedPhotoMatchedGeometry = ""
//                }
                                   }
                                if value.translation.height > 80 {
                                    // down
//                                    withAnimation(.easeOut(duration: 0.3)) {
                                        OpenedPhotoMatchedGeometry = ""
//                                    }

                                }
                            }))
    }
    func saveMediaInPhotosAlbum(){
        DispatchQueue.global(qos: .background).async {
               do
                {
                    let data = try Data.init(contentsOf: (photo ?? URL.init(string:"url"))!)
                      DispatchQueue.main.async {
                          let image: UIImage? = UIImage(data: data) ?? UIImage(systemName: "")
                          
                          NewMedia.saveInPhotosAlbum(newMedia: NewMedia(image: image!)) {  error in
                              print(error?.localizedDescription ?? "media saved in PhotosAlbum")
                              withAnimation(.easeIn(duration: 0.5)) {
                                  isSavedMessageShowing = true
                              }
                          }
                      }
                }
               catch {
                      // error
                     }
        }

        
    }
}

struct OpenPhotoTabView: View {
    @Binding var OpenedPhotoMatchedGeometry: String
    @State var selectedTab = "tag"
    @State var photo: URL?
    @State var isFromTimeline: Bool
    var body: some View {
        if selectedTab == "tag" {
            ZStack {
                
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    OpenedPhoto(photo: photo, OpenedPhotoMatchedGeometry: $OpenedPhotoMatchedGeometry, isFromTimeline: isFromTimeline)
                        .tag("tag")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    OpenedPhotoMatchedGeometry = ""
                }
        }
    }
}

struct OpenedGIF: View {
    @State var gifURL: String
    @Binding var OpenedGIFMatchedGeometry: String
    @State private var scale: CGFloat = 1
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea(.all)
            AnimatedImage(url: URL(string: gifURL))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .zoomable(scale: $scale)
            VStack () {
                HStack {
                    Button(action: {
                        OpenedGIFMatchedGeometry = ""
                        
                    }) {
                        ZStack {
#if os(iOS)
                            Color.white.opacity(0.2)
#endif
                        Image(systemName: "chevron.left")
                            .font(.largeTitle)

                            .foregroundColor(.speakerPurple)
                            .padding(.horizontal, 5)
                        }
                        .frame(width: 20, height: 20)
//                        .padding(.leading)
                        
                    }.buttonStyle(.borderless)
                    .padding(.top, 80)
                    Spacer()
                }
                .padding()
                Spacer()
            }
//            .opacity(isFromTimeline == true ? 1 : 0)
//            .disabled(isFromTimeline == true ? false : true)
        }
      
        .highPriorityGesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onEnded({ value in
            if value.translation.width > 80 {
                                       // right
//                withAnimation(.easeOut(duration: 0.3)) {
                OpenedGIFMatchedGeometry = ""
//                }
                                   }
                                if value.translation.height > 80 {
                                    // down
//                                    withAnimation(.easeOut(duration: 0.3)) {
                                    OpenedGIFMatchedGeometry = ""
//                                    }

                                }
                            }))
    }
}

struct OpenedGIFTabView: View {
    @Binding var OpenedGIFMatchedGeometry: String
    @State var selectedTab = "tag"
    var body: some View {
        if selectedTab == "tag" {
            ZStack {
                
                TabView(selection: $selectedTab) {
                    EmptyView()
                        .tag("home")
                    OpenedGIF(gifURL: OpenedGIFMatchedGeometry, OpenedGIFMatchedGeometry: $OpenedGIFMatchedGeometry)
                        .tag("tag")
                }
                .edgesIgnoringSafeArea(.bottom)
                .mutualTabViewStyle()
            }
            .ignoresSafeArea(edges: .top)
        } else {
            EmptyView()
                .onAppear() {
                    OpenedGIFMatchedGeometry = ""
                }
        }
    }
}
