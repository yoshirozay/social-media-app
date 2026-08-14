//
//  QRCodeManager.swift
//  QRCodeTest
//
//  Created by Ahmad naeem on 10/28/21.
//

import Foundation
import UIKit

class QRCodeManager {
    static let shared  = QRCodeManager()
    var ciContext = CIContext()
    
//    func generateQRCode(for string: String) -> UIImage? {
//        let data = string.data(using: String.Encoding.utf8)
//        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
//        qrFilter.setValue(data, forKey: "inputMessage")
//        
//        if let ciImage = qrFilter.outputImage ,
//           let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent){
//            let uiImage = UIImage(cgImage: cgImage)
//            return uiImage
//        }
//        
//        return nil
//    }
    
     func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 19, y: 19)
            
            if let output = filter.outputImage?.transformed(by: transform),
                let cgImage = ciContext.createCGImage(output, from: output.extent) {
                let image = UIImage(cgImage: cgImage)
                return image
            }
        }
        
        return nil
    }
    //let image = generateQRCode(from: "Hacking with Swift is the best iOS coding tutorial I've ever read!")
}
class QRToString {

    func string(from image: UIImage) -> String? {

     
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                        context: nil,
                                        options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
            let ciImage = CIImage(image: image),
            let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else {
                return nil
        }
        var qrAsString = ""
        for feature in features {
            guard let indeedMessageString = feature.messageString else {
                continue
            }
            qrAsString += indeedMessageString
        }

        return qrAsString
    }
}
