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

    @IBOutlet weak var txtDemo: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.sharedManager().disabledToolbarClasses.addObject(MKUIKeyboardViewController)
        
        // Do any additional setup after loading the view.
    }
    override func setupUI() {
        super.setupUI()
        let keyboard = NumberKeyboard.keyboard(self.txtDemo, type: .Normal)
        self.txtDemo.inputView = keyboard
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
