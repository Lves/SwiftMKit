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
    
    public func pmp_didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: NSData) {
        let token = deviceToken.hexString
        if #available(iOS 10.0, *) {
            UserNotificationManager.deviceToken = token
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func pmp_registerRemoteNotification(application: UIApplication, launchOptions: [NSObject : AnyObject]?) {
        if #available(iOS 10.0, *) {
            let types = UserNotificationOption(arrayLiteral: [.Alert, .Badge, .Sound])
            UserNotificationManager.requestAuthorization(types, completionHandler: {_,_ in })
        } else { //iOS8,iOS9注册通知
            let setting = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(setting)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
    }
    
    public func pmp_didFailToRegisterForRemoteNotificationsWithError(error: NSError) {
        DDLogError("Fail to get device token: \(error)")
    }
    
    public func pmp_didReceiveNotification(from: PushFrom, userInfo: [NSObject : AnyObject]) {
        Async.main {
            self.receivePushData(userInfo)
        }
    }
    
    func receivePushData(userInfo: [NSObject: AnyObject]){
        DDLogVerbose("\(userInfo)")
        let title: String = "消息推送"
        let message = userInfo["aps"]?["alert"] as? String
        if let message = message {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let action = UIAlertAction(title: "我知道了", style: .Default, handler: { _ in
            })
            alert.addAction(action)
            UIViewController.topController?.showAlert(alert, completion: nil)
        }
    }

}
