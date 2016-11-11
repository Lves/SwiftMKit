//
//  MKUserNotificationViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 09/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import UserNotifications

class MKUserNotificationViewController: BaseViewController {
    
    private struct InnerConstant {
        static let NotifyIdentifier = "com.cdts.notify"
        static let NotifyCategoryIdentifier = "saySomethingCategory"
    }

    @IBOutlet weak var lblDeviceToken: UILabel!
    @IBOutlet weak var lblAuthorizeStatus: UILabel!
    @IBOutlet weak var lblSound: UILabel!
    @IBOutlet weak var lblBadge: UILabel!
    @IBOutlet weak var lblLockScreen: UILabel!
    @IBOutlet weak var lblAlert: UILabel!
    @IBOutlet weak var lblCarPlay: UILabel!
    @IBOutlet weak var lblAlertStyle: UILabel!
    @IBOutlet weak var lblNotificationCenter: UILabel!
    override func setupUI() {
        super.setupUI()
        lblDeviceToken.adjustsFontSizeToFitWidth = true
        loadData()
    }
    override func loadData() {
        super.loadData()
        
        if #available(iOS 10.0, *) {
            lblDeviceToken.text = UserNotificationManager.deviceToken
            
            UserNotificationManager.requestAuthorization([.Alert, .Sound, .Badge]) { (granted, error) in
            }
            
            UserNotificationManager.authorizationStatus.producer.startWithNext({ (status) in
                self.lblAuthorizeStatus.text = "\(status)"
            })
            
            UserNotificationManager.getNotificationSettings({ (settings) in
                self.lblSound.text = "\(settings.soundSetting)"
                self.lblBadge.text = "\(settings.badgeSetting)"
                self.lblAlert.text = "\(settings.alertSetting)"
                self.lblNotificationCenter.text = "\(settings.notificationCenterSetting)"
                self.lblLockScreen.text = "\(settings.lockScreenSetting)"
                self.lblCarPlay.text = "\(settings.carPlaySetting)"
                self.lblAlertStyle.text = "\(settings.alertStyle)"
            })
            
            UserNotificationManager.sharedInstance.willPresentNotificationHandler = { _ in
                return false
            }
            UserNotificationManager.sharedInstance.didRecieveNotificationHandler = { response in
                let category = response.notification.request.content.categoryIdentifier
                if category == "saySomethingCategory" {
                    var text: String = ""
                    let actionType = response.actionIdentifier
                    switch actionType {
                    case "action.input": text = (response as! UNTextInputNotificationResponse).userText
                    case "action.goodbye": text = "Goodbye"
                    case "action.none": text = ""
                    default: break
                    }
                    if !text.isEmpty {
                        let alert = UIAlertController(title: nil, message: "You just said \(text)", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Got It", style: .Default, handler: nil))
                        self.showAlert(alert, completion: nil)
                    }
                }
                return true
            }
        } else {
            // Fallback on earlier versions
        }
    }
    @IBAction func click_sendLocalNotify(sender: UIButton) {
        if #available(iOS 10.0, *) {
            UserNotificationManager.addNotify("Time Interval Notification", body: "My notification", triggerTime: 5, repeats: false, identifier: InnerConstant.NotifyIdentifier, categoryIdentifier: InnerConstant.NotifyCategoryIdentifier, withCompletionHandler: nil)
            showTip("5秒后将收到本地推送")
        } else {
            // Fallback on earlier versions
        }
    }
    @IBAction func click_cancelLocalNotify(sender: UIButton) {
        if #available(iOS 10.0, *) {
            UserNotificationManager.cancelNotifies([InnerConstant.NotifyIdentifier])
        } else {
            // Fallback on earlier versions
        }
    }
    @IBAction func click_removeDeliveredNotify(sender: UIButton) {
        if #available(iOS 10.0, *) {
            UserNotificationManager.removeDeliveredNotifies([InnerConstant.NotifyIdentifier])
        } else {
            // Fallback on earlier versions
        }
    }
    @IBAction func click_sendNotifyWithImage(sender: UIButton) {
        
        if #available(iOS 10.0, *) {
            var attachments = [UNNotificationAttachment]()
            if let imageURL = NSBundle.mainBundle().URLForResource("appicon", withExtension: "png") {
                if let attachment = try? UNNotificationAttachment(identifier: "imageAttachment", URL: imageURL, options: nil) {
                    attachments.append(attachment)
                }
            }
            UserNotificationManager.addNotify("Image Notification", body: "Show me an image", attachments: attachments, triggerTime: 5, repeats: false, identifier: InnerConstant.NotifyIdentifier, categoryIdentifier: InnerConstant.NotifyCategoryIdentifier, withCompletionHandler: nil)
            showTip("5秒后将收到本地推送")
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 10.0, *)
    static func registerNotificationCategory() {
        let saySomethingCategory: UNNotificationCategory = {
            // 1
            let inputAction = UNTextInputNotificationAction(
                identifier: "action.input",
                title: "Input",
                options: [.Foreground],
                textInputButtonTitle: "Send",
                textInputPlaceholder: "What do you want to say...")
            
            // 2
            let goodbyeAction = UNNotificationAction(
                identifier: "action.goodbye",
                title: "Goodbye",
                options: [.Foreground])
            
            let cancelAction = UNNotificationAction(
                identifier: "action.cancel",
                title: "Cancel",
                options: [.Destructive])
            
            // 3
            return UNNotificationCategory(identifier:"saySomethingCategory", actions: [inputAction, goodbyeAction, cancelAction], intentIdentifiers: [], options: [.CustomDismissAction])
        }()
        
        UNUserNotificationCenter.currentNotificationCenter().setNotificationCategories([saySomethingCategory])
    }
}

@available(iOS 10.0, *)
extension UNAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case NotDetermined: return "NotDetermined"
        case Denied: return "Denied"
        case Authorized: return "Authorized"
        }
    }
}

@available(iOS 10.0, *)
extension UNNotificationSetting: CustomStringConvertible {
    public var description: String {
        switch self {
        case NotSupported: return "NotSupported"
        case Disabled: return "Disabled"
        case Enabled: return "Enabled"
        }
    }
}

@available(iOS 10.0, *)
extension UNAlertStyle: CustomStringConvertible {
    public var description: String {
        switch self {
        case None: return "None"
        case Banner: return "Banner"
        case Alert: return "Alert"
        }
    }
}
