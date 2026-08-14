//
//  UITableView+Extension.swift
//  speakEZ
//
//  Created by Ahmad naeem on 10/6/21.
//

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
 
extension UITableView {
 func scrollToBottom()  {
#if os(macOS)
        self.scrollRowToVisible( 0)
#elseif os(iOS)
     if self.numberOfSections > 0{
         self.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false) 
     }
#endif
   }
}
