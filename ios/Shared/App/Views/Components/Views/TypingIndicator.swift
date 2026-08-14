//
//  TypingIndicator.swift
//  speakEZ crossplatform (iOS)
//
//  Created by Carson O'Sullivan on 5/9/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
struct TypingIndicatorController: View {
    @StateObject var people : TypingIndicatorOO
    @State var isFromAllMessages = false
    @State var isFromOpenedPost = false
    let currentView : ViewType
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            switch currentView {
            case .OpenedConversation:
                TypingIndicatorScrollView(people: $people.openedConversation, isFromAllMessages: isFromAllMessages, themeController: themeController)
                
            case .OpenedMoment:
                TypingIndicatorScrollView(people: $people.openedMoment, isFromOpenedPost: isFromOpenedPost, themeController: themeController)
            }
        }
    }
    
}

struct TypingIndicatorScrollView: View {
    @Binding  var people: [Person]
    @State var isFromAllMessages = false
    @State var isFromOpenedPost = false
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            if people.isNotEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(people, id: \.self) { item in
                            if item.id != currentUserID {
                                TypingIndicator(person: item, isFromAllMessages: isFromAllMessages, isFromOpenedPost: isFromOpenedPost, themeController: themeController)
                            }
                        }
                    }
                }
                .frame(width: isFromAllMessages ? 200 : screenWidth - 200, height: 40, alignment: .leading)
            }
        }
    }
}

struct TypingIndicator: View {
    @State var person: Person
    @State private var numberOfTheAnimationgBall = 3
    @Environment(\.colorScheme) var colorScheme
    @State var isFromAllMessages = false
    @State var isFromOpenedPost = false
    @ObservedObject var themeController: ThemeController
    var body: some View {
        ZStack {
            themeController.theme.secondary
        HStack {
            if isFromAllMessages != true {
            ZStack {
                Circle()
                    .fill(Color.mainColorInverse)
                    .frame(width: 32, height: 32)
                WebImage(url: person.webLink)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            }
        }
            HStack(alignment: .firstTextBaseline) {
                ForEach(0..<3) { i in
                    Capsule()
                        .foregroundColor((self.numberOfTheAnimationgBall == i) ? themeController.theme.primary : themeController.theme.accent)
                        .frame(width: self.ballSize, height: (self.numberOfTheAnimationgBall == i) ? self.ballSize/3 : self.ballSize)
                }
            }
            .animation(Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.1).speed(2))
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: self.speed, repeats: true) { _ in
                    var randomNumb: Int
                    repeat {
                        randomNumb = Int.random(in: 0...2)
                    } while randomNumb == self.numberOfTheAnimationgBall
                    self.numberOfTheAnimationgBall = randomNumb
                }
        }
        }
        }
        .frame(width: isFromAllMessages ? 80 : 120, height: 40)
        .clipShape(ChatBubbleShape(direction: .left))
    }
    // MAKR: - Drawing Constants
    let ballSize: CGFloat = 15
    let speed: Double = 0.2
}

enum ViewType : String {
    case OpenedConversation
    case OpenedMoment
}

