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
import ReactiveSwift
import SwiftMKit
import LocalAuthentication

class MKGesturePasswordViewController: BaseViewController {

    @IBAction func click_setPassword(_ sender: UIButton) {
        GesturePasswordViewController.lockScreen(.reset)
    }
    @IBAction func click_verifyPassword(_ sender: UIButton) {
        GesturePasswordViewController.lockScreen()
    }
    @IBAction func click_alert(_ sender: UIButton) {
        let alert = UIAlertController(title: "提示", message: "我是一个弹窗", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "我知道了", style: .default, handler: nil))
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
    var style: GestureTentacleStyle = .verify {
        didSet {
            gesturePasswordView?.style = style
            updateUI()
        }
    }
    @IBAction func click_fingerPrint(_ sender: UIButton) {
        FingerPrint.authenticate("指纹解锁").observe(on: QueueScheduler.main).flatMapError({ _ in
            return SignalProducer.empty
        }).startWithValues { success in
            if success {
                GesturePasswordViewController.unlockScreen()
            }
        }
    }
    
    fileprivate static let sharedViewController: GesturePasswordViewController = UIViewController.instanceViewControllerInStoryboard(withName: "GesturePasswordViewController", storyboardName: "MKGesturePasswordView") as! GesturePasswordViewController
    class func shared() -> GesturePasswordViewController {
        return GesturePasswordViewController.sharedViewController
    }
    
    class func lockScreen(_ style: GestureTentacleStyle = .verify) {
        DDLogInfo("Lock screen")
        if screenLocked {
            return
        }
        let vc = GesturePasswordViewController.shared()
        vc.style = style
        let window = UIApplication.shared.delegate?.window
        window??.windowLevel = UIWindowLevelStatusBar
        window??.addSubview(vc.view)
        screenLocked = true
        vc.view.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            vc.view.alpha = 1
        }) 
    }
    class func unlockScreen() {
        DDLogInfo("Unlock screen")
        if !screenLocked {
            return
        }
        let vc = GesturePasswordViewController.shared()
        UIView.animate(withDuration: 0.4, animations: {
            vc.view.alpha = 0
        }, completion: { completed in
            vc.view.removeFromSuperview()
            vc.reset()
        }) 
        let window = UIApplication.shared.delegate?.window
        window??.windowLevel = UIWindowLevelNormal
        screenLocked = false
    }
    
    override func setupUI() {
        super.setupUI()
        gesturePasswordView?.delegate = self
        gesturePasswordView?.style = style
        updateUI()
        if style == .verify {
            FingerPrint.isSupport().on(
                failed: { [weak self] _ in self?.btnFingerPrint.isHidden = true },
                value: { [weak self] _ in self?.btnFingerPrint.isHidden = false}).start()
        }
    }
    func updateUI() {
        if isViewLoaded {
            switch style {
            case .verify:
                lblInfo.text = "请绘制手势密码解锁"
                self.btnFingerPrint.isHidden = false
            case .reset:
                lblInfo.text = "请绘制手势密码"
                self.btnFingerPrint.isHidden = true
            }
        }
    }
    func reset() {
        lblInfo.text = ""
        gesturePasswordView?.reset()
    }
    
    func gp_verification(_ success: Bool, message: String, canTryAgain: Bool) {
        DDLogInfo("结果：\(success) 消息：\(message) 能否再试：\(canTryAgain)")
        lblInfo.text = message
        if success {
            lblInfo.text = message
            GesturePasswordViewController.unlockScreen()
        } else {
            lblInfo.shake(withCount: 3)
            if !canTryAgain {
                Async.main(after: 1) {
                    GesturePasswordViewController.unlockScreen()
                }
            }
        }
    }
    func gp_setPassword(_ success: Bool, message: String) {
        DDLogInfo("结果：\(success) 消息：\(message)")
        lblInfo.text = message
        if success {
            lblInfo.text = message
        } else {
            lblInfo.shake(withCount: 3)
        }
    }
    func gp_confirmSetPassword(_ success: Bool, message: String) {
        DDLogInfo("结果：\(success) 消息：\(message)")
        lblInfo.text = message
        if success {
            lblInfo.text = message
            GesturePasswordViewController.unlockScreen()
        } else {
            lblInfo.shake(withCount: 3)
        }
    }
}
