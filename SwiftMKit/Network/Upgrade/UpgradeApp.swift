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
    public var appProtocol: UpgradeAppProtocol
    
    init(appProtocol: UpgradeAppProtocol) {
        self.appProtocol = appProtocol
        super.init()
    }
    
    public func checkUpgrade() {
        let version = appProtocol.version
        DDLogInfo("[UpgradeApp] 开始检测新版本: 当前版本-\(version)")
        appProtocol.checkUpgrade(appProtocol.appId, version: version, channelId: appProtocol.channelId, deviceId: UIDevice.currentDevice().uuid, completion: { (needUpgrade, newVersion, upgradeMessage, downloadUrl) in
            if needUpgrade {
                DDLogInfo("[UpgradeApp] 检测到新版本: \(newVersion)")
                let alert = UIAlertController(title: "提示", message: upgradeMessage, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "立即下载", style: .Default) { _ in
                    if let url = NSURL(string: downloadUrl) {
                        DDLogInfo("[UpgradeApp] 跳转下载地址: \(downloadUrl)")
                        UIApplication.sharedApplication().openURL(url)
                    } else {
                        DDLogError("[UpgradeApp] 下载地址错误: \(downloadUrl)")
                        let errorAlert = UIAlertController(title: "抱歉", message: "下载地址不正确，请稍后再试", preferredStyle: .Alert)
                        errorAlert.addAction(UIAlertAction(title: "我知道了", style: .Cancel, handler: nil))
                        if let vc = UIViewController.topController {
                            errorAlert.showViewController(vc, sender: nil)
                        }
                    }
                })
                alert.addAction(UIAlertAction(title: "我知道了", style: .Cancel, handler: nil))
                if let vc = UIViewController.topController {
                    alert.showViewController(vc, sender: nil)
                }
            } else {
                DDLogInfo("[UpgradeApp] 当前版本已是最新")
            }
        })
    }
}