//
//  KeyboardViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/11/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import IQKeyboardManager

class MKKeyboardViewController: BaseViewController {

    @IBOutlet weak var txtNormal: UITextField!
    @IBOutlet weak var txtNoDot: UITextField!
    @IBOutlet weak var txtMoney: UITextField!
    @IBOutlet weak var btnSuccess: UIButton!
    @IBOutlet weak var btnFail: UIButton!
    @IBOutlet weak var btnLock: UIButton!
    
    override func setupUI() {
        super.setupUI()
        IQKeyboardManager.sharedManager().disabledToolbarClasses.addObject(MKKeyboardViewController)
        self.title = "Keyboard View"

        var keyboard = NumberKeyboard.keyboard(self.txtNormal, type: .Normal)
        self.txtNormal.inputView = keyboard
        keyboard = NumberKeyboard.keyboard(self.txtNoDot, type: .NoDot)
        self.txtNoDot.inputView = keyboard
        keyboard = NumberKeyboard.keyboard(self.txtMoney, type: .Money)
        self.txtMoney.inputView = keyboard
        
        btnSuccess.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [unowned self] _ in
            let pannel = PasswordPannel.pannel()
            pannel.eventInputPassword = { _,_,finish in
                Async.main(after: 1) {
                    finish(true, "提交成功", .Normal)
                }
            }
            pannel.showInView(self.view)
        }
        btnFail.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [unowned self] _ in
            let pannel = PasswordPannel.pannel()
            pannel.eventInputPassword = { _,_,finish in
                Async.main(after: 1) {
                    finish(false, "提交失败", .PasswordWrong)
                }
            }
            pannel.showInView(self.view)
        }
        btnLock.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [unowned self] _ in
            let pannel = PasswordPannel.pannel()
            pannel.eventInputPassword = { _,_,finish in
                Async.main(after: 1) {
                    finish(false, "密码被锁", .PasswordLocked)
                }
            }
            pannel.showInView(self.view)
        }
        
    }

}
