//
//  GesturePassword.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import CocoaLumberjack

open class GesturePassword: GesturePasswordProtocol {
    
    open static var passwordKey: String = "GesturePassword"
    
    open class func verify(_ password: String) -> Bool {
        if password.length > 0 {
            if let mPassword = KeychainWrapper.string(forKey: passwordKey) {
                if mPassword == password {
                    DDLogInfo("[GesturePassword] Success: \(password)")
                    return true
                }
            }
        }
        DDLogError("[GesturePassword] Failed: \(password)")
        return false
    }
    open class func change(_ password: String) -> Bool {
        DDLogInfo("[GesturePassword] Changed: \(password)")
        return KeychainWrapper.setString(password, forKey: passwordKey)
    }
    open class func exist() -> Bool {
        return KeychainWrapper.string(forKey: passwordKey) != nil
    }
    open class func clear() -> Bool {
        DDLogInfo("[GesturePassword] Clear")
        return KeychainWrapper.removeObject(forKey: passwordKey)
    }
    
}
