//
//  CocoaNetworkingProvider.swift
//  CocoaNetworkingMonitor
//
//  Created by 上條蓮太朗 on 2024/09/23.
//

import Foundation
import Combine

@MainActor
public final class CocoaNetworkingProvider: ObservableObject {
    @Published public var isReachable: Bool = true
    @Published public var isShowUnsatisfiedAlert: Bool = false
    
    private let publisher = CocoaNetworkingMonitor.shared.publisher()
    private var cancellablesBag = Set<AnyCancellable>()
    
    
    public init() {
        publisher.sink { [weak self] isReachable in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isReachable = isReachable
                self.isShowUnsatisfiedAlert = !isReachable
            }
        }.store(in: &cancellablesBag)
    }
    
    deinit {
        cancellablesBag.forEach {
            $0.cancel()
        }
    }
}
