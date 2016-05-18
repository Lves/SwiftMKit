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
            // 3秒后结束动画，隐藏菊花
            let delayInSeconds = 3.0
            let popTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(delayInSeconds * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                // 隐藏菊花
                self?.btnTest.enabled = true
                self?.btnTest.setTitle("测试通过，页面该跳转了", forState: .Normal)
            }
        }
    }
}
