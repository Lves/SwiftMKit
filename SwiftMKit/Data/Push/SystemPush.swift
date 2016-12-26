//
//  SystemPush.swift
//  Merak
//
//  Created by HeLi on 16/12/20.
//  Copyright © 2016年 jimubox. All rights reserved.
//

import UIKit
import UserNotifications
import CocoaLumberjack

public class SystemPush: PushManagerProtocol {
    
    public func pmp_didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        let token = deviceToken.hexString
        if #available(iOS 10.0, *) {
            UserNotificationManager.deviceToken = token
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func pmp_registerRemoteNotification(application: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        if #available(iOS 10.0, *) {
            let types = UserNotificationOption(arrayLiteral: [.Alert, .Badge, .Sound])
            UserNotificationManager.requestAuthorization(types, completionHandler: {_,_ in })
        } else { //iOS8,iOS9注册通知
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    public func pmp_didFailToRegisterForRemoteNotificationsWithError(error: Error) {
        DDLogError("Fail to get device token: \(error)")
    }
    
    public func pmp_didReceiveNotification(from: PushFrom, userInfo: [AnyHashable: Any]) {
        Async.main {
            self.receivePushData(userInfo: userInfo)
        }
    }
    
    func receivePushData(userInfo: [AnyHashable: Any]){
        DDLogVerbose("\(userInfo)")
        let title: String = "消息推送"
        let message = (userInfo["aps"] as? [AnyHashable: Any])?["alert"] as? String
        if let message = message {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "我知道了", style: .default, handler: { _ in
            })
            alert.addAction(action)
            UIViewController.topController?.showAlert(alert, completion: nil)
        }
    }

}