class TypingIndicatorOO: ObservableObject, CloudFunction {
    @Published var friendsDictionary = FriendsDictionary()
    @Published var openedConversation = [Person]()
    @Published var openedMoment = [Person]()
    init(type: ViewType, resourceID: String, authorID: String) {
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        friendsDictionary.getFriendsDictionary(source: .cache) {[weak self] friendsDict,error in
           
            
            if type == .OpenedConversation {
            let collectionRef = Firestore.firestore().collection("UserChats").document(userId.nonEmpty).collection("UserChatss").document(resourceID.nonEmpty).collection("IsTyping")
                self?.listener =  collectionRef.addSnapshotListener { [weak self] (snap, error) in
                guard let documentChanges = snap?.documentChanges, error == nil else {
                    print(error?.localizedDescription ?? "")
                    return
                }
                for documentChange in documentChanges {
                    if documentChange.type == .added {
                        let document = documentChange.document
                        let userId = document.documentID
                        if let friend = friendsDict[userId] {
                            self?.openedConversation.append(friend)
                        } else {
                            Person.fetchFriend(id: userId,source: .default)  {[weak self] user, error in
                                if let user = user{
                                    DispatchQueue.main.async {
                                    self?.openedConversation.append(user)
                                    }
                                }
                            }
                            }
                        }
                    if documentChange.type == .removed {
                        let document = documentChange.document
                        let userId = document.documentID
                        if let firstIndex = self?.openedConversation.firstIndex(where: {$0.id == userId}) {
                            self?.openedConversation.remove(at: firstIndex)
                        }
                        
                    }
                }
            }
        } else if type == .OpenedMoment {
            let collectionReference =
            Firestore.firestore()
                .collection("Posts")
                .document(authorID.nonEmpty)
                .collection("UserPosts")
                .document(resourceID.nonEmpty)
                .collection("IsTyping")
            self?.listener2 = collectionReference.addSnapshotListener { [weak self] (snap, error) in
                    guard let documentChanges = snap?.documentChanges, error == nil else {
                        print(error?.localizedDescription ?? "")
                        return
                    }
                    for documentChange in documentChanges {
                     
                        if documentChange.type == .added {
                         
                            let document = documentChange.document
                            let userId = document.documentID
                            if let friend = friendsDict[userId] {

                                self?.openedMoment.append(friend)
                            } else {
                                Person.fetchFriend(id: userId,source: .default)  {[weak self] user, error in
                                    if let user = user{
                                        DispatchQueue.main.async {
                                        self?.openedMoment.append(user)
                                        }
                                    }
                                }
                                }
                            }
                        if documentChange.type == .removed {
                            let document = documentChange.document
                            let userId = document.documentID
                            if let firstIndex = self?.openedMoment.firstIndex(where: {$0.id == userId}) {
                                self?.openedMoment.remove(at: firstIndex)
                            }
                            
                        }
                    }
                }
        }
        }
    }
    class func isTypingInOCCloudFunc(otherUsers: [String], chatUID: String, callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        var messageInformation = [[String: String]]()
        for item in otherUsers {
            messageInformation.append(["typingUser" : currentUserID ?? "",
                                       "otherUser": item,
                                       "chatUID": chatUID])
        }
       
        Self.call(funcName: Constant.isTypingInOC(), informationDict: messageInformation, callback: callback)
    }
    class func isNotTypingInOCCloudFunc(otherUsers: [String], chatUID: String,callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        
        var messageInformation = [[String: String]]()
        for item in otherUsers {
            messageInformation.append(["typingUser" : currentUserID ?? "",
                                       "otherUser": item,
                                       "chatUID": chatUID])
        }
       
        Self.call(funcName: Constant.isNotTypingInOC(), informationDict: messageInformation, callback: callback)
    }
    class func isTypingInOPCloudFunc(originalAuthor: String, postID: String, callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        var postInformation = [String: String]()
            postInformation = ["typingUser" : currentUserID ?? "",
                                       "originalAuthor": originalAuthor,
                                       "postID": postID]

        Self.call(funcName: Constant.isTypingInOP(), informationDict: postInformation, callback: callback)
    }
    class func isNotTypingInOPCloudFunc(originalAuthor: String, postID: String, callback : @escaping ( _  error : Error?) -> Void = {_ in }) {
        var postInformation = [String: String]()
            postInformation = ["typingUser" : currentUserID ?? "",
                                       "originalAuthor": originalAuthor,
                                       "postID": postID]
       
        Self.call(funcName: Constant.isNotTypingInOP(), informationDict: postInformation, callback: callback)
    }
    enum Constant : String {
        case isTypingInOC = "isTypingInOC-isTypingInOC"
        case isNotTypingInOC = "isNotTypingInOC-isNotTypingInOC"
        case isTypingInOP = "isTypingInOP-isTypingInOP"
        case isNotTypingInOP = "isNotTypingInOP-isNotTypingInOP"
    }
    
    var listener: ListenerRegistration?
    var listener2: ListenerRegistration?
    deinit {
        listener?.remove()
        listener2?.remove()
    }
}
