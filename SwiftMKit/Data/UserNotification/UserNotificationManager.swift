//
//  UserNotificationManager.swift
//  SwiftMKitDemo
//
//  Created by Mao on 09/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import PINCache
import CocoaLumberjack
import UserNotifications
import ReactiveCocoa

struct UserNotificationOption : OptionSetType {
    
    let rawValue: UInt
    
    static let Badge = UserNotificationOption(rawValue: 1 << 0)
    static let Sound = UserNotificationOption(rawValue: 1 << 1)
    static let Alert = UserNotificationOption(rawValue: 1 << 2)
    static let CarPlay = UserNotificationOption(rawValue: 1 << 3)
}

@available(iOS 10.0, *)
public class UserNotificationManager: NSObject {
    
    static let sharedInstance = UserNotificationManager()
    
    public var willPresentNotificationHandler: ((UNNotification) -> Bool)?
    public var didRecieveNotificationHandler: ((UNNotificationResponse) -> Bool)?
    
    private struct Constant {
        static let DeviceTokenName = "DeviceTokenName"
        static let CFBundleInfoDictionaryVersion = "CFBundleInfoDictionaryVersion"
        static let CFBundleVersion = "CFBundleVersion"
        static let CFBundleShortVersionString = "CFBundleShortVersionString"
        static let BuildDateString = "BuildDateString"
    }
    
    static var deviceToken: String? {
        get {
            let token = PINMemoryCache.sharedCache().objectForKey(Constant.DeviceTokenName) as? String
            DDLogInfo("Get Push Device Token: \(token ?? "")")
            return token
        }
        set {
            if let deviceToken = newValue {
                PINMemoryCache.sharedCache().setObject(deviceToken, forKey: Constant.DeviceTokenName)
                DDLogInfo("Set Push Device Token: \(deviceToken)")
            } else {
                PINMemoryCache.sharedCache().removeObjectForKey(Constant.DeviceTokenName)
                DDLogWarn("Remove Push Device Token: \(deviceToken)")
            }
        }
    }
    
    static var authorizationStatus = MutableProperty<UNAuthorizationStatus>(.NotDetermined)
    static var settings = MutableProperty<UNNotificationSettings?>(nil)
    
    static func registerForRemoteNotifications() {
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    static func requestAuthorization(options: UserNotificationOption, completionHandler: (Bool, NSError?) -> Void) {
        UNUserNotificationCenter.currentNotificationCenter().requestAuthorizationWithOptions(UNAuthorizationOptions(rawValue: options.rawValue)) { (granted, error) in
            if granted {
                DDLogInfo("推送授权成功")
                UserNotificationManager.registerForRemoteNotifications()
                getNotificationSettings({ _ in })
            } else {
                DDLogInfo("推送授权失败")
            }
            Async.main {
                completionHandler(granted, error)
            }
        }
    }
    
    static func getNotificationSettings(completionHandler: (UNNotificationSettings) -> Void) {
        UNUserNotificationCenter.currentNotificationCenter().getNotificationSettingsWithCompletionHandler { (settings) in
            Async.main {
                self.settings.value = settings
                self.authorizationStatus.value = settings.authorizationStatus
                completionHandler(settings)
            }
        }
    }
    
    static func addNotify(title: String, body: String, triggerTime: NSTimeInterval, repeats: Bool, identifier: String, categoryIdentifier: String, withCompletionHandler completionHandler: ((NSError?) -> Void)?) {
        addNotify(title, body: body, attachments: nil, triggerTime: triggerTime, repeats: repeats, identifier: identifier, categoryIdentifier: categoryIdentifier, withCompletionHandler: completionHandler)
    }
    static func addNotify(title: String, body: String, attachments: [UNNotificationAttachment]?, triggerTime: NSTimeInterval, repeats: Bool, identifier: String, categoryIdentifier: String, withCompletionHandler completionHandler: ((NSError?) -> Void)?) {
        // 1. 创建通知内容
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if let attachments = attachments {
            content.attachments = attachments
        }
        content.categoryIdentifier = categoryIdentifier
        
        // 2. 创建发送触发
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerTime, repeats: repeats)
        
        // 3. 发送请求标识符
        let requestIdentifier = identifier
        
        // 4. 创建一个发送请求
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        // 将请求添加到发送中心
        UNUserNotificationCenter.currentNotificationCenter().addNotificationRequest(request) { error in
            if error == nil {
                DDLogInfo("定时推送添加成功：\(requestIdentifier)")
            }
            completionHandler?(error)
        }
    }
    
    static func removeDeliveredNotifies(identifiers: [String]) {
        UNUserNotificationCenter.currentNotificationCenter().removeDeliveredNotificationsWithIdentifiers(identifiers)
    }
    static func removeAllDeliveredNotifies() {
        UNUserNotificationCenter.currentNotificationCenter().removeAllDeliveredNotifications()
    }
    static func cancelNotifies(identifiers: [String]) {
        UNUserNotificationCenter.currentNotificationCenter().removePendingNotificationRequestsWithIdentifiers(identifiers)
    }
    static func cancelAllNotifies() {
        UNUserNotificationCenter.currentNotificationCenter().removeAllPendingNotificationRequests()
    }
}


@available(iOS 10.0, *)
extension UserNotificationManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        if (willPresentNotificationHandler?(notification) ?? false) == true {
            completionHandler([.Alert, .Sound])
        } else {
            completionHandler([])
        }
    }
    
    public func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        if (didRecieveNotificationHandler?(response) ?? true) == true {
            completionHandler()
        }
    }
    
}
