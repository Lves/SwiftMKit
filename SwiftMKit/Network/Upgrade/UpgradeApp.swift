//
//  UpgradeApp.swift
//  Merak
//
//  Created by Mao on 6/24/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

public class UpgradeApp : NSObject {
    public static var alertController: UIAlertController?
    public static var appProtocol: UpgradeAppProtocol?
    public static func checkUpgrade() {
        let version = appProtocol?.version ?? "0"
        DDLogInfo("[UpgradeApp] 开始检测新版本: 当前版本 \(version)")
        appProtocol?.requestUpgrade(appProtocol?.appId ?? "", version: version, channelId: appProtocol?.channelId ?? "", deviceId: UIDevice.currentDevice().uuid, completion: { (needUpgrade, newVersion, upgradeMessage, downloadUrl) in
            if needUpgrade {
                DDLogInfo("[UpgradeApp] 检测到新版本")
                DDLogInfo("[UpgradeApp] currentVersion: \(version)")
                DDLogInfo("[UpgradeApp] newVersion: \(newVersion)")
                DDLogInfo("[UpgradeApp] updateMessage: \(upgradeMessage)")
                DDLogInfo("[UpgradeApp] downloadUrl: \(downloadUrl)")
                UpgradeApp.showUpgradeAlert(false, newVersion: newVersion, upgradeMessage: upgradeMessage, downloadUrl: downloadUrl)
            } else {
                DDLogInfo("[UpgradeApp] 当前版本已是最新")
            }
        })
    }
    public static func showUpgradeAlert(forceUpgrade: Bool, newVersion: String, upgradeMessage: String, downloadUrl: String) {
        let alert = UIAlertController(title: "发现新版本", message: upgradeMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "立即下载", style: .Default) { _ in
            if let url = NSURL(string: downloadUrl) {
                if UIApplication.sharedApplication().canOpenURL(url) {
                    alertController = nil
                    DDLogInfo("[UpgradeApp] 跳转下载地址: \(downloadUrl)")
                    UIApplication.sharedApplication().openURL(url)
                    return
                }
            }
            DDLogError("[UpgradeApp] 下载地址错误: \(downloadUrl)")
            let errorAlert = UIAlertController(title: "抱歉", message: "下载地址不正确，请稍后再试", preferredStyle: .Alert)
            errorAlert.addAction(UIAlertAction(title: "我知道了", style: .Cancel, handler: { _ in
                alertController = nil
                if forceUpgrade {
                    exit(0)
                }
            }))
            if let vc = UIViewController.topController {
                alertController = errorAlert
                vc.showAlert(errorAlert, completion: nil)
            }
            })
        alert.addAction(UIAlertAction(title: "我知道了", style: .Cancel, handler: { _ in
            alertController = nil
            if forceUpgrade {
                exit(0)
            }
        }))
        if let vc = UIViewController.topController {
            if alertController != nil {
                if forceUpgrade {
                    alertController?.dismissVC(completion: nil)
                } else {
                    return
                }
            }
            alertController = alert
            vc.showAlert(alert, completion: nil)
        }
    }
}