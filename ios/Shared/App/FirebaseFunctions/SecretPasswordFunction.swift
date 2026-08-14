//
//  SecretPasswordFunction.swift
//  speakEZ (iOS)
//
//  Created by Carson O'Sullivan on 7/9/21.
//
import SwiftUI
import Firebase
import FirebaseFunctions

class SecretPasswordFunction: ObservableObject {
    @Published private var isOngingRequest = false
    var showLoadingCircle : Bool{
        isOngingRequest
    }
    class var savedSecretPassword: String? {
        get {
            UserDefaults.standard.string(forKey:  Key.secretPassword.rawValue) ?? "default value for version 2.04"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.secretPassword.rawValue)
        }
    }
    
    class func setDynamiclinkAsSecretPasswordIfNone(){
        if  SecretPasswordFunction.savedSecretPassword == nil{
            SecretPasswordFunction.savedSecretPassword = Key.dynamicLink()
        }
    }
    
    func checkSecretPassword( _ password: String) {
        isOngingRequest = true
        Self.checkSecretPassword(password){ [weak self] error in
            self?.isOngingRequest = false
        }
    }
    
    class func checkSecretPassword( _ password: String,callback : @escaping (_  error : Error?) -> Void) {
        let passwordDetails = password.lowercased()
        Functions.functions().httpsCallable("doesPasswordExist-doesPasswordExist").call(passwordDetails) { (result, error) in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    print("\(error)")
                    _ = FunctionsErrorCode(rawValue: error.code)
                    _ = error.localizedDescription
                    _ = error.userInfo[FunctionsErrorDetailsKey]
                }
            }
            print("123 \(String(describing: result?.data))")
            
            if let data = result?.data,
               let dict = data as? [String:Any],
               let firstValue = dict.first?.value as? Int,
               firstValue == 1 {
                savedSecretPassword = passwordDetails
            }
            callback(error)
        }
        
    }
    
    enum Key: String {
        case secretPassword
        case dynamicLink
    }
    
}

