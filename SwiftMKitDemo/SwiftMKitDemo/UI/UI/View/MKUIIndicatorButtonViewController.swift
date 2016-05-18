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
        self.btnTest.setTitle("测试", forState: .Normal)
        self.btnTest.setTitle("测试正在拼命加载中...", forState: .Disabled)
        // FIXME: 注意内存泄露！！！
        btnTest.rac_signalForControlEvents(.TouchUpInside).subscribeNext { [weak self](sender) in
            self?.btnTest.enabled = false
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.btnTest.enabled = true
    }
}
