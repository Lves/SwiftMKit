//
//  KeyboardViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/11/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import IQKeyboardManager

class MKUIKeyboardViewController: BaseViewController, PasswordPannelDelegate {

    @IBOutlet weak var txtNormal: UITextField!
    @IBOutlet weak var txtNoDot: UITextField!
    @IBOutlet weak var txtMoney: UITextField!
    @IBOutlet weak var btnCommit: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.sharedManager().disabledToolbarClasses.addObject(MKUIKeyboardViewController)
        
        // Do any additional setup after loading the view.
    }
    override func setupUI() {
        super.setupUI()
        var keyboard = NumberKeyboard.keyboard(self.txtNormal, type: .Normal)
        self.txtNormal.inputView = keyboard
        keyboard = NumberKeyboard.keyboard(self.txtNoDot, type: .NoDot)
        self.txtNoDot.inputView = keyboard
        keyboard = NumberKeyboard.keyboard(self.txtMoney, type: .Money)
        self.txtMoney.inputView = keyboard
        
        btnCommit.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().startWithNext { [unowned self] _ in
            let pannel = PasswordPannel.pannel()
            pannel.delegate = self
            pannel.show(self)
        }
        
    }
    
    func pp_forgetPassword(pannel: PasswordPannel?) {
        
    }
    func pp_didInputPassword(pannel: PasswordPannel?, password: String, completion: ((Bool, String) -> Void)) {
        
        PX500PopularPhotosApiData(page:1, number:1).signal().on(
            next: { _ in
                completion(true, "成功")
            },
            failed: { _ in
                completion(false, "失败")
        }).start()
    }

}
