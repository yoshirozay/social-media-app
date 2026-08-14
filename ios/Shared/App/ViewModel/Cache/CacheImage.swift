//
//  CacheImage.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 4/17/21.
//
 
import SwiftUI
import Firebase
import SDWebImageSwiftUI
import SDWebImage
 

class CacheImage : ObservableObject {
    @Environment(\.colorScheme) var colorScheme
    @Published private (set) var image : UIImage  = CacheImage.placeholderImage  
    init(photoURL : URL?, lightOrDark: Color) {
        image = UIColor(lightOrDark).image()
        guard let photoURL = photoURL else { return  }
        DispatchQueue.global(qos: .userInitiated).async  {
            SDWebImageManager.shared.loadImage(with: photoURL,  progress: nil) {[weak self]  image, data, error, cachyType, bol, url in
                if let newImage = image {
                    DispatchQueue.main.async {
                            self?.image = newImage
                    }
                }
            }
        }
    }
    
    static var placeholderImage : UIImage = {
        
        let img = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1969228732).image()
        return img
    }()
    
    static var maxImageSize : Int = 10_000_000
    
    deinit {
     
    }
} 
 
