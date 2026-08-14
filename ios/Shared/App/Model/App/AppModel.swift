//
//  AppModel.swift
//  SpeakEZ (no firebase)
//
//  Created by Carson O'Sullivan on 1/15/21.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImage.SDImageCache
 

struct Person: Identifiable, Hashable {
    // we do not need this as all the users have AccountCreationDate but for now just let it be
    static var defaultAccountCreationDate : Timestamp = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateStr = "July 15, 2021"
        let date = dateFormatter.date(from: dateStr)!
        let time = Timestamp(date: date)
        return time
    }()
     
    init(id: String, username: String, name: String, bio: String, imageurl: String, webLink: URL? = nil,token : String = "", school: String = "", accountCreationDate : Timestamp, profileCircle: Color, doesWantAllNotifications: Bool = true, anonymousMode: Bool = false ) {
        self.id = id
        self.username = username
        self.name = name
        self.bio = bio
        self.imageurl = imageurl
        self.webLink = webLink
        self.token = token
        self.school = school
        self.accountCreationDate = accountCreationDate
        self.profileCircle = profileCircle
        self.doesWantAllNotifications = doesWantAllNotifications
        self.anonymousMode = anonymousMode
    }
    //init to get an empty Object
    init(id : String) {
        self.id = id
        self.username = ""
        self.name = ""
        self.bio = ""
        self.imageurl = ""
        self.webLink = nil
        self.token = ""
        self.school = ""
        self.accountCreationDate = Person.defaultAccountCreationDate
        self.profileCircle = Color.mainColor.opacity(0.00)
        self.doesWantAllNotifications = true
        self.anonymousMode = false
    }
    
    func isUserEqual(_ user : Person) -> Bool {
        id == user.id &&
        username == user.username  &&
        name == user.name &&
        bio == user.bio &&
        imageurl == user.imageurl &&
        webLink == user.webLink  &&
        token == user.token &&
        school == user.school &&
        accountCreationDate.isTimeEqual(user.accountCreationDate) &&
        doesWantAllNotifications == user.doesWantAllNotifications &&
        profileCircle == user.profileCircle &&
        anonymousMode == user.anonymousMode
    }
    
    private (set) var id : String
    private (set) var username: String
    private (set) var name: String
    private (set) var bio: String
    private (set) var imageurl: String
    private (set) var webLink: URL?
    private (set) var token : String = ""
    private (set) var school : String = ""
    private (set) var accountCreationDate : Timestamp
    private (set) var profileCircle : Color
    private (set) var doesWantAllNotifications : Bool = true
    private (set) var anonymousMode : Bool = false

    
    //only used when current user updates his profile pic
    var tempWebLink: URL?
    //used when we want to show the webLink image in a view
    var profilePicLink: URL?{
        tempWebLink == nil ? webLink : tempWebLink
    }
    
    private (set) var phoneNumber : String?
         //FIXME: - now replace this with getPersonFromUserInfo as every user now have weblink
        init (userId : String? = nil,documentData : [String : Any]) {
            let dict = documentData
            self.username = dict["username"] as? String ?? ""
            self.name = dict["name"] as? String ?? ""
            self.bio = dict["bio"] as? String ?? ""
            self.imageurl = dict["imageurl"] as? String ?? ""
            self.token = dict["token"] as? String ?? ""
            self.school = dict["school"] as? String ?? ""
            self.doesWantAllNotifications = dict["doesWantAllNotifications"] as? Bool ?? true
            let profileCircleName = dict["profileCircle"] as? String ?? ""
            self.accountCreationDate = dict["accountCreationDate"] as? Timestamp ?? Self.defaultAccountCreationDate
            self.id = dict["uid"] as? String ?? ""
            if let userId = userId {
                self.id = userId
            }
            self.profileCircle = getBackgroundColor(backgroundColor: profileCircleName)
            self.webLink = URL(string: dict["webLink"] as? String ?? "") 
            self.phoneNumber =  dict["phoneNumber"] as? String
            self.anonymousMode =  dict["anonymousMode"]  as? Bool ?? false
        }
    
    static func getPersonFromUserInfo(userId : String? = nil, documentData : [String : Any], callback : @escaping (_ friend :  Person?,  _ error : Error?) -> Void) {
         var user = Person(userId: userId, documentData: documentData)
        if let _ = user.webLink{
            callback(user,nil)
        }else{
            let photoRef = Storage.storage().reference().child("\(user.id)/profilePhoto.jpeg")
            photoRef.downloadURL { (url, error) in
                if let webLink = url {
                    user.webLink = webLink
                    callback(user,nil)
                     //FIXME: - for now we will just use the UpdateProfileFunction but in fufure we might not need it.
                    UpdateProfileFunction.updateProfileWebLink(path: photoRef.fullPath, userId: user.id)
                }else if let error = error {
                    callback(nil,error)
                }
            }
        }
    }
    
    //FIXME: - we will remove UserContactsVM.getRandomMobileNumber() after we implement the cloud func to add phone number
