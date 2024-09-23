// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Network
import Combine

@objcMembers
public final class CocoaNetworkingMonitor: NSObject {
    public static let DidChangeStatusNotification = NSNotification.Name(rawValue: "CocoaNetworkingMonitorChangeStatusNotification")
    public static let shared = CocoaNetworkingMonitor()
    
    private override init() {}
    
    private let nwPathMonitor = NWPathMonitor()
    private let monitoringSubject = PassthroughSubject<CocoaNetworkingStatus, Never>()
    
    private var currentStatus: CocoaNetworkingStatus {
        if nwPathMonitor.currentPath.status == .satisfied {
            return .satisfied
        }
        return .unsatisfied
    }
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
    public func setup() {
        nwPathMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            // Combine
            self.monitoringSubject.send(self.currentStatus)
            // Notification
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: CocoaNetworkingMonitor.DidChangeStatusNotification, object: nil)
            }
        }
    }
    
    public func startMonitoring() {
        nwPathMonitor.start(queue: DispatchQueue(label: "com.cocoa_networking_monitor.monitoring"))
    }
    
    public func cancelMonitoring() {
        nwPathMonitor.cancel()
    }
    
    public func publisher() -> AnyPublisher<CocoaNetworkingStatus, Never> {
        monitoringSubject.eraseToAnyPublisher()
    }
}
