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

public class SendCodeButton: UIButton {
    private var timer: NSTimer?
    private var stopTime: Int = 0
    
    public var countDownSeconds: Int = 60
    public var timeupTitle: String = "重新获取"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func countDown() {
        countDown(countDownSeconds)
    }
    public func countDown(seconds: Int) {
        stop()
        self.selected = true
        self.userInteractionEnabled = false
        self.stopTime = NSDate().timeIntervalSince1970.toInt + seconds
        self.showRemainSecond()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SendCodeButton.timerCountDown), userInfo: nil, repeats: true)
    }
    
    public func stop() {
        timer?.invalidate()
        timer = nil
        self.selected = false
        self.userInteractionEnabled = true
    }
    
    private func showRemainSecond() {
        let now = NSDate().timeIntervalSince1970.toInt
        setTitle("\(stopTime - now)秒后可重发", forState: .Selected)
    }
    @objc private func timerCountDown() {
        let now = NSDate().timeIntervalSince1970.toInt
        if now > stopTime {
            stop()
            setTitle(timeupTitle, forState: .Normal)
        } else {
            showRemainSecond()
        }
    }
    public override func removeFromSuperview() {
        stop()
        super.removeFromSuperview()
    }
}