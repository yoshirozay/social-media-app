//
//  FailedManager.swift
//  speakEZ
//
//  Created by Ahmad naeem on 12/30/21.
//
 
import Combine
import RealmSwift

class FailedManager : FailedManagerRequiredAble{
  var internetStatusSubscriber : AnyCancellable?
  var realmSubscriber : AnyCancellable?
  var timer : Timer?
  var errorTime : Date?
  var retryAfterSeconds : TimeInterval = 5
  var failedObjectSendIds : [String] = []
  var isOnline : Bool = false
  var isSendingObject = false
  var hasResentAllObjects : Bool = false
  
  func removeAllListeners() {
      internetStatusSubscriber?.cancel()
      realmSubscriber?.cancel()
      timer?.invalidate()
  }
  
  deinit {
      removeAllListeners()
  }
}
