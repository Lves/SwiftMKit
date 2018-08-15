//
//  PushManager.swift
//  Merak
//
//  Created by Mao on 7/8/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack
import UserNotifications

public enum PushFrom : Int {
    case remote
    case local
}

public protocol PushManagerProtocol {
    func pmp_registerRemoteNotification(application:UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
    func pmp_didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data)
    func pmp_didReceiveNotification(from : PushFrom, userInfo: [AnyHashable: Any])
    func pmp_didFailToRegisterForRemoteNotifications(withError error: Error)
}

extension PushManagerProtocol {
    public func pmp_didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {}
    public func pmp_didReceiveNotification(from : PushFrom, userInfo: [AnyHashable: Any]){}
    public func pmp_didFailToRegisterForRemoteNotifications(withError error: Error) {}
}

public class PushManager: NSObject , UNUserNotificationCenterDelegate{
    private override init() {
    }
    public static let shared = PushManager()
    private var tempPushUserInfo: [AnyHashable: Any]? {
        didSet {
            DDLogInfo("PushUserInfo temp store: \(String(describing: tempPushUserInfo))")
        }
    }
    private var tempPushFrom: PushFrom?
    public var managers: [PushManagerProtocol] = []
    public var canReceiveData: Bool = false {
        didSet {
            if canReceiveData == true && tempPushUserInfo != nil && tempPushFrom != nil {
                didReceiveNotification(from: tempPushFrom!, userInfo: tempPushUserInfo!)
            }
        }
    }
    
    public func storeTempData(userInfo: [AnyHashable: Any], from: PushFrom) {
        tempPushUserInfo = userInfo
        tempPushFrom = from
    }
    
    public func addManagers(_ managers: [PushManagerProtocol]) {
        _ = managers.map { self.managers.append($0) }
    }
    
    func register(){
        if #available(iOS 10.0, *) {
            let notifiCenter = UNUserNotificationCenter.current()
//            let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
//            notifiCenter.delegate = appDelegate
        }
    }
    
    func finishLaunch(application:UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?){
        
        PushManager.shared.register()
        if managers.count > 0{
            _ = managers.map { $0.pmp_registerRemoteNotification(application: application,launchOptions:launchOptions) }
        }
        
        //开机收到通知
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            self.didReceiveNotification(from: .remote, userInfo: userInfo)
        }else if let localNoti = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
            self.didReceiveNotification(from: .local, userInfo: localNoti.userInfo ?? [:])
        }
    }
    
    func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data){
        _ = managers.map { $0.pmp_didRegisterForRemoteNotifications(withDeviceToken: deviceToken) }
    }
    func didReceiveNotification(from: PushFrom, userInfo: [AnyHashable: Any]){
        storeTempData(userInfo: userInfo, from: from)
        if canReceiveData {
            tempPushUserInfo = nil
            tempPushFrom = nil
            _ = managers.map { $0.pmp_didReceiveNotification(from: from, userInfo: userInfo) }
        }
    }
    func didFailToRegisterForRemoteNotifications(withError error: Error){
        _ = managers.map { $0.pmp_didFailToRegisterForRemoteNotifications(withError: error) }
    }
    
}

//extension AppDelegate : UNUserNotificationCenterDelegate{
//
//    //MARK: 推送回调方法
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        DDLogInfo("推送注册成功 DeviceToken: \(deviceToken)")
//        PushManager.shared.didRegisterForRemoteNotifications(withDeviceToken: deviceToken)
//    }
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        DDLogError("推送注册失败")
//        PushManager.shared.didFailToRegisterForRemoteNotifications(withError: error)
//    }
//
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        if application.applicationState == .active || application.applicationState == .inactive {
//            PushManager.shared.didReceiveNotification(from: .remote, userInfo: userInfo as [NSObject : AnyObject])
//        }
//
//        completionHandler(.noData)
//    }
//    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
//        if UIApplication.shared.applicationState == .active{ //本地推送，用户活动状态  不做处理
//            return
//        }
//        if let userInfo = notification.userInfo {
//            PushManager.shared.didReceiveNotification(from: .local, userInfo: userInfo as [NSObject : AnyObject])
//        }
//    }
//    //MARK: iOS10新加入的回调方法
//    // 应用在前台收到通知
//    @available(iOS 10.0, *)
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//        if notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) == true { //远程推送
//            PushManager.shared.didReceiveNotification(from: .remote, userInfo: userInfo as [NSObject : AnyObject])
//        }else{  //本地推送
//            if UIApplication.shared.applicationState != .active{ //本地推送，用户活动状态  不做处理
//                PushManager.shared.didReceiveNotification(from: .local, userInfo: userInfo as [NSObject : AnyObject])
//            }
//        }
//        completionHandler(.sound)
//    }
//
//    // 点击通知进入应用
//    @available(iOS 10.0, *)
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        let userInfo = response.notification.request.content.userInfo
//        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) == true){
//            PushManager.shared.didReceiveNotification(from: .remote, userInfo: userInfo)
//        }else {
//            PushManager.shared.didReceiveNotification(from: .local, userInfo: userInfo)
//        }
//        completionHandler()
//    }
//}


