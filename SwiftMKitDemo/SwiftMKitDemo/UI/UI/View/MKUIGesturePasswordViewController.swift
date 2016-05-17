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
        self.presentVC(self.initialedViewController("GesturePasswordController")!)
    }
    @IBAction func click_verifyPassword(sender: UIButton) {
        self.presentVC(self.initialedViewController("GesturePasswordController")!)
    }
    
    
}


class GesturePasswordController: BaseViewController, GesturePasswordViewDelegate {
    
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var gesturePasswordView: GesturePasswordView!
    var style: GestureTentacleStyle = .Verify {
        didSet {
            gesturePasswordView.style = style
        }
    }
    
    override func setupUI() {
        super.setupUI()
        gesturePasswordView.delegate = self
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
        } else {
            lblInfo.shake(3)
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
        } else {
            lblInfo.shake(3)
        }
    }
}