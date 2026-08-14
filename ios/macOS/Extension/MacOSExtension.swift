//
//  MacOSExtension.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 12/4/21.
//
  
import Cocoa
import SwiftUI
 
extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }

    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }

    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }

    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}
//if we do not override viewDidMoveToWindow of NSTableView the list background color get changed need to check that as well
extension NSTableView {
   open override func viewDidMoveToWindow() {
       super.viewDidMoveToWindow()
       
       backgroundColor = NSColor.clear
       enclosingScrollView?.drawsBackground = false
   }
}

extension NSColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> NSImage {
        return NSImage(color: self, size: size)
    }
}

extension NSScreen {
  static var width : CGFloat {
      let screenWidth = (NSScreen.main?.visibleFrame.width ?? 0) * 0.5558035714
//      screenWidth = screenWidth/2 + screenWidth/17.92
      return screenWidth
   }
  static var height : CGFloat {
      let screenHeight =  (NSScreen.main?.visibleFrame.height ?? 0 ) * 0.9258710156
//      screenHeight = screenHeight - screenHeight/13.49
       return  screenHeight
   }
}

extension NSImage {
    convenience init(color: NSColor, size: NSSize ) {
        self.init(size: size)
        lockFocus()
        color.drawSwatch(in: NSRect(origin: .zero, size: size))
        unlockFocus()
    }
    
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)
  
        return cgImage(forProposedRect: &proposedRect,
                       context: nil,
                       hints: nil)
    }
    func jpegData(compressionQuality: Double) -> Data? {
        var compressedData: Data?
        if let tiff = self.tiffRepresentation,
           let compressedImageData = NSBitmapImageRep(data: tiff)?.representation(using: .jpeg, properties: [.compressionFactor : compressionQuality]) {
            compressedData = compressedImageData
        }
        return compressedData
    }
}


extension Image {
  init(uiImage : NSImage) {
      self.init(nsImage: uiImage)
  }
}

extension View {
    func presentMediaPicker(isPresented: Binding<Bool>,
                            newMedia : Binding<NewMedia?>  = Binding.constant(nil),
                            text: Binding< String> = Binding.constant("") ,
                            parentView: ParentView) -> some View {
//        self.modifier(MediaPicker(isPresented: isPresented,
//                                  newMedia: newMedia,
//                                  text: text ,
//                                  parentView: parentView ))
        return  self.sheet(isPresented: isPresented, onDismiss: {}) {
            OSPickerView(newMedia: newMedia,text: text)
        }
    }
}
