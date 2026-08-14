//
//  PermissionVM.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 6/28/22.
//

import Contacts 
import Combine
import UserNotifications
import UIKit.UIApplication
//so we should also add a array of denied premisson so in case user try to allow them we take them to settings
class PermissionVM: ObservableObject {
    @Published private(set) var permissionAccess: Set<PermissonType> = []
    let openDeviceSetting = PassthroughSubject<URL,Never>()
    private var didBecomeActiveCancellable: AnyCancellable?
    init() {
        checkGrantedPermissions()
        didBecomeActiveCancellable = NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification).sink { [weak self] _ in
                self?.checkGrantedPermissions()
            }
    }
    func checkGrantedPermissions(){
        if CNContactStore.authorizationStatus(for: .contacts) == .authorized{
            addPermisson(.contacts)
        }
        UNUserNotificationCenter.current().getNotificationSettings { [weak self]  settings in
            switch settings.authorizationStatus {
            case .authorized:
                self?.addPermisson(.pushNotifications)
            case .denied, .provisional, .notDetermined,.ephemeral:
                print("Do something according to status")
            @unknown default:
                return
            }
        }
    }
    func addPermisson(_ type: PermissonType){
        DispatchQueue.main.async { [weak self] in
            self?.permissionAccess.insert(type)
        }
    }
    
    func askForPermissonOf(_ type: PermissonType) {
        switch type {
        case .contacts:
            if CNContactStore.authorizationStatus(for: .contacts) == .denied{
                openDeviceSettings()
            }else{
                CNContactStore().requestAccess(for: .contacts){ [weak self] (granted, error) in
                    self?.requestResponse(type: type, granted: granted, error: error)
                }
            }
        case .pushNotifications:
            UNUserNotificationCenter.current().getNotificationSettings { [weak self]  settings in
                if settings.authorizationStatus == .denied {
                    self?.openDeviceSettings()
                }else{
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] (granted, error) in
                        self?.requestResponse(type: type, granted: granted, error: error)
                    }
                }
            }
        }
    }
    
    func requestResponse(type: PermissonType ,granted: Bool,error: Error?){
        if granted{
            addPermisson(type)
        }
        print("\(type()) permission = ", error?.localizedDescription ?? "was successfull")
    }
    
    func openDeviceSettings(){
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            DispatchQueue.main.async { [weak self] in
                self?.openDeviceSetting.send(settingsUrl)
            }
        }
    }
    deinit {
        didBecomeActiveCancellable?.cancel()
    }
}