//FIXME: - so in future i think we should make this private, as we will not show this in the app. we will only use this to get user contact friends.

}
extension Person {
//    username
    static func fetchFriend(id : String, source: FirestoreSource = .default, callback: @escaping (Person?, Error?) -> Void){
        let docRef = Firestore.firestore().collection("UserInfo").document(id.nonEmpty)
        docRef.getDocument(source: source) { (document, error) in
            if let documentData = document?.data() {
                Person.getPersonFromUserInfo(documentData: documentData, callback: callback)
            }else{
                callback(nil,error)
            }
        }
    }
    //Cache then Network (CTN)
    static func fetchUserUsingCTN(id : String, callback: @escaping (Person?, Error?) -> Void){
        fetchFriend(id: id, source: .cache) { user, _ in
            if let user = user {
                callback(user,nil)
            }else{
                Person.fetchFriend(id: id, source: .server, callback : callback)
            }
        }
    }
    
    ///so we will also fetch from the server to check is the user changed or not. if a user has changed then we will again send callback with aResend been true
    static func fetchLatestUserUsingCTN(id : String, callback: @escaping (_ success : Person?, _ aResend : Bool?, _  error : Error?) -> Void){
        fetchFriend(id: id, source: .cache) { user, _ in
            if let user = user {
                callback(user,false,nil)
                DispatchQueue.global(qos: .background).async  {
                    fetchFriend(id: id, source: .server) { latestPerson, error in
                        if let latestPerson = latestPerson,
                           user != latestPerson{
                            DispatchQueue.main.async {
                                callback(latestPerson,true,nil)
                            }
                        }
                    }
                }
            }else{
                Person.fetchFriend(id: id, source: .server){ user, error in
                    if let user = user{
                        callback(user,false,nil)
                    }else{
                        callback(nil,nil,error)
                    }
                }
            }
        }
    }
    
    ///fetch user using username
    static func fetch(username : String, source: FirestoreSource = .default, callback: @escaping (Person?, Error?) -> Void){
        let docRef = Firestore.firestore().collection("UserInfo")
            .whereField("username", isEqualTo: username)
            .limit(to: 1)
        docRef.getDocuments(source: source) { (snap, error) in
            if let documentData = snap?.documents.first?.data() {
                Person.getPersonFromUserInfo(documentData: documentData, callback: callback)
            }else{
                callback(nil,error)
            }
        }
    }
    //Cache then Network (CTN)
    static func fetchUsingCTN(username : String, callback: @escaping (Person?, Error?) -> Void){
        fetch(username: username, source: .cache) { user, _ in
            if let user = user {
                callback(user,nil)
            }else{
                fetch(username: username, source: .server, callback : callback)
            }
        }
    }
}
 
 func getBackgroundColor(backgroundColor: String) -> Color {
     guard backgroundColor.isNotEmpty else {  return .clear }
    var color: Color
    let circleColor = backgroundColor
    switch circleColor {
    case "yellow":
        color = .yellow
    case "orange":
        color = .orange
    case "white":
        color = .mainColor
    case "blue":
        color = .blue
    case "red":
        color = .red
    case "purple":
        color = .purple
    case "pink":
        color = .pink
    case "green":
        color = .green
    case "black":
        color = .mainColor
    case "mainColor":
        color = .mainColor
    case "aqua":
        color = .speakerBlue
    case "greenBlue":
        color = .white
    case "purpleBlue":
        color = .blue
    case "blackWhite":
        color = .blue
    case "pinkRed":
        color = .blue
    case "pinkPurple":
        color = .blue
    case "aliceBlue":
        color = .aliceBlue
    case "alloyOrange":
        color = .alloyOrange
    case "arylideYellow":
        color = .arylideYellow
    case "babyBlue":
        color = .babyBlue
    case "blackCoral":
        color = .blackCoral
    case "bleuDeFrance":
        color = .bleuDeFrance
    case "blizzardBlue":
        color = .blizzardBlue
    case "bloodRed":
        color = .bloodRed
    case "blueBell":
        color = .blueBell
    case "bluePigment":
        color = .bluePigment
    case "brightMaroon":
        color = .brightMaroon
    case "brinkPink":
        color = .brinkPink
    case "burntSienna":
        color = .burntSienna
    case "cafeAuLait":
        color = .cafeAuLait
    case "cafeNoir":
        color = .cafeNoir
    case "cambridgeBlue":
        color = .cambridgeBlue
    case "caribbeanGreen":
        color = .caribbeanGreen
    case "celadonGreen":
        color = .celadonGreen
    case "charmPink":
        color = .charmPink
    case "chinaRose":
        color = .chinaRose
    case "chineseRed":
        color = .chineseRed
    case "cornflowerBlue":
        color = .cornflowerBlue
    case "cottonCandy":
        color = .cottonCandy
    case "cyberGrape":
        color = .cyberGrape
    case "darkTurqoise":
        color = .darkTurqoise
    case "deepPurple":
        color = .deepPurple
    case "dodgerBlue":
        color = .dodgerBlue
    case "earthYellow":
        color = .earthYellow
    case "etonBlue":
        color = .etonBlue
    case "fireEngineRed":
        color = .fireEngineRed
    case "flourescentBlue":
        color = .flourescentBlue
    case "forestGreen":
        color = .forestGreen
    case "frenchMauve":
        color = .frenchMauve
    case "frenchSkyBlue":
        color = .frenchSkyBlue
    case "greenSheen":
        color = .greenSheen
    case "indigoDye":
        color = .indigoDye
    case "ivory":
        color = .ivory
    case "juneBud":
        color = .juneBud
    case "khakiWeb":
        color = .khakiWeb
    case "laurelGreen":
        color = .laurelGreen
    case "lavenderBlue":
        color = .lavenderBlue
    case "lavenderFloral":
        color = .lavenderFloral
    case "lightCyan":
        color = .lightCyan
    case "magentaDye":
        color = .magentaDye
    case "magentaHaze":
        color = .magentaHaze
    case "magentaProcess":
        color = .magentaProcess
    case "mandarin":
        color = .mandarin
    case "mangolia":
        color = .mangolia
    case "maximumBluePurple":
        color = .maximumBluePurple
    case "maximumGreenYellow":
        color = .maximumGreenYellow
    case "maximumYellowRed":
        color = .maximumYellowRed
    case "mediumPurple":
        color = .mediumPurple
    case "mellowApricot":
        color = .mellowApricot
    case "middleRed":
        color = .middleRed
    case "mintGreen":
        color = .mintGreen
    case "oldLavender":
        color = .oldLavender
    case "orangePeel":
        color = .orangePeel
    case "oxfordBlue":
        color = .oxfordBlue
    case "peachPuff":
        color = .peachPuff
    case "pearlyPurple":
        color = .pearlyPurple
    case "periwinkleCrayola":
        color = .periwinkleCrayola
    case "persianGreen":
        color = .persianGreen
    case "plumWeb":
        color = .plumWeb
    case "raisinBlack":
        color = .raisinBlack
    case "rawSienna":
        color = .rawSienna
    case "romanSilver":
        color = .romanSilver
    case "roseEbony":
        color = .roseEbony
    case "rosePink":
        color = .rosePink
    case "russianViolet":
        color = .russianViolet
    case "safetyYellow":
        color = .safetyYellow
    case "sandyBrown":
        color = .sandyBrown
    case "sizzlingRed":
        color = .sizzlingRed
    case "skyBlueCrayola":
        color = .skyBlueCrayola
    case "springGreen":
        color = .springGreen
    case "tartOrange":
        color = .tartOrange
    case "taupeGray":
        color = .taupeGray
    case "tealBlue":
        color = .tealBlue
    case "upForestGreen":
        color = .upForestGreen
    case "vividSkyBlue":
        color = .vividSkyBlue
 
    default:
        color = .clear
    }
    return color

}

