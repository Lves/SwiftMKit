//
//  FingerPrint.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/18/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import LocalAuthentication
import ReactiveCocoa
import CocoaLumberjack

open class FingerPrint {
    open class func isSupport() -> SignalProducer<LAContext, NSError> {
        return SignalProducer { sink,disposable in
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
                DDLogInfo("[FingerPrint] Supported")
                sink.sendNext(context)
                sink.sendCompleted()
            } else {
                DDLogWarn("[FingerPrint] UnSupported")
                sink.sendFailed(error ?? NSError(domain: "", code: -1, userInfo: nil))
            }
        }
    }
    
    open class func authenticate(_ title: String) -> SignalProducer<Bool, NSError> {
        return FingerPrint.isSupport().flatMap(.Concat) { (context) -> SignalProducer<Bool, NSError> in
            return SignalProducer { sink,disposable in
                context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: title) {
                    (success: Bool, authenticationError: NSError?) -> Void in
                    if success {
                        DDLogInfo("[FingerPrint] Matched Success")
                        sink.sendNext(success)
                        sink.sendCompleted()
                    } else {
                        if authenticationError != nil && authenticationError!.code == LAError.UserCancel.rawValue {
                            DDLogWarn("[FingerPrint] Matched Cancel")
                            sink.sendNext(false)
                            sink.sendCompleted()
                        } else {
                            DDLogError("[FingerPrint] Matched Failure: \(authenticationError)")
                            sink.sendFailed(authenticationError ?? NSError(domain: "", code: -1, userInfo: nil))
                        }
                    }
                }
            }
        }
    }
}
