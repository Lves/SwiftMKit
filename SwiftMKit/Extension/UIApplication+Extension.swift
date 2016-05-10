//
//  UIApplication+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import PINCache
import CocoaLumberjack

public extension UIApplication {
    @nonobjc static var activityCount: Int = 0
    func showNetworkActivityIndicator() {
        if UIApplication.sharedApplication().statusBarHidden {
            return
        }
        let lockQueue = dispatch_queue_create("com.cdts.LockQueue", nil)
        dispatch_sync(lockQueue) {
            if UIApplication.activityCount == 0 {
                self.networkActivityIndicatorVisible = true
            }
            UIApplication.activityCount += 1
        }
    }
    func hideNetworkActivityIndicator() {
        if UIApplication.sharedApplication().statusBarHidden {
            return
        }
        let lockQueue = dispatch_queue_create("com.cdts.LockQueue", nil)
        dispatch_sync(lockQueue) {
            UIApplication.activityCount -= 1
            if UIApplication.activityCount <= 0 {
                self.networkActivityIndicatorVisible = false
                UIApplication.activityCount = 0
            }
        }
    }
    
    private struct Constant {
        static let BundleIdentifier = "BundleIdentifier"
        static let CFBundleInfoDictionaryVersion = "CFBundleInfoDictionaryVersion"
        static let CFBundleVersion = "CFBundleVersion"
        static let CFBundleShortVersionString = "CFBundleShortVersionString"
    }
    
    var bundleIdentifier: String {
        get {
            if let identifier = PINMemoryCache.sharedCache().objectForKey(Constant.BundleIdentifier) as? String {
                DDLogInfo("BundleIdentifier: \(identifier)")
                return identifier
            }
            let identifier = NSBundle.mainBundle().infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
            PINMemoryCache.sharedCache().setObject(identifier, forKey: Constant.BundleIdentifier)
            DDLogInfo("BundleIdentifier: \(identifier)")
            return identifier
        }
    }
    var minTargetVersion: String {
        get {
            if let version = PINMemoryCache.sharedCache().objectForKey(Constant.CFBundleInfoDictionaryVersion) as? String {
                DDLogInfo("CFBundleInfoDictionaryVersion: \(version)")
                return version
            }
            let version = NSBundle.mainBundle().infoDictionary?[Constant.CFBundleInfoDictionaryVersion] as? String ?? ""
            PINMemoryCache.sharedCache().setObject(version, forKey: Constant.CFBundleInfoDictionaryVersion)
            DDLogInfo("CFBundleInfoDictionaryVersion: \(version)")
            return version
        }
    }
    var bundleVersion: String {
        get {
            if let version = PINMemoryCache.sharedCache().objectForKey(Constant.CFBundleVersion) as? String {
                DDLogInfo("CFBundleVersion: \(version)")
                return version
            }
            let version = NSBundle.mainBundle().infoDictionary?[Constant.CFBundleVersion] as? String ?? ""
            PINMemoryCache.sharedCache().setObject(version, forKey: Constant.CFBundleVersion)
            DDLogInfo("CFBundleVersion: \(version)")
            return version
        }
    }
    var bundleShortVersionString: String {
        get {
            if let version = PINMemoryCache.sharedCache().objectForKey(Constant.CFBundleShortVersionString) as? String {
                DDLogInfo("CFBundleShortVersionString: \(version)")
                return version
            }
            let version = NSBundle.mainBundle().infoDictionary?[Constant.CFBundleShortVersionString] as? String ?? ""
            PINMemoryCache.sharedCache().setObject(version, forKey: Constant.CFBundleShortVersionString)
            DDLogInfo("CFBundleShortVersionString: \(version)")
            return version
        }
    }
    var bundleShortVersionNumber: Int {
        get {
            return bundleShortVersionString.stringByReplacingOccurrencesOfString(".", withString: "").toInt() ?? 0
        }
    }
}