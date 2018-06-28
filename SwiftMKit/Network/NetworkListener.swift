//
//  NetApiClient.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/5/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack
import ReactiveCocoa
import ReactiveSwift

public enum NetworkStatus: String {
    case unknown                = "Unknown"
    case notReachable           = "No Connection"
    case reachableViaWiFi       = "WiFi"
    case reachableViaWWAN       = "Cellular"
}


public struct NetworkListener {
    public static var networkStatus = MutableProperty<NetworkStatus>(.unknown)
    private static var reachability: Reachability?
    
    public static func listen() {
        reachability = Reachability.init()
        reachability?.whenReachable = { reachability in
            if reachability.isReachableViaWiFi {
                DDLogInfo("当前网络: WiFi")
                self.networkStatus.value = .reachableViaWiFi
            } else {
                DDLogInfo("当前网络: Cellular")
                self.networkStatus.value = .reachableViaWWAN
            }
        }
        reachability?.whenUnreachable = { reachability in
            DDLogInfo("网络无法连接")
            self.networkStatus.value = .notReachable
        }
        
        do {
            try self.reachability?.startNotifier()
        } catch {
            DDLogError("Unable to start notifier")
        }
    }
    
    
    
}
