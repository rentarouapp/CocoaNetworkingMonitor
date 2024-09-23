// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Network
import Combine

@objcMembers
public final class CocoaNetworkingMonitor: NSObject {
    public static let DidChangeStatusNotificationName = NSNotification.Name(rawValue: "CocoaNetworkingMonitorChangeStatusNotification")
    public static let shared = CocoaNetworkingMonitor()
    
    private override init() {}
    
    private var nwPathMonitor = NWPathMonitor()
    private let monitoringSubject = PassthroughSubject<Bool, Never>()
    
}

// MARK: - Status Properties
extension CocoaNetworkingMonitor {
    public var isReachable: Bool {
        nwPathMonitor.currentPath.status == .satisfied
    }
    
    public var isReachableViaWifi: Bool {
        return isReachable && nwPathMonitor.currentPath.usesInterfaceType(.wifi)
    }
    
    public var isReachableViaCellular: Bool {
        return isReachable && nwPathMonitor.currentPath.usesInterfaceType(.cellular)
    }
    
    public var isReachableViaEthernet: Bool {
        return isReachable && nwPathMonitor.currentPath.usesInterfaceType(.wiredEthernet)
    }
    
    public var isReachableViaLoopback: Bool {
        return isReachable && nwPathMonitor.currentPath.usesInterfaceType(.loopback)
    }
    
    public var isReachableViaOther: Bool {
        return isReachable && nwPathMonitor.currentPath.usesInterfaceType(.other)
    }
}

// MARK: - Methods
extension CocoaNetworkingMonitor {
    public func startMonitoring() {
        // Once you cancel a path monitor, that specific object is done. You can’t start it again. You will need to create a new path monitor
        nwPathMonitor = NWPathMonitor()
        nwPathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            // Combine
            self.monitoringSubject.send(path.status == .satisfied)
            // Notification
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: CocoaNetworkingMonitor.DidChangeStatusNotificationName, object: nil)
            }
        }
        nwPathMonitor.start(queue: DispatchQueue(label: "com.cocoa_networking_monitor.monitoring"))
    }
    
    public func cancelMonitoring() {
        nwPathMonitor.cancel()
    }
    
    public func publisher() -> AnyPublisher<Bool, Never> {
        monitoringSubject.eraseToAnyPublisher()
    }
}
