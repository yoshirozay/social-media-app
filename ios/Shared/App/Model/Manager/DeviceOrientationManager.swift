//
//  DeviceOrientationManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 1/7/22.
//

 
import Combine
import UIKit
  
struct DeviceOrientationManager {
   
   static func lockOrientation(_ orientation: UIInterfaceOrientationMask,
                               andRotateTo rotateOrientation: UIInterfaceOrientation? = nil){
       NotificationCenter.default.post(name: Self.updateDeviceOrientation, object: orientation)
       if let rotateOrientation = rotateOrientation{
           UIDevice.current.setValue(rotateOrientation.rawValue, forKey: Constant.orientation())
       }else{
           if let currentOrientationRawValue = UIDevice.current.value(forKey: Constant.orientation()) as? Int ,
              var currentOrientation = UIInterfaceOrientation(rawValue: currentOrientationRawValue) {
               if currentOrientation == .unknown,
                  UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape == true {
                   currentOrientation = .landscapeLeft
               }
               UIDevice.current.setValue( currentOrientation.rawValue, forKey: Constant.orientation())
           }else{
               UIDevice.current.setValue( UIDevice.current.value(forKey: Constant.orientation()), forKey: Constant.orientation())
           }
       }
       
       UINavigationController.attemptRotationToDeviceOrientation()
   }
   
   private static let updateDeviceOrientation = Foundation.Notification.Name(Constant.updateDeviceOrientation())
   static let deviceOrientationPublisher = {
       NotificationCenter.default.publisher(for: Self.updateDeviceOrientation)
           .compactMap{$0.object as? UIInterfaceOrientationMask}
   }()
   
   enum Constant : String{
       case updateDeviceOrientation
       case orientation
   }
}
