//
//  GesturePassword.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import CocoaLumberjack

public class GesturePassword: GesturePasswordProtocol {
    
    public var passwordKey: String = "GesturePassword"
    
    public func verify(password: String) -> Bool {
        if password.length > 0 {
            if let mPassword = KeychainWrapper.stringForKey(passwordKey) {
                if mPassword == password {
                    DDLogInfo("[GesturePassword] Success: \(password)")
                    return true
                }
            }
        }
        DDLogError("[GesturePassword] Failed: \(password)")
        return false
    }
    public func change(password: String) -> Bool {
        DDLogInfo("[GesturePassword] Changed: \(password)")
        return KeychainWrapper.setString(password, forKey: passwordKey)
    }
    public func exist() -> Bool {
        return KeychainWrapper.stringForKey(passwordKey) != nil
    }
    public func clear() -> Bool {
        DDLogInfo("[GesturePassword] Clear")
        return KeychainWrapper.removeObjectForKey(passwordKey)
    }
    
}