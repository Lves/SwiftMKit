//
//  BaseKitService.swift
//  JimuDuMiao
//
//  Created by wei.mao on 2017/6/23.
//  Copyright © 2017年 Pintec. All rights reserved.
//

import UIKit
import ReactiveSwift

class BaseKitService: NSObject {

    class func signalFor<T: NetApiProtocol>(api: T) -> SignalProducer<T, NetError> {
        return api.signal()
    }

    class func validate<T: NetApiProtocol>(_ conditions: [(Bool, String)], completion: () -> T) -> T where T: NSObject {
        let cond = conditions.map { ($0, NetStatusCode.validateFailed.rawValue, $1) }
        return validate(cond, completion: completion)
    }
    class func validate<T: NetApiProtocol>(_ conditions: [(Bool, Int, String)], completion: () -> T) -> T where T: NSObject {
        for condition in conditions {
            if condition.0 {
                let error = NetError(statusCode: condition.1, message: condition.2)
                let t = T()
                t.error = error
                return t
            }
        }
        return completion()
    }
//    class func signalFor<T: RequestApi>(api: T) -> SignalProducer<T, NetError> {
//        return api.signal()
//    }
//
//    class func validate<T: RequestApi>(_ conditions: [(Bool, String)], completion: () -> T) -> T where T: NSObject {
//        let cond = conditions.map { ($0, NetStatusCode.validateFailed.rawValue, $1) }
//        return validate(cond, completion: completion)
//    }
//    class func validate<T: RequestApi>(_ conditions: [(Bool, Int, String)], completion: () -> T) -> T where T: NSObject {
//        for condition in conditions {
//            if condition.0 {
//                let error = NetError(statusCode: condition.1, message: condition.2)
//                let t = T()
//                t.error = error
//                return t
//            }
//        }
//        return completion()
//    }
}
