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
import Alamofire

public enum NetworkStatus: String {
    case unknown                = "Unknown"
    case notReachable           = "No Connection"
    case reachableViaWiFi       = "WiFi"
    case reachableViaWWAN       = "Cellular"
}


public struct NetworkListener {
    public static var networkStatus = MutableProperty<NetworkStatus>(.unknown)
    private static var manager: NetworkReachabilityManager?
    
    public static func listen() {
        manager = NetworkReachabilityManager()
        manager?.listener = { status in
            switch status {
            case .reachable(.ethernetOrWiFi):
                DDLogInfo("当前网络: WiFi")
                self.networkStatus.value = .reachableViaWiFi
            case .reachable(.wwan):
                DDLogInfo("当前网络: Cellular")
                self.networkStatus.value = .reachableViaWWAN
            default:
                DDLogInfo("网络无法连接")
                self.networkStatus.value = .notReachable
            }
        }
        manager?.startListening()
    }
    
    
    
}
