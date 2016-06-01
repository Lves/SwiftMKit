//
//  MKUICustomAlertViewController.swift
//  SwiftMKitDemo
//
//  Created by why on 16/5/30.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

class MKUICustomAlertViewController: BaseViewController {

    var alertview : AlertCustomBaseView?

    @IBAction func click_show(sender: UIButton) {
        self.alertview?.showAlertCustomView()

    }

    override func setupUI() {
        super.setupUI()
        
//        self.alertview = AlertCustomBaseView.alertCustomView(self)
    }
    
}
