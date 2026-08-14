//
//  UserContactsVM.swift
//  testingSwiftUI
//
//  Created by Ahmad naeem on 3/3/22.
//

import Foundation
import SwiftUI
import Contacts
import FirebaseFirestore
import FirebaseFirestoreSwift
 
struct FirebaseUserContact {
    var contact : Contact
    var user : Person
}
///only for  mobile phone numbers
struct Contact {
    init(givenName: String,phoneNumber : String) {
        self.firstName = givenName
        self.phoneNumber = "+"+phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
    var firstName: String
    var phoneNumber : String
}

extension Contact: Identifiable, Hashable ,Equatable {
    var id : String { phoneNumber }
    func hash(into hasher: inout Hasher) {
        hasher.combine(phoneNumber)
    }
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs.phoneNumber == rhs.phoneNumber
    }
}
 
   
