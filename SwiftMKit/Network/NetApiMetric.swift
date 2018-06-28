//
//  NetApiMetric.swift
//  SwiftMKitDemo
//
//  Created by wei.mao on 2018/6/28.
//  Copyright © 2018年 cdts. All rights reserved.
//

import Foundation
import CocoaLumberjack

public struct NetApiMetric {
    
    private var runningApis = [NetApiData]()
    
    private static var shared = NetApiMetric()
    
    // MARK: RunningApi
    
    public static func runnings() -> [NetApiData] {
        return shared.runningApis
    }
    public static func add(api: NetApiData) {
        shared.runningApis.append(api)
        DDLogDebug("[Api++ \(shared.runningApis.count)] \(Unmanaged.passUnretained(api).toOpaque())")
    }
    public static func remove(api: NetApiData) {
        if let index = shared.runningApis.index(of: api) {
            shared.runningApis.remove(at: index)
            DDLogDebug("[Api-- \(shared.runningApis.count)] \(Unmanaged.passUnretained(api).toOpaque())")
        }
    }
}
