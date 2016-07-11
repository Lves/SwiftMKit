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
    
    public static var passwordKey: String = "GesturePassword"
    
    public class func verify(password: String) -> Bool {
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
    public class func change(password: String) -> Bool {
        DDLogInfo("[GesturePassword] Changed: \(password)")
        return KeychainWrapper.setString(password, forKey: passwordKey)
    }
    public class func exist() -> Bool {
        return KeychainWrapper.stringForKey(passwordKey) != nil
    }
    public class func clear() -> Bool {
        DDLogInfo("[GesturePassword] Clear")
        return KeychainWrapper.removeObjectForKey(passwordKey)
    }
    
}