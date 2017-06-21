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

open class UpgradeApp : NSObject {
    open static var alertShowing: Bool = false
    open static var alertController: UIAlertController?
    open static var appProtocol: UpgradeAppProtocol?
    open static func checkUpgrade() {
        let version = appProtocol?.version ?? "0"
        DDLogInfo("[UpgradeApp] 开始检测新版本: 当前版本 \(version)")
        appProtocol?.requestUpgrade(version: version, completion: { (needUpgrade, newVersion, upgradeMessage, downloadUrl) in
            if needUpgrade {
                DDLogInfo("检测到新版本")
                DDLogInfo("currentVersion: \(version)")
                DDLogInfo("newVersion: \(newVersion)")
                DDLogInfo("updateMessage: \(upgradeMessage)")
                DDLogInfo("downloadUrl: \(downloadUrl)")
                UpgradeApp.showUpgradeAlert(forceUpgrade: false, newVersion: newVersion, upgradeMessage: upgradeMessage, downloadUrl: downloadUrl)
            } else {
                DDLogInfo("当前版本已是最新")
            }
        })
    }
    private static var lastForceUpgrade = false
    open static func showUpgradeAlert(forceUpgrade: Bool, newVersion: String, upgradeMessage: String, downloadUrl: String) {
        let alert = UIAlertController(title: "发现新版本", message: upgradeMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "立即下载", style: .default) { _ in
            UpgradeApp.alertShowing = false
            lastForceUpgrade = false
            if let url = URL(string: downloadUrl) {
                if UIApplication.shared.canOpenURL(url) {
                    DDLogInfo("跳转下载地址: \(downloadUrl)")
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }else{
                        UIApplication.shared.openURL(url)
                    }
                    return
                }
            }
            DDLogError("[UpgradeApp] 下载地址错误: \(downloadUrl)")
            let errorAlert = UIAlertController(title: "抱歉", message: "下载地址不正确，请稍后再试", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: forceUpgrade ? "退出" : "我知道了", style: .cancel, handler: { _ in
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
        alert.addAction(UIAlertAction(title: forceUpgrade ? "退出" : "我知道了", style: .cancel, handler: { _ in
            UpgradeApp.alertShowing = false
            lastForceUpgrade = false
            alertController = nil
            if forceUpgrade {
                exit(0)
            }
        }))
        
        if let vc = UIViewController.topController {
            if alertController != nil {
                if forceUpgrade && !lastForceUpgrade {
                    alertController?.dismissVC(completion: nil)
                    UpgradeApp.alertShowing = false
                } else {
                    return
                }
            }
            alertController = alert
            if (!UpgradeApp.alertShowing){
                vc.showAlert(alert, completion: nil)
                lastForceUpgrade = forceUpgrade
                UpgradeApp.alertShowing = true
            }
        }
    }
    public class func showUpgradeAlertAfterExit(forceUpgrade: Bool, newVersion: String, upgradeMessage: String, downloadUrl: String) {
        let alert = UIAlertController(title: "发现新版本", message: upgradeMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "立即下载", style: .default) { _ in
            if let url = URL(string: downloadUrl) {
                if UIApplication.shared.canOpenURL(url) {
                    DDLogInfo("[UpgradeApp] 跳转下载地址: \(downloadUrl)")
                    if #available(iOS 10.0, *) {

                        UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                            exit(0)
                        })
                    }else{
                        UIApplication.shared.openURL(url)
                        Async.main(after: 5) {
                            exit(0)
                        }
                    }
                }
            }
            DDLogError("下载地址错误: \(downloadUrl)")
            let errorAlert = UIAlertController(title: "抱歉", message: "下载地址不正确，请稍后再试", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: forceUpgrade ? "退出" : "我知道了", style: .cancel, handler: { _ in
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
        alert.addAction(UIAlertAction(title: forceUpgrade ? "退出" : "我知道了", style: .cancel, handler: { _ in
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
