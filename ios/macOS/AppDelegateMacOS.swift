//
//  AppDelegateMacOS.swift
//  speakEZ (macOS)
//
//  Created by Ahmad naeem on 10/3/21.
//

import Foundation
import Cocoa
 
class AppDelegateMacOS: NSObject, NSApplicationDelegate {

     
    func applicationDidFinishLaunching(_ notification: Notification) {
         
        
    }
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}
