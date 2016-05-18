//
//  MKUIIndicatorButtonViewController.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MKUIIndicatorButtonViewController: BaseViewController {

    @IBOutlet weak var btnTest: IndicatorButton!
    
    override func setupUI() {
        super.setupUI()
        
        btnTest.cornerRadius = 3
        btnTest.upToDown = false
        btnTest.rac_signalForControlEvents(.TouchUpInside).subscribeNext { (sender) in
            DDLogInfo("\(sender)")
            self.btnTest.ib_loadingWithTitle("正在拼命加载中...")
        }
    }
}
