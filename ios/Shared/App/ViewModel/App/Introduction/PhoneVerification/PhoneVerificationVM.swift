//
//  PhoneVerificationVM.swift
//  speakEZ
//
//  Created by Ahmad naeem on 3/3/22.
//

import Foundation  
import FirebaseAuth
import Combine
/*
 so when we will call for verification then we will make sure that we add a plus before the entered phone number. so we will do query for the equal for in. so when we will save the number we will romove all speacial character other then the plus.
 */
class PhoneVerificationVM : ObservableObject {
    @Published var phoneNumber : String = ""
    @Published var verificationCode : String = ""
    @Published var countryCode: String = ""
    @Published var verificationID  : String = ""
    
//    func sendCode(callback : @escaping ( _  error : Error?) -> Void) {
//        guard !phoneNumber.isEmpty,currentUser?.phoneNumber == nil else { return }
//        let countryCode = countryCode.isEmpty ? "1" : countryCode
//        let phoneNumber = "+"+countryCode+phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
//        PhoneAuthProvider.provider()
//            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
//                 if let verificationID = verificationID{
//                    print(" verificationID \(verificationID)")
//                    self.verificationID = verificationID
//                }
//                callback(error)
//            }
//    }
    func sendCode(callback : @escaping ( _  error : Error?) -> Void) {
        guard !phoneNumber.isEmpty else { return }
//        guard !phoneNumber.isEmpty else { return }
        let phoneNumber = phoneNumber.trimWhitespacesAndNewlines()
        var joinedPhoneNumber = phoneNumber
        if phoneNumber.first != "+" {
            let countryCode = countryCode.isEmpty ? "1" : countryCode
            joinedPhoneNumber = "+"+countryCode+phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        }
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(joinedPhoneNumber, uiDelegate: nil) { verificationID, error in
                 if let verificationID = verificationID{
                    print(" verificationID \(verificationID)")
                    self.verificationID = verificationID
                }
                callback(error)
            }
    }
    func signIn(callback : @escaping ( _  error : Error?) -> Void) {
        
        guard !verificationID.isEmpty,
              !verificationCode.isEmpty,
              currentUser?.phoneNumber == nil,
        let userId = currentUserID else { return }
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        Auth.auth().currentUser?.link(with: credential) { authResult, error in
            if let error = error {
                callback(error)
            }else{
                print("user phone number verified successfully")
                if let phoneNumber = Auth.auth().currentUser?.phoneNumber {
                    Self.phoneNumberPublisher.send(phoneNumber)
                    EditProfileFunction.updatePhoneNumberOf(userId: userId, phoneNumber: phoneNumber) { error in
                        print("updatePhoneNumberOf was called = : \(error.descriptionIfAny)")
                    } 
                    callback(nil)
                    
                }else {
                    callback("CurrentUser PhoneNumber not found".asError)
                }
            }
        }
    }
    
    static var phoneNumberPublisher =  PassthroughSubject<String?,Never>()
}

class UserPhoneTestVM : ObservableObject {
    @Published var userPhoneNumber : String?
    var sub :  AnyCancellable?
    init() {
        if let phoneNumber = Auth.auth().currentUser?.phoneNumber{
            userPhoneNumber = phoneNumber
            return
        }
        sub =  PhoneVerificationVM.phoneNumberPublisher.sink { [weak self]  phoneNumber in
            if let phoneNumber = phoneNumber  {
                self?.userPhoneNumber = phoneNumber
            } else {
                self?.userPhoneNumber = nil
            }
        }
    }
    
    deinit {
        sub?.cancel()
    }
    
}