public var iOS15: Bool = {
       guard #available(iOS 15, *) else {
           return false
       }
       return true
   }()
public var iOS16: Bool = {
       guard #available(iOS 16, *) else {
           return false
       }
       return true
   }()

extension Person{
    
    struct Preloaded {
        
        static func getTristan( callback : @escaping (Person?, Error?) -> Void )   {

            let webLinkString = "https://firebasestorage.googleapis.com/v0/b/YOUR_FIREBASE_PROJECT_ID.appspot.com/o/ctgg158KOnajMBuFZ5GyHLyRYPE3%2FprofilePhoto.jpeg?alt=media&token=459f8c00-dae0-4345-b00c-aacc2c486d58"
            if let image = UIImage(named: "TristanProfilePhoto2"), let url = URL(string: webLinkString){
                SDImageCache.shared.add(image: image, url: url)
            }
            var userDocumentData : [String : Any] = [:]
            userDocumentData["webLink"] = webLinkString
            userDocumentData["accountCreationDate"] = Timestamp(seconds: 1626386178, nanoseconds: 855000000)
            userDocumentData["username"] = "@tristan"
            userDocumentData["imageurl"] = "ctgg158KOnajMBuFZ5GyHLyRYPE3.png"
            userDocumentData["uid"] = "ctgg158KOnajMBuFZ5GyHLyRYPE3"
            userDocumentData["createdProfile"] =  1
            userDocumentData["token"] = "eshNK3rstUqVseiYOGLBqc:APA91bEjbcFGzogWmPbZ9cOHOMs5FA-amW1dB2e-L_6Sqp38ahTW4XrpgLRcQj5WdSlgk9-YTAxNb_ub74CdJkyPdqtiicRMAB6j29yK-9UXoiWT8l_aQPQNl-Nzf4Iub6jwY-Wj2uzW"
            
            userDocumentData["bio"] = " the goat 🐐"
            userDocumentData["name"] = "Tristan"
            Person.getPersonFromUserInfo(documentData: userDocumentData,callback : callback)
        }
    }
}
