//
//  PushManager.swift
//  Merak
//
//  Created by Mao on 7/8/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack
import UserNotifications

public enum PushFrom : Int {
    case REMOTE
    case LOCAL
}

public protocol PushManagerProtocol {
    func pmp_registerRemoteNotification(application:UIApplication,launchOptions:[NSObject: AnyObject]?)
    func pmp_didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData)
    func pmp_didReceiveNotification(from : PushFrom, userInfo: [NSObject : AnyObject])
    func pmp_didFailToRegisterForRemoteNotificationsWithError(error: NSError)
}

extension PushManagerProtocol {
    public func pmp_didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData) {}
    public func pmp_didReceiveNotification(from : PushFrom, userInfo: [NSObject : AnyObject]){}
    public func pmp_didFailToRegisterForRemoteNotificationsWithError(error: NSError) {}
}

public class PushManager: NSObject , UNUserNotificationCenterDelegate{
    private override init() {
    }
    public static let shared = PushManager()
    private var tempPushUserInfo: [NSObject : AnyObject]? {
        didSet {
            DDLogInfo("PushUserInfo temp store: \(tempPushUserInfo)")
        }
    }
    private var tempPushFrom: PushFrom?
    public var managers: [PushManagerProtocol] = []
    public var canReceiveData: Bool = false {
        didSet {
            if canReceiveData == true && tempPushUserInfo != nil && tempPushFrom != nil {
                didReceiveNotification(tempPushFrom!, userInfo: tempPushUserInfo!)
            }
        }
    }
    
    public func storeTempData(userInfo: [NSObject : AnyObject], from: PushFrom) {
        tempPushUserInfo = userInfo
        tempPushFrom = from
    }
    
    public func addManagers(managers: [PushManagerProtocol]) {
        _ = managers.map { self.managers.append($0) }
    }
    
    func register(){
        if #available(iOS 10.0, *) {
            let notifiCenter = UNUserNotificationCenter.currentNotificationCenter()
            let appDelegate = (UIApplication.sharedApplication().delegate) as! AppDelegate
            notifiCenter.delegate = appDelegate
        }
    }
    
    func finishLaunchApplication(application:UIApplication,didFinishLaunchingWithOptions launchOptions:[NSObject: AnyObject]?){
        
        PushManager.shared.register()
        if managers.count > 0{
            _ = managers.map { $0.pmp_registerRemoteNotification(application,launchOptions:launchOptions) }
        }
        
        //开机收到通知
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject: AnyObject] {
            self.didReceiveNotification(.REMOTE, userInfo: userInfo)
        }else if let userInfo = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? [NSObject: AnyObject] {
            self.didReceiveNotification(.LOCAL, userInfo: userInfo)
        }
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData){
        _ = managers.map { $0.pmp_didRegisterForRemoteNotificationsWithDeviceToken(deviceToken) }
    }
    func didReceiveNotification(from: PushFrom, userInfo: [NSObject : AnyObject]){
        storeTempData(userInfo, from: from)
        if canReceiveData {
            tempPushUserInfo = nil
            tempPushFrom = nil
            _ = managers.map { $0.pmp_didReceiveNotification(from, userInfo: userInfo) }
        }
    }
    func didFailToRegisterForRemoteNotificationsWithError(error: NSError){
        _ = managers.map { $0.pmp_didFailToRegisterForRemoteNotificationsWithError(error) }
    }
    
}

extension AppDelegate : UNUserNotificationCenterDelegate{
    
    //MARK: 推送回调方法
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        DDLogInfo("推送注册成功 DeviceToken: \(deviceToken)")
        PushManager.shared.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        DDLogError("推送注册失败")
        PushManager.shared.didFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == .Active || application.applicationState == .Inactive {
            PushManager.shared.didReceiveNotification(.REMOTE, userInfo: userInfo)
        }
        
        completionHandler(.NoData)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        if let userInfo = notification.userInfo {
            PushManager.shared.didReceiveNotification(.LOCAL, userInfo: userInfo)
        }
    }
    
    //MARK: iOS10新加入的回调方法
    // 应用在前台收到通知
    @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        PushManager.shared.didReceiveNotification(.REMOTE, userInfo: userInfo)

        completionHandler(.Sound)
    }
    
    // 点击通知进入应用
    @available(iOS 10.0, *)
    func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if ((response.notification.request.trigger?.isKindOfClass(UNPushNotificationTrigger)) != nil){
            PushManager.shared.didReceiveNotification(.REMOTE, userInfo: userInfo)
        }
        completionHandler()
    }
}


