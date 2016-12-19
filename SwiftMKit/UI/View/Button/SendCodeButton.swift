//
//  SendCodeButton.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/26/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import Aspects

open class SendCodeButton: UIButton {
    fileprivate var timer: Timer?
    fileprivate var stopTime: Int = 0
    
    open var countDownSeconds: Int = 60
    open var timeupTitle: String = "重新获取"
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open func countDown() {
        countDown(countDownSeconds)
    }
    open func countDown(_ seconds: Int) {
        stop()
        self.isSelected = true
        self.isUserInteractionEnabled = false
        self.stopTime = Date().timeIntervalSince1970.toInt + seconds
        self.showRemainSecond()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(SendCodeButton.timerCountDown), userInfo: nil, repeats: true)
    }
    
    open func stop() {
        timer?.invalidate()
        timer = nil
        self.isSelected = false
        self.isUserInteractionEnabled = true
    }
    
    fileprivate func showRemainSecond() {
        let now = Date().timeIntervalSince1970.toInt
        setTitle("\(stopTime - now)秒后可重发", for: .selected)
    }
    @objc fileprivate func timerCountDown() {
        let now = Date().timeIntervalSince1970.toInt
        if now > stopTime {
            stop()
            setTitle(timeupTitle, for: UIControlState())
        } else {
            showRemainSecond()
        }
    }
    open override func removeFromSuperview() {
        stop()
        super.removeFromSuperview()
    }
}
