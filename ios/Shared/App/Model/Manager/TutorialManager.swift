//
//  TutorialManager.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/8/21.
//

import Foundation

class TutorialManager {
    
    private init() { }
    
    static let shared = TutorialManager()
    
    var tutorialNumber: Int {
        get {
            return UserDefaults.standard.integer(forKey: Key.tutorialNumber())
        }
        set {
            UserDefaults.standard.set(newValue , forKey: Key.tutorialNumber())
        }
    }
    
    var isOngoing : Bool {
        tutorialNumber < 21 && tutorialNumber > 0
    }
    
      func start() {
        tutorialNumber = 1
    }
    
      func complete() {
        tutorialNumber = 0
      }
    
    func restartIfNotCompleted() {
        if isOngoing {
            start()
        }else{
            complete()
        }
    }
    
      func skip() {
        tutorialNumber = 100
    }
    
    enum Key: String {
        case tutorialNumber
    }
}
extension UserDefaults {
    @objc dynamic var tutorialNumber: Int {
        return integer(forKey: TutorialManager.Key.tutorialNumber())
    }
}
