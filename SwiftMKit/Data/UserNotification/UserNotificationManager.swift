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
import ReactiveSwift

struct UserNotificationOption : OptionSet {
    
    let rawValue: UInt
    
    static let Badge = UserNotificationOption(rawValue: 1 << 0)
    static let Sound = UserNotificationOption(rawValue: 1 << 1)
    static let Alert = UserNotificationOption(rawValue: 1 << 2)
    static let CarPlay = UserNotificationOption(rawValue: 1 << 3)
}

@available(iOS 10.0, *)
open class UserNotificationManager: NSObject {
    
    static let sharedInstance = UserNotificationManager()
    
    open var willPresentNotificationHandler: ((UNNotification) -> Bool)?
    open var didRecieveNotificationHandler: ((UNNotificationResponse) -> Bool)?
    
    fileprivate struct Constant {
        static let DeviceTokenName = "DeviceTokenName"
        static let CFBundleInfoDictionaryVersion = "CFBundleInfoDictionaryVersion"
        static let CFBundleVersion = "CFBundleVersion"
        static let CFBundleShortVersionString = "CFBundleShortVersionString"
        static let BuildDateString = "BuildDateString"
    }
    
    static var deviceToken: String? {
        get {
            let token = MemoryCache.shared().getObject(forKey: Constant.DeviceTokenName) as? String
            DDLogInfo("Get Push Device Token: \(token ?? "")")
            return token
        }
        set {
            if let deviceToken = newValue {
                MemoryCache.shared().setObject(deviceToken, forKey: Constant.DeviceTokenName)
                DDLogInfo("Set Push Device Token: \(deviceToken)")
            } else {
                MemoryCache.shared().removeObject(forKey: Constant.DeviceTokenName)
                DDLogWarn("Remove Push Device Token: \(deviceToken)")
            }
        }
    }
    
    static var authorizationStatus = MutableProperty<UNAuthorizationStatus>(.notDetermined)
    static var settings = MutableProperty<UNNotificationSettings?>(nil)
    
    static func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    static func requestAuthorization(_ options: UserNotificationOption, completionHandler: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: UNAuthorizationOptions(rawValue: options.rawValue)) { (granted, error) in
            if granted {
                DDLogInfo("推送授权成功")
                UserNotificationManager.registerForRemoteNotifications()
                getNotificationSettings({ _ in })
            } else {
                DDLogInfo("推送授权失败")
            }
            let _ = Async.main {
                completionHandler(granted, error as Error?)
            }
        }
    }
    
    static func getNotificationSettings(_ completionHandler: @escaping (UNNotificationSettings) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            let _ = Async.main {
                self.settings.value = settings
                self.authorizationStatus.value = settings.authorizationStatus
                completionHandler(settings)
            }
        }
    }
    
    static func addNotify(title: String, body: String, triggerTime: TimeInterval, repeats: Bool, identifier: String, categoryIdentifier: String, withCompletionHandler completionHandler: ((NSError?) -> Void)?) {
        addNotify(title: title, body: body, attachments: nil, triggerTime: triggerTime, repeats: repeats, identifier: identifier, categoryIdentifier: categoryIdentifier, withCompletionHandler: completionHandler)
    }
    static func addNotify(title: String, body: String, attachments: [UNNotificationAttachment]?, triggerTime: TimeInterval, repeats: Bool, identifier: String, categoryIdentifier: String, withCompletionHandler completionHandler: ((NSError?) -> Void)?) {
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
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                DDLogInfo("定时推送添加成功：\(requestIdentifier)")
            }
            completionHandler?(error as NSError?)
        }
    }
    
    static func removeDeliveredNotifies(identifiers: [String]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    static func removeAllDeliveredNotifies() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    static func cancelNotifies(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    static func cancelAllNotifies() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}


@available(iOS 10.0, *)
extension UserNotificationManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if (willPresentNotificationHandler?(notification) ?? false) == true {
            completionHandler([.alert, .sound])
        } else {
            completionHandler([])
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if (didRecieveNotificationHandler?(response) ?? true) == true {
            completionHandler()
        }
    }
    
}
