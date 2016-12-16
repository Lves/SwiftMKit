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
        let lockQueue = DispatchQueue(label: "com.cdts.LockQueue", attributes: [])
        lockQueue.sync {
            if UIApplication.activityCount == 0 {
                self.isNetworkActivityIndicatorVisible = true
            }
            UIApplication.activityCount += 1
        }
    }
    func hideNetworkActivityIndicator() {
        let lockQueue = DispatchQueue(label: "com.cdts.LockQueue", attributes: [])
        lockQueue.sync {
            UIApplication.activityCount -= 1
            if UIApplication.activityCount <= 0 {
                self.isNetworkActivityIndicatorVisible = false
                UIApplication.activityCount = 0
            }
        }
    }
    
    fileprivate struct Constant {
        static let BundleIdentifier: String? = "BundleIdentifier"
        static let CFBundleInfoDictionaryVersion: String? = "CFBundleInfoDictionaryVersion"
        static let CFBundleVersion: String? = "CFBundleVersion"
        static let CFBundleShortVersionString: String? = "CFBundleShortVersionString"
        static let BuildDateString: String? = "BuildDateString"
    }
    
    var remoteNotificationEnabled: Bool {
        get {
            if let status = currentUserNotificationSettings {
                return status.types != UIUserNotificationType()
            }
            return false
        }
    }
    
    var infoDictionary:[String : AnyObject]? {
        return Bundle.main.infoDictionary as [String : AnyObject]?
    }
    
    var bundleIdentifier: String {
        get {
            if let identifier = PINMemoryCache.shared().object(forKey: Constant.BundleIdentifier) as? String {
                return identifier
            }
            let identifier = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
            PINMemoryCache.shared().setObject(identifier, forKey: Constant.BundleIdentifier!)
            DDLogInfo("BundleIdentifier: \(identifier)")
            return identifier
        }
    }
    var minTargetVersion: String {
        get {
            if let version = PINMemoryCache.shared().object(forKey: Constant.CFBundleInfoDictionaryVersion) as? String {
                return version
            }
            let version = Bundle.main.infoDictionary?[Constant.CFBundleInfoDictionaryVersion!] as? String ?? ""
            PINMemoryCache.shared().setObject(version, forKey: Constant.CFBundleInfoDictionaryVersion!)
            DDLogInfo("CFBundleInfoDictionaryVersion: \(version)")
            return version
        }
    }
    var bundleVersion: String {
        get {
            if let version = PINMemoryCache.shared().object(forKey: Constant.CFBundleVersion) as? String {
                return version
            }
            let version = Bundle.main.infoDictionary?[Constant.CFBundleVersion!] as? String ?? ""
            PINMemoryCache.shared().setObject(version, forKey: Constant.CFBundleVersion!)
            DDLogInfo("CFBundleVersion: \(version)")
            return version
        }
    }
    var bundleShortVersionString: String {
        get {
            if let version = PINMemoryCache.shared().object(forKey: Constant.CFBundleShortVersionString) as? String {
                return version
            }
            let version = Bundle.main.infoDictionary?[Constant.CFBundleShortVersionString!] as? String ?? ""
            PINMemoryCache.shared().setObject(version, forKey: Constant.CFBundleShortVersionString!)
            DDLogInfo("CFBundleShortVersionString: \(version)")
            return version
        }
    }
    var bundleShortVersionNumber: Int {
        get {
            return bundleShortVersionString.replacingOccurrences(of: ".", with: "").toInt() ?? 0
        }
    }
    var bundleBuildDateString: String {
        get {
            if let dateString = PINMemoryCache.shared().object(forKey: Constant.BuildDateString) as? String {
                return dateString
            }
            let dateString = Bundle.main.infoDictionary?[Constant.BuildDateString!] as? String ?? ""
            PINMemoryCache.shared().setObject(dateString, forKey: Constant.BuildDateString!)
            DDLogInfo("BuildDateString: \(dateString)")
            return dateString
        }
    }
}
