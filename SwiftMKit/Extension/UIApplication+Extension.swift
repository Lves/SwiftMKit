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
    
    func bundleIdentifier(_ completion: @escaping (String?) -> Void) {
        if PINMemoryCache.shared().containsObject(forKey: Constant.BundleIdentifier) {
            PINMemoryCache.shared().object(forKey: Constant.BundleIdentifier)  { _, _, value in
                completion(value as? String)
            }
        } else {
            let identifier = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
            PINMemoryCache.shared().setObject(identifier, forKey: Constant.BundleIdentifier)
            DDLogInfo("BundleIdentifier: \(identifier)")
            completion(identifier)
        }
    }
    func minTargetVersion(_ completion: @escaping (String?) -> Void) {
        if PINMemoryCache.shared().containsObject(forKey: Constant.CFBundleInfoDictionaryVersion) {
            PINMemoryCache.shared().object(forKey: Constant.CFBundleInfoDictionaryVersion)  { _, _, value in
                completion(value as? String)
            }
        } else {
            let version = Bundle.main.infoDictionary?[Constant.CFBundleInfoDictionaryVersion] as? String ?? ""
            PINMemoryCache.shared().setObject(version, forKey: Constant.CFBundleInfoDictionaryVersion)
            DDLogInfo("CFBundleInfoDictionaryVersion: \(version)")
            completion(version)
        }
    }
    func bundleVersion(_ completion: @escaping (String?) -> Void) {
        if PINMemoryCache.shared().containsObject(forKey: Constant.CFBundleVersion) {
            PINMemoryCache.shared().object(forKey: Constant.CFBundleVersion)  { _, _, value in
                completion(value as? String)
            }
        } else {
            let version = Bundle.main.infoDictionary?[Constant.CFBundleVersion] as? String ?? ""
            PINMemoryCache.shared().setObject(version, forKey: Constant.CFBundleVersion)
            DDLogInfo("CFBundleVersion: \(version)")
            completion(version)
        }
    }
    func bundleShortVersionString(_ completion: @escaping (String?) -> Void) {
        if PINMemoryCache.shared().containsObject(forKey: Constant.CFBundleShortVersionString) {
            PINMemoryCache.shared().object(forKey: Constant.CFBundleShortVersionString)  { _, _, value in
                completion(value as? String)
            }
        } else {
            let version = Bundle.main.infoDictionary?[Constant.CFBundleShortVersionString] as? String ?? ""
            PINMemoryCache.shared().setObject(version, forKey: Constant.CFBundleShortVersionString)
            DDLogInfo("CFBundleShortVersionString: \(version)")
            completion(version)
        }
    }
    func bundleShortVersionNumber(_ completion: @escaping (Int?) -> Void) {
        bundleShortVersionString { value in
            let number = value?.replacingOccurrences(of: ".", with: "").toInt()
            completion(number)
        }
    }
    func bundleBuildDateString(_ completion: @escaping (String?) -> Void) {
        if PINMemoryCache.shared().containsObject(forKey: Constant.BuildDateString) {
            PINMemoryCache.shared().object(forKey: Constant.BuildDateString)  { _, _, value in
                completion(value as? String)
            }
        } else {
            let dateString = Bundle.main.infoDictionary?[Constant.BuildDateString] as? String ?? ""
            PINMemoryCache.shared().setObject(dateString, forKey: Constant.CFBundleShortVersionString)
            DDLogInfo("BuildDateString: \(dateString)")
            completion(dateString)
        }
    }
}
