//
//  MKUIGesturePasswordViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MKUIGesturePasswordViewController: BaseViewController {

    @IBAction func click_setPassword(sender: UIButton) {
        GesturePasswordViewController.lockScreen(.Reset)
    }
    @IBAction func click_verifyPassword(sender: UIButton) {
        GesturePasswordViewController.lockScreen()
    }
    
    
}


class GesturePasswordViewController: BaseViewController, GesturePasswordViewDelegate {
    
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var gesturePasswordView: GesturePasswordView?
    static var screenLocked = false
    var style: GestureTentacleStyle = .Verify {
        didSet {
            gesturePasswordView?.style = style
        }
    }
    
    static let shared: GesturePasswordViewController = UIViewController.instanceViewControllerInStoryboardWithName("GesturePasswordViewController", storyboardName: "Main") as! GesturePasswordViewController
    
    class func lockScreen(style: GestureTentacleStyle = .Verify) {
        DDLogInfo("Lock screen")
        if screenLocked {
            return
        }
        let vc = GesturePasswordViewController.shared
        vc.style = style
        let window = UIApplication.sharedApplication().delegate?.window
        window??.windowLevel = UIWindowLevelStatusBar
        window??.addSubview(vc.view)
        screenLocked = true
    }
    class func unlockScreen() {
        DDLogInfo("Unlock screen")
        if !screenLocked {
            return
        }
        let vc = GesturePasswordViewController.shared
        vc.view.removeFromSuperview()
        let window = UIApplication.sharedApplication().delegate?.window
        window??.windowLevel = UIWindowLevelNormal
        screenLocked = false
    }
    
    override func setupUI() {
        super.setupUI()
        gesturePasswordView?.delegate = self
        gesturePasswordView?.style = style
        switch style {
        case .Verify:
            lblInfo.text = "请绘制手势密码解锁"
        case .Reset:
            lblInfo.text = "请绘制手势密码"
        }
    }
    
    func gp_verification(success: Bool, message: String, canTryAgain: Bool) {
        DDLogInfo("\(success) \(message) \(canTryAgain)")
        lblInfo.text = message
        if success {
            lblInfo.text = message
            GesturePasswordViewController.unlockScreen()
        } else {
            lblInfo.shake(3)
            if !canTryAgain {
                Async.main(after: 1) {
                    GesturePasswordViewController.unlockScreen()
                }
            }
        }
    }
    func gp_setPassword(success: Bool, message: String) {
        DDLogInfo("\(success) \(message)")
        lblInfo.text = message
        if success {
            lblInfo.text = message
        } else {
            lblInfo.shake(3)
        }
    }
    func gp_confirmSetPassword(success: Bool, message: String) {
        DDLogInfo("\(success) \(message)")
        lblInfo.text = message
        if success {
            lblInfo.text = message
            GesturePasswordViewController.unlockScreen()
        } else {
            lblInfo.shake(3)
        }
    }
}