//
//  Extensions.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 5/12/21.
//
 
import UIKit

extension UIScreen {
  static var width : CGFloat {
       return UIScreen.main.bounds.width
   }
  static var height : CGFloat {
       return UIScreen.main.bounds.height
   }
}  

extension UIApplication {
    class func getSafeAreaTopInsets() -> CGFloat {
        if let safeAreaTopInsets = UIApplication.shared.windows.first?.safeAreaInsets.top {
            return safeAreaTopInsets
        }
        return 0
    }

    class func getSafeAreaBottomInsets() -> CGFloat {
        if let safeAreaTopInsets = UIApplication.shared.windows.first?.safeAreaInsets.bottom {
            return safeAreaTopInsets
        }
        return 0
    }
}

extension UIColor {
   func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
       return UIGraphicsImageRenderer(size: size).image { rendererContext in
           self.setFill()
           rendererContext.fill(CGRect(origin: .zero, size: size))
       }
   }
}

extension UIImage {
    
   //MARK:- scalePreservingAspectRatio
   func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
       // Determine the scale factor that preserves aspect ratio
       let widthRatio = targetSize.width / size.width
       let heightRatio = targetSize.height / size.height
       
       let scaleFactor = min(widthRatio, heightRatio)
       
       // Compute the new image size that preserves aspect ratio
       let scaledImageSize = CGSize(
           width: size.width * scaleFactor,
           height: size.height * scaleFactor
       )
       let format = imageRendererFormat
       format.opaque = true
       format.preferredRange = .standard//self.imageRendererFormat.preferredRange
       // Draw and return the resized UIImage
       let renderer = UIGraphicsImageRenderer(
           size: scaledImageSize,format : format
       )

       let scaledImage = renderer.image { _ in
           self.draw(in: CGRect(
               origin: .zero,
               size: scaledImageSize
           ))
       }
      
       return scaledImage
   }
}
