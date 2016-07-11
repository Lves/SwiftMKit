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

public class PushManager: NSObject {
    private override init() {
    }
    public static let shared = PushManager()
    public var pushUserInfo: [NSObject : AnyObject]?
    public func showPushAlert() {
        if let userInfo = pushUserInfo {
            DDLogInfo("[PushManager] 收到推送消息")
            DDLogInfo("[PushManager] \(pushUserInfo)")
            let title = "消息推送"
            let message : String? = userInfo["aps"]?["alert"] as? String
            if let message = message {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "我知道了", style: .Cancel, handler: nil))
                if let vc = UIViewController.topController {
                    if shouldShowPushAlertInViewController(vc) {
                        vc.showAlert(alert, completion: nil)
                        pushUserInfo = nil
                    }
                }
            }
            
        }
    }
    public func shouldShowPushAlertInViewController(vc: UIViewController) -> Bool {
        return true
    }
}
