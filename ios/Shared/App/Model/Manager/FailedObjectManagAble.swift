//
//  FailedObjectManagAble.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 9/16/21.
//
  
import Combine
import RealmSwift

  
protocol FailedManagerRequiredAble : AnyObject {
    var internetStatusSubscriber : AnyCancellable? { get set }
    var realmSubscriber : AnyCancellable? { get set }
    var timer : Timer? { get set }
    var errorTime : Date? { get set }
    var retryAfterSeconds : TimeInterval { get set }
    var failedObjectSendIds : [String] { get set }
    var isOnline : Bool { get set }
    var isSendingObject : Bool { get set }
    var hasResentAllObjects : Bool { get set }
    func removeAllListeners()
}

protocol FailedObjectManagAble : FailedManagerRequiredAble {
  
    func addNetworkAvailabilityListener()
    func startResendingFailedObjects()
    func reSendObject()
    func didTriedToManyTimes() -> Bool
    func canSendObject() -> Bool
    
    associatedtype RealmFailAbleObject : RealmFailAble
    associatedtype ResendAbleObject : OldestObjectFetchAble
    
    func sendObjectUsingCloudFunc(obj : ResendAbleObject.RawResendAbleObject)
    static func configure() 
}

extension FailedObjectManagAble {
    internal func addNetworkAvailabilityListener() {
        
        internetStatusSubscriber = ReachabilityService.shared.networkAvailabilityPublisher.sink { [weak self] isOnline in
            //            print("isOnline = ",isOnline)
            self?.isOnline = isOnline
            self?.startResendingFailedObjects()
        }
    }
    
    func startResendingFailedObjects() {
        guard !isSendingObject , isOnline else { return }
        if let errorTime = self.errorTime {
            let diff = Date() - errorTime
            if diff <  retryAfterSeconds {
                reSendObject()
            }else{
                //                isSendingMsssage = true
                timer = Timer.scheduledTimer(withTimeInterval: diff, repeats: false) {[weak self] (_) in
                    self?.reSendObject()
                }
            }
        }else{
            reSendObject()
        }
    }
    
    func reSendObject() {
//        print("reSendObject")
        guard !hasResentAllObjects ,
              let rawObject = ResendAbleObject.getOldestFromRealm() else {
            internetStatusSubscriber?.cancel()
            isSendingObject = false
            hasResentAllObjects = true
            errorTime = nil
            startListeningToLatestFailedObjects()
            return
        }
        
        guard canSendObject()  else {
            isSendingObject = false
            return
        }
        
        guard !didTriedToManyTimes() else {
            isSendingObject = false
            return
        }
      
        isSendingObject = true
        if rawObject.isCorrupted {
            DispatchQueue.main.async { self.removeObject(obj: rawObject) }
        }else{
            sendObjectUsingCloudFunc(obj: rawObject)
        }
    }
    
    func startListeningToLatestFailedObjects() {
        
        DispatchQueue.main.async {
            var resultCount = 0
            
            guard let results = RealmFailAbleObject.getAllFailedObjectsResult() else { return  }
            self.realmSubscriber = results.changesetPublisher.sink {[weak self] changes in
                var updatedResultsCount = 0
                
                switch changes {
                case let .initial(initialResults):
                    updatedResultsCount = initialResults.count
                case let .update(updatedResults, _, _, _):
                    updatedResultsCount = updatedResults.count
                case let .error(error):
                    assert(false, " results.changesetPublisher = \(error.localizedDescription) ")
                }
                if resultCount < updatedResultsCount , let self = self , !self.isSendingObject{
                    self.hasResentAllObjects = false
                    self.addNetworkAvailabilityListener()
                }
                resultCount = updatedResultsCount
            }
        }
        
    }
    
    internal func didTriedToManyTimes() -> Bool {
        let retriedCount = failedObjectSendIds.count - failedObjectSendIds.getSet().count
        if retriedCount > 2 {
            retryAfterSeconds += 5
            if retriedCount > 5 {
                //we will just stop the whole process if app has tried more ten 10 times
                if retriedCount < 10  {
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(withTimeInterval: retryAfterSeconds, repeats: false) {[weak self] (_) in
                        self?.reSendObject()
                    }
                }else{
                    assert(false, "retriedCount has reached 10 times")
                }
                return true
            }
        }
        return false
    }
    
    
    internal func canSendObject() -> Bool {
        guard isOnline else {
            errorTime = Date()
            return false
        }
        return true
    }
    func removeAllListeners() {
        internetStatusSubscriber?.cancel()
        realmSubscriber?.cancel()
        timer?.invalidate()
    }
    
}

extension FailedObjectManagAble {
    
    func cloudFuncCallBackResponse(obj: ResendAbleObject.RawResendAbleObject,error:  Error?) -> Void {
        if let error = error {
            print( "reSendpost Error = ", error.localizedDescription)
            failedObjectSendIds.append(obj.objectKey)
            reSendObject()
        }else{
            removeObject(obj: obj)
        }
    }
    
   func removeObject(obj: ResendAbleObject.RawResendAbleObject) {
       let objectKey = obj.objectKey
       obj.removeFailedObjectsFromCache() {[weak self] error in
           if let error = error {
               print( "reSendpost Error = ", error.localizedDescription)
           }else{
               self?.failedObjectSendIds.removeAll(where: {$0 == objectKey})
           }
           self?.reSendObject()
       }
   }
}
