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

public struct FingerPrint {
    public static func isSupport() -> SignalProducer<LAContext, NSError> {
        return SignalProducer { sink,disposable in
            let context = LAContext()
            var error: NSError?
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
    
    public static func authenticate(_ title: String) -> SignalProducer<Bool, NSError> {
        return FingerPrint.isSupport().flatMap(.concat) { (context) -> SignalProducer<Bool, NSError> in
            return SignalProducer { sink,disposable in
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: title, reply: {
                    (success: Bool, authenticationError: Error?) -> Void in
                    if success {
                        DDLogInfo("[FingerPrint] Matched Success")
                        sink.send(value: success)
                        sink.sendCompleted()
                    } else {
                        if authenticationError != nil && authenticationError?.localizedDescription == "Cancel" {
                            DDLogWarn("[FingerPrint] Matched Cancel")
                            sink.send(value: false)
                            sink.sendCompleted()
                        } else {
                            DDLogError("[FingerPrint] Matched Failure: \(String(describing: authenticationError))")
                            sink.send(error: authenticationError as NSError? ?? NSError(domain: "", code: -1, userInfo: nil))
                        }
                    }
                })
            }
        }
    }
}
