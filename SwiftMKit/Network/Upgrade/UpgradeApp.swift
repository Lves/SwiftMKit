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
    open static var alertController: UIAlertController?
    open static var appProtocol: UpgradeAppProtocol?
    open static func checkUpgrade() {
        let version = appProtocol?.version ?? "0"
        DDLogInfo("[UpgradeApp] 开始检测新版本: 当前版本 \(version)")
        appProtocol?.requestUpgrade(appProtocol?.appId ?? "", version: version, channelId: appProtocol?.channelId ?? "", deviceId: UIDevice.current.uuid, completion: { (needUpgrade, newVersion, upgradeMessage, downloadUrl) in
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
    open static func showUpgradeAlert(_ forceUpgrade: Bool, newVersion: String, upgradeMessage: String, downloadUrl: String) {
        let alert = UIAlertController(title: "发现新版本", message: upgradeMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "立即下载", style: .default) { _ in
            if let url = URL(string: downloadUrl) {
                if UIApplication.shared.canOpenURL(url) {
                    DDLogInfo("[UpgradeApp] 跳转下载地址: \(downloadUrl)")
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
    open class func showUpgradeAlertAfterExit(_ forceUpgrade: Bool, newVersion: String, upgradeMessage: String, downloadUrl: String) {
        let alert = UIAlertController(title: "发现新版本", message: upgradeMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "立即下载", style: .default) { _ in
            if let url = URL(string: downloadUrl) {
                if UIApplication.shared.canOpenURL(url) {
                    DDLogInfo("[UpgradeApp] 跳转下载地址: \(downloadUrl)")
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }else{
                        UIApplication.shared.openURL(url)
                    }
                    exit(0)
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
    fileprivate static func getViewController() -> UIViewController? {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindowLevelNormal {
            let windows = UIApplication.shared.windows
            for tmpWin in windows {
                if tmpWin.windowLevel == UIWindowLevelNormal {
                    window = tmpWin
                    break
                }
            }
        }
        
        let frontView = window?.subviews.last
        let nextResponder = frontView?.next
        if nextResponder?.isKind(of: UIViewController.self) ?? false {
            return nextResponder as? UIViewController
        }
        return window?.rootViewController
    }
}
