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
                Async.main { [weak self] in
                     self?.isNetworkActivityIndicatorVisible = true
                }
            }
            UIApplication.activityCount += 1
        }
    }
    func hideNetworkActivityIndicator() {
        let lockQueue = DispatchQueue(label: "com.cdts.LockQueue", attributes: [])
        lockQueue.sync {
            UIApplication.activityCount -= 1
            if UIApplication.activityCount <= 0 {
                Async.main { [weak self] in
                    self?.isNetworkActivityIndicatorVisible = false
                }
                UIApplication.activityCount = 0
            }
        }
    }
    
    fileprivate struct Constant {
        static let BundleIdentifier = "BundleIdentifier"
        static let CFBundleInfoDictionaryVersion = "CFBundleInfoDictionaryVersion"
        static let CFBundleVersion = "CFBundleVersion"
        static let CFBundleShortVersionString = "CFBundleShortVersionString"
        static let BuildDateString = "BuildDateString"
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
            if let identifier = MemoryCache.shared().getObject(forKey: Constant.BundleIdentifier) as? String {
                return identifier
            }
            let identifier = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
            PINMemoryCache.shared().setObject(identifier, forKey: Constant.BundleIdentifier)
            DDLogInfo("BundleIdentifier: \(identifier)")
            return identifier
        }
    }
    var minTargetVersion: String {
        get {
            if let version = MemoryCache.shared().getObject(forKey: Constant.CFBundleInfoDictionaryVersion) as? String {
                return version
            }
            let version = Bundle.main.infoDictionary?[Constant.CFBundleInfoDictionaryVersion] as? String ?? ""
            PINMemoryCache.shared().setObject(version, forKey: Constant.CFBundleInfoDictionaryVersion)
            DDLogInfo("CFBundleInfoDictionaryVersion: \(version)")
            return version
        }
    }
    var bundleVersion: String {
        get {
            if let version = MemoryCache.shared().getObject(forKey: Constant.CFBundleVersion) as? String {
                return version
            }
            let version = Bundle.main.infoDictionary?[Constant.CFBundleVersion] as? String ?? ""
            PINMemoryCache.shared().setObject(version, forKey: Constant.CFBundleVersion)
            DDLogInfo("CFBundleVersion: \(version)")
            return version
        }
    }
    var bundleShortVersionString: String {
        get {
            if let version = MemoryCache.shared().getObject(forKey: Constant.CFBundleShortVersionString) as? String {
                return version
            }
            let version = Bundle.main.infoDictionary?[Constant.CFBundleShortVersionString] as? String ?? ""
            PINMemoryCache.shared().setObject(version, forKey: Constant.CFBundleShortVersionString)
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
            if let dateString = MemoryCache.shared().getObject(forKey: Constant.BuildDateString) as? String {
                return dateString
            }
            let dateString = Bundle.main.infoDictionary?[Constant.BuildDateString] as? String ?? ""
            PINMemoryCache.shared().setObject(dateString, forKey: Constant.BuildDateString)
            DDLogInfo("BuildDateString: \(dateString)")
            return dateString
        }
    }
}
