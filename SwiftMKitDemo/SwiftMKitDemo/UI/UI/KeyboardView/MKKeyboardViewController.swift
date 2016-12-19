//
//  KeyboardViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/11/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import IQKeyboardManager
import ReactiveSwift
import ReactiveCocoa

class MKKeyboardViewController: BaseViewController {

    @IBOutlet weak var txtNormal: UITextField!
    @IBOutlet weak var txtNoDot: UITextField!
    @IBOutlet weak var txtMoney: UITextField!
    @IBOutlet weak var btnSuccess: UIButton!
    @IBOutlet weak var btnFail: UIButton!
    @IBOutlet weak var btnLock: UIButton!
    
    override func setupUI() {
        super.setupUI()
        IQKeyboardManager.shared().disabledToolbarClasses.add(MKKeyboardViewController.self)
        self.title = "Keyboard View"

        var keyboard = NumberKeyboard.keyboard(self.txtNormal, type: .normal)
        self.txtNormal.inputView = keyboard
        keyboard = NumberKeyboard.keyboard(self.txtNoDot, type: .noDot)
        self.txtNoDot.inputView = keyboard
        keyboard = NumberKeyboard.keyboard(self.txtMoney, type: .money)
        self.txtMoney.inputView = keyboard
        
        btnSuccess.reactive.trigger(for: .touchUpInside).observeValues { [unowned self] _ in
            let pannel = PasswordPannel.pannel()
            pannel.eventInputPassword = { _,_,finish in
                Async.main(after: 1) {
                    finish(true, "提交成功", .normal)
                }
            }
            pannel.showInView(self.view)
        }
        btnFail.reactive.trigger(for: .touchUpInside).observeValues { [unowned self] _ in
            let pannel = PasswordPannel.pannel()
            pannel.eventInputPassword = { _,_,finish in
                Async.main(after: 1) {
                    finish(false, "提交失败", .passwordWrong)
                }
            }
            pannel.showInView(self.view)
        }
        btnLock.reactive.trigger(for: .touchUpInside).observeValues { [unowned self] _ in
            let pannel = PasswordPannel.pannel()
            pannel.eventInputPassword = { _,_,finish in
                Async.main(after: 1) {
                    finish(false, "密码被锁", .passwordLocked)
                }
            }
            pannel.showInView(self.view)
        }
        
    }

}
