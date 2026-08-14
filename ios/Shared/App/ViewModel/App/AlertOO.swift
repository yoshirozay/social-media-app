//
//  AlertOO.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 12/4/21.
//

import SwiftUI

class AlertOO: ObservableObject {
//    @Published var warningDetail = ""
//    @Published var errorDetail = ""
   @Published var alertDetail = ""
   var showAlert : Bool{
       alertDetail != ""
   }
   func showAlert( _ alertDetail : String){
       withAnimation(.easeOut) {
           self.alertDetail = alertDetail
       }
   }
}
