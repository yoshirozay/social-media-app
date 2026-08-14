//
//  ReachabilityService.swift
//  speakEZ (iOS)
//
//  Created by Ahmad naeem on 8/19/21.
//
 
 import Combine
 import Network

enum NetworkType : String {
     case wifi
     case cellular
     case loopBack
     case wired
     case other
 }

final class ReachabilityService: ObservableObject {
    
    @Published var reachabilityInfos: NWPath?
    @Published var typeOfCurrentConnection:  NWInterface.InterfaceType?
    let networkAvailabilityPublisher =  CurrentValueSubject<Bool,Never>(false)
    private let monitor = NWPathMonitor()
    private let backgroundQueue = DispatchQueue.global(qos: .background)
    private (set) var isNetworkAvailable: Bool = false {
        didSet{
            networkAvailabilityPublisher.send(isNetworkAvailable)
        }
    }
    
    func toggleisNetworkAvailable(){
        isNetworkAvailable = !isNetworkAvailable
        }
    
    init() {
        
        monitor.pathUpdateHandler = { [weak self] path in
            self?.reachabilityInfos = path
            
            var statusString = "default"
            
            switch path.status {
            case .satisfied:
                statusString = "satisfied"
                self?.isNetworkAvailable = true
                break
            case .unsatisfied:
                statusString = "unsatisfied"
                
                if #available(iOS 14.2, *) {
                    var reasonString = ""
                    switch path.unsatisfiedReason {
                    case .notAvailable:
                        reasonString = "notAvailable"
                        break
                    case .cellularDenied:
                        reasonString = "cellularDenied"
                        break
                    case .wifiDenied:
                        reasonString = "wifiDenied"
                        break
                    case .localNetworkDenied:
                        reasonString = "localNetworkDenied"
                        break
                    @unknown default:
                        reasonString = "default"
                    }
//                    print("ReachabilityService: unsatisfiedReason: ",reasonString)
                } else {
                    // Fallback on earlier versions
                }
                
                self?.isNetworkAvailable = false
                break
            case .requiresConnection:
                statusString = "requiresConnection"
                self?.isNetworkAvailable = false
                break
            @unknown default:
                self?.isNetworkAvailable = false
            }
//           print("ReachabilityService: ",statusString)
            
            let allNetworks = NWInterface.InterfaceType.allNetworksTypes
            
            for network in allNetworks {
                if path.usesInterfaceType(network) {
                    self?.typeOfCurrentConnection = network
                    break
                }
            }
            
//            print("ReachabilityService: typeOfCurrentConnection ", self?.typeOfCurrentConnection)
//            print("ReachabilityService: availableInterfaces ",  path.availableInterfaces.map({$0.type}))
            
        }
        
        monitor.start(queue: backgroundQueue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    static let shared = ReachabilityService()
    static func configure(){
        let _ = ReachabilityService.shared
    }
}

 private extension ReachabilityService {

 }
// Usage:
//
// In your view model:
//
// private let reachability = ReachabilityService()
//
// init() {
//     reachability.$isNetworkAvailable.sink { [weak self] isConnected in
//         self?.isConnected = isConnected ?? false
//     }.store(in: &cancelBag)
// }
// In your controller:
//
// viewModel.$isConnected.sink { [weak self] isConnected in
//     print("isConnected: \(isConnected)")
//     DispatchQueue.main.async {
//         //Update your UI in here
//     }
// }.store(in: &bindings)

 
extension NWInterface.InterfaceType {
    static var allNetworksTypes : [NWInterface.InterfaceType] = {
           [.wifi,.cellular,.loopback,.wiredEthernet,.other]
        }()
}
