//
//  OSPickerView.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 10/4/21.
//
 

import SwiftUI
import CoreServices
import AVFoundation
import Cocoa

//FIXME: - we can also add the picked media in the cache so we can just use the newMedia as it is and will need a check before sending media to make sure it is in the correct format.
typealias InstagramImagePickerView = OSPickerView
struct OSPickerView: View {
    @Binding var newMedia : NewMedia?
    @Binding var text : String
    @StateObject var pickerVM  = MacOSMediaPickerVM()
    @EnvironmentObject var friendsDictionary: FriendsDictionary
    @StateObject var alert = AlertOO()
    @Environment(\.presentationMode) var presentationMode
    @State var showProgresser : Bool = false
    
    var imageView : some View {
        ZStack {
            
             Color(#colorLiteral(red: 0.05882352941, green: 0.05882352941, blue: 0.05882352941, alpha: 1))
            if let img = newMedia?.image {
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }else{ 
                Text("Select Media")
                    .font(.system(size: 50))
            }
            if showProgresser{
                HStack(spacing: 20) {
                Text("Loading Media ...")
                    .font(.title3)
                    ProgressViewPurpleCircular()
                }
            }
        }.frame(width: screenWidth*0.6, height: screenWidth*0.6)
         .onTapGesture {
             selectFile()
         }
         .padding(.top ,10)
    }
    
    var body: some View {
        
        ZStack{
            VStack{
                Button {
                    newMedia = nil
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    MacOsDismissButton(matchedGeometry: .constant(""))
                }.buttonStyle(.borderless)
                    .padding(.leading ,20)
                    .padding(.top ,20)
                
                imageView
                 
                ZStack(){
                    if  newMedia?.image == nil {
                        Button("Select Media",action: selectFile)
                    }else{
                        HStack{
                            
                            Spacer()
                            
                            Button("Cancel") {
                                newMedia = nil
                                showProgresser = false
                            }.frame( width: 70, alignment: .center)
                                .padding()
                            
                            Spacer()
                            
                            Button("Done",action : doneTapped)
                                .frame( width: 70, alignment: .center)
                                .padding()
                                .disabled(showProgresser)
                            Spacer()
                        }
                    }
                }.frame(height: 70, alignment: .center)
            }.frame(width: screenWidth*0.8, height: screenWidth*0.8, alignment: .center)
            
            if alert.showAlert{
                AlertView(errorString:  $alert.alertDetail)
            }
        }
    }
    
    func doneTapped() {
        withAnimation {
            showProgresser = true
        } 
        DispatchQueue.global(qos: .userInitiated).async  {
            newMedia?.image.getCompressedImage { comperssedImage in
                DispatchQueue.main.async {
                    if let comperssedImage = comperssedImage {
                        print("image has been compressed ")
                        self.newMedia?.image = comperssedImage
                        presentationMode.wrappedValue.dismiss()
                    }else{
                        newMedia = nil
                        alert.alertDetail = "Image compression failed, some thing went wrong"
                    }
                    showProgresser = false
                }
            }
        }
    }
    
    func showAlert(detail : String){
        withAnimation {
            alert.alertDetail = detail
        }
    }
    
    func selectFile(){
        let openPanel = NSOpenPanel()
        openPanel.prompt = "Select File"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["public.image","public.movie"]
        openPanel.begin { (result) -> Void in
            pickerVM.getMedia(openPanelURL: openPanel.url, openPanelResponse: result) { newMedia, error in
                if let newMedia = newMedia {
                    self.newMedia = newMedia
                }else if let error = error{
                    showAlert(detail: error.localizedDescription.description)
                }
            }
        }
    }
       
    func dismiss(errorDetail : String? = nil){
        if let errorDetail = errorDetail{
            newMedia = nil
            alert.alertDetail = errorDetail
        }
        presentationMode.wrappedValue.dismiss()
    }
     
}

class MacOSMediaPickerVM : ObservableObject{
    public func imageFromVideo(url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let asset = AVURLAsset(url: url)
            
            let assetIG = AVAssetImageGenerator(asset: asset)
            assetIG.appliesPreferredTrackTransform = true
            assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
            
            //            let cmTime = CMTime(seconds: 0, preferredTimescale: 60)
            let thumbnailImageRef: CGImage
            do {
                thumbnailImageRef = try assetIG.copyCGImage(at: .zero, actualTime: nil)
            } catch let error {
                print("Error: \(error)")
                return completion(nil)
            }
            DispatchQueue.main.async {
                completion(UIImage(cgImage: thumbnailImageRef, size: .zero))
            }
        }
    }
    
    func getMedia(openPanelURL : URL?,
                  openPanelResponse response : NSApplication.ModalResponse,
                  callback : @escaping (_ newMedia : NewMedia?,  _  error : Error?) -> Void){
         
        guard let url = openPanelURL, response.rawValue == NSApplication.ModalResponse.OK.rawValue else {
            callback(nil, nil)
            return
        }
        
        if let resourceValues = try? url.resourceValues(forKeys: [URLResourceKey.typeIdentifierKey]),
           let typeId : CFString = resourceValues.typeIdentifier as CFString? {
            if UTTypeConformsTo( typeId, kUTTypeMovie)  {
                print("url \(url)")
                guard url.fileSize <= 64*1000*1000 else{
                    callback(nil,"Video size exceeded 64MB limit".asError)
                    return
                }
                self.imageFromVideo(url: url) { image in
                    if let image = image {
                        callback(NewMedia(image: image, videoUrl: url),nil)
                    }
                }
            }else if UTTypeConformsTo( typeId, kUTTypeImage){
                if let selectedImage = NSImage(contentsOf: url) {
                    callback(NewMedia(image: selectedImage),nil)
                }
            }else{
                callback(nil,"Media Format Not Supported".asError)
            }
        }else{
            callback(nil,"Media Format Not Supported".asError)
        }
    }
}
 
/*
 stil need to test the flow. and add background threading as well check everything thorouly 
 */
