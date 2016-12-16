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
import ReactiveSwift
import CocoaLumberjack

open class FingerPrint {
    open class func isSupport() -> SignalProducer<LAContext, Error> {
        return SignalProducer { sink,disposable in
            let context = LAContext()
            var error: Error?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                DDLogInfo("[FingerPrint] Supported")
                sink.send(value: context)
                sink.sendCompleted()
            } else {
                DDLogWarn("[FingerPrint] UnSupported")
                sink.send(error: error ?? NSError(domain: "", code: -1, userInfo: nil))
            }
        }
    }
    
    open class func authenticate(_ title: String) -> SignalProducer<Bool, Error> {
        return FingerPrint.isSupport().flatMap(.Concat) { (context) -> SignalProducer<Bool, Error> in
            return SignalProducer { sink,disposable in
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: title) {
                    (success: Bool, authenticationError: Error?) -> Void in
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
