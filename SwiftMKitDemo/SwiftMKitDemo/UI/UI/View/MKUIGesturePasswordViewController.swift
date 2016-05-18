//
//  MKUIGesturePasswordViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack
import ReactiveCocoa

class MKUIGesturePasswordViewController: BaseViewController {

    @IBAction func click_setPassword(sender: UIButton) {
        GesturePasswordViewController.lockScreen(.Reset)
    }
    @IBAction func click_verifyPassword(sender: UIButton) {
        GesturePasswordViewController.lockScreen()
    }
    @IBAction func click_alert(sender: UIButton) {
        let alert = UIAlertController(title: "提示", message: "我是一个弹窗", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "我知道了", style: .Default, handler: nil))
        self.showAlert(alert, completion: nil)
        Async.main(after: 1) {
            GesturePasswordViewController.lockScreen()
        }
    }
    
    
}


class GesturePasswordViewController: BaseViewController, GesturePasswordViewDelegate {
    
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var btnFingerPrint: UIButton!
    @IBOutlet weak var gesturePasswordView: GesturePasswordView?
    static var screenLocked = false
    var style: GestureTentacleStyle = .Verify {
        didSet {
            gesturePasswordView?.style = style
            updateUI()
        }
    }
    @IBAction func click_fingerPrint(sender: UIButton) {
        FingerPrint.authenticate("指纹解锁").observeOn(QueueScheduler.mainQueueScheduler).startWithNext { success in
            if success {
                GesturePasswordViewController.unlockScreen()
            }
        }
    }
    
    private static let sharedViewController: GesturePasswordViewController = UIViewController.instanceViewControllerInStoryboardWithName("GesturePasswordViewController", storyboardName: "Main") as! GesturePasswordViewController
    class func shared() -> GesturePasswordViewController {
        return GesturePasswordViewController.sharedViewController
    }
    
    class func lockScreen(style: GestureTentacleStyle = .Verify) {
        DDLogInfo("Lock screen")
        if screenLocked {
            return
        }
        let vc = GesturePasswordViewController.shared()
        vc.style = style
        let window = UIApplication.sharedApplication().delegate?.window
        window??.windowLevel = UIWindowLevelStatusBar
        window??.addSubview(vc.view)
        screenLocked = true
        vc.view.alpha = 0
        UIView.animateWithDuration(0.4) {
            vc.view.alpha = 1
        }
    }
    class func unlockScreen() {
        DDLogInfo("Unlock screen")
        if !screenLocked {
            return
        }
        let vc = GesturePasswordViewController.shared()
        UIView.animateWithDuration(0.4, animations: {
            vc.view.alpha = 0
        }) { completed in
            vc.view.removeFromSuperview()
            vc.reset()
        }
        let window = UIApplication.sharedApplication().delegate?.window
        window??.windowLevel = UIWindowLevelNormal
        screenLocked = false
    }
    
    override func setupUI() {
        super.setupUI()
        gesturePasswordView?.delegate = self
        gesturePasswordView?.style = style
        updateUI()
        if style == .Verify {
            FingerPrint.isSupport().on(
                next: { [weak self] _ in self?.btnFingerPrint.hidden = false},
                failed: { [weak self] _ in self?.btnFingerPrint.hidden = true }).start()
        }
    }
    func updateUI() {
        if isViewLoaded() {
            switch style {
            case .Verify:
                lblInfo.text = "请绘制手势密码解锁"
                self.btnFingerPrint.hidden = false
            case .Reset:
                lblInfo.text = "请绘制手势密码"
                self.btnFingerPrint.hidden = true
            }
        }
    }
    func reset() {
        lblInfo.text = ""
        gesturePasswordView?.reset()
    }
    
    func gp_verification(success: Bool, message: String, canTryAgain: Bool) {
        DDLogInfo("结果：\(success) 消息：\(message) 能否再试：\(canTryAgain)")
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
        DDLogInfo("结果：\(success) 消息：\(message)")
        lblInfo.text = message
        if success {
            lblInfo.text = message
        } else {
            lblInfo.shake(3)
        }
    }
    func gp_confirmSetPassword(success: Bool, message: String) {
        DDLogInfo("结果：\(success) 消息：\(message)")
        lblInfo.text = message
        if success {
            lblInfo.text = message
            GesturePasswordViewController.unlockScreen()
        } else {
            lblInfo.shake(3)
        }
    }
}