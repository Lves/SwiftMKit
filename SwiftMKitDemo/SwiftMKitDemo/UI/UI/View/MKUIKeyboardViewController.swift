//
//  KeyboardViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/11/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import IQKeyboardManager

class MKUIKeyboardViewController: BaseViewController {

    @IBOutlet weak var txtNormal: UITextField!
    @IBOutlet weak var txtNoDot: UITextField!
    @IBOutlet weak var txtMoney: UITextField!
    
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
        if let pannel = PasswordPannel.pannel() {
            pannel.showPasswordPannelInView(self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
