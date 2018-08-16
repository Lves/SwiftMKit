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

public struct UserNotificationOption : OptionSet {
    
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let Badge = UserNotificationOption(rawValue: 1 << 0)
    public static let Sound = UserNotificationOption(rawValue: 1 << 1)
    public static let Alert = UserNotificationOption(rawValue: 1 << 2)
    public static let CarPlay = UserNotificationOption(rawValue: 1 << 3)
}

@available(iOS 10.0, *)
open class UserNotificationManager: NSObject {
    
    public static let sharedInstance = UserNotificationManager()
    
    open var willPresentNotificationHandler: ((UNNotification) -> Bool)?
    open var didRecieveNotificationHandler: ((UNNotificationResponse) -> Bool)?
    
    fileprivate struct Constant {
        static let DeviceTokenName = "DeviceTokenName"
        static let CFBundleInfoDictionaryVersion = "CFBundleInfoDictionaryVersion"
        static let CFBundleVersion = "CFBundleVersion"
        static let CFBundleShortVersionString = "CFBundleShortVersionString"
        static let BuildDateString = "BuildDateString"
    }
    
    public static var deviceToken: String? {
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
                DDLogWarn("Remove Push Device Token: \(deviceToken ?? "")")
            }
        }
    }
    
    public static var authorizationStatus = MutableProperty<UNAuthorizationStatus>(.notDetermined)
    public static var settings = MutableProperty<UNNotificationSettings?>(nil)
    
    public static func registerForRemoteNotifications() {
        let _ = Async.main {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    public static func requestAuthorization(_ options: UserNotificationOption, completionHandler: @escaping (Bool, Error?) -> Void) {
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
    
    public static func getNotificationSettings(_ completionHandler: @escaping (UNNotificationSettings) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            let _ = Async.main {
                self.settings.value = settings
                self.authorizationStatus.value = settings.authorizationStatus
                completionHandler(settings)
            }
        }
    }
    
    public static func addNotify(title: String, body: String, triggerTime: TimeInterval, repeats: Bool, identifier: String, categoryIdentifier: String, withCompletionHandler completionHandler: ((NSError?) -> Void)?) {
        addNotify(title: title, body: body , userInfo:nil, attachments: nil, triggerTime: triggerTime, repeats: repeats, identifier: identifier, categoryIdentifier: categoryIdentifier, withCompletionHandler: completionHandler)
    }
    //iOS10及以上本地推送
    public static func addNotify(title: String, body: String, userInfo:[AnyHashable:Any]? = [:], attachments: [UNNotificationAttachment]?, triggerTime: TimeInterval, repeats: Bool, identifier: String, categoryIdentifier: String, withCompletionHandler completionHandler: ((NSError?) -> Void)?) {
        // 1. 创建通知内容
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if let attachments = attachments {
            content.attachments = attachments
        }
        content.categoryIdentifier = categoryIdentifier
        content.userInfo = userInfo ?? [:]
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
    public static func removeDeliveredNotifies(identifiers: [String]) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
    }
    public static func removeAllDeliveredNotifies() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    public static func cancelNotifies(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    public static func cancelAllNotifies() {
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

class UserNotificationBellowiOS10Manager: NSObject{
    //MARK: - iOS10 以下本地推送
    //iOS10以下授权本地推送
    static func requestAuthorization(){
        let settings = UIUserNotificationSettings(types: [UIUserNotificationType.alert,UIUserNotificationType.sound,UIUserNotificationType.badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    //iOS10以下添加本地推送
    static func addNotifyBellowiOS10(fireDate: Date, alertBody: String?, alertAction: String? = "OK" , userInfo:[AnyHashable:Any]? = [:]){
        let localNoti = UILocalNotification()
        localNoti.fireDate = fireDate
        localNoti.alertBody = alertBody
        localNoti.alertAction = "Ok"
        localNoti.hasAction = true
        localNoti.userInfo = userInfo
        localNoti.repeatInterval = NSCalendar.Unit(rawValue: 0)
        UIApplication.shared.scheduleLocalNotification(localNoti)
    }
    //iOS10以下删除指定推送
    static func cancleLocalNotifiesByUserInfo(key:String){
        if let notifications = UIApplication.shared.scheduledLocalNotifications {
            for notifi in notifications {
                if notifi.userInfo?[key] != nil { //找到指定key的本地推送
                    UIApplication.shared.cancelLocalNotification(notifi)
                }
            }
        }
    }
    //iOS10以下删除所有未触发推送
    static func cancleAllBellowiOS10Notifies(){
        UIApplication.shared.cancelAllLocalNotifications()
    }
    
}

