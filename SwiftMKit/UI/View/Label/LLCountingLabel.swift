//
//  LLCountingLabel.swift
//  Merak
//
//  Created by LiXingLe on 16/6/17.
//  Copyright © 2016年 jimubox. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit


struct InnerConstaint {
    static let kUILabelCounterRate:Float = 3.0
}


protocol LabelCounter {
    func update(t:Double) -> Double
}

class LabelCounterLinear: LabelCounter {
    func update(t: Double) -> Double {
        return t
    }
}

class LabelCounterEaseIn: LabelCounter {
    func update(t: Double) -> Double {
        return Double(powf(Float(t), LLCountingLabel.InnerConstaint.kUILabelCounterRate))

    }
}

class LabelCounterEaseOut: LabelCounter {
    func update(t: Double) -> Double {
        return 1.0-Double(powf((1.0-Float(t)), LLCountingLabel.InnerConstaint.kUILabelCounterRate))
    }
}

class LabelCounterEaseInOut: LabelCounter {
    func update(t: Double) -> Double {
        var tP = t
        var sign = 1

        let r = Int(LLCountingLabel.InnerConstaint.kUILabelCounterRate)
        if r % 2 == 0 {
            sign = -1
        }
        
        tP*=2
        if tP < 1 {

            return 0.5 * Double(powf(Float(tP), LLCountingLabel.InnerConstaint.kUILabelCounterRate))
        }else {
            return Double(sign) * 0.5 * (Double(powf(Float(tP)-2, LLCountingLabel.InnerConstaint.kUILabelCounterRate)) + Double(sign) * 2);
        }
    }
}


enum UILabelCountingMethod:Int {
    case EaseInOut
    case EaseIn
    case EaseOut
    case Linear
}


//MARK: - Label
class LLCountingLabel: UILabel {
    var startValue:Double = 0
    var destinationValue:Double?
    var progress:TimeInterval = 0
    var lastUpdate:TimeInterval?
    var totalTime:TimeInterval?
    var easingRate:Double?
    var timer:CADisplayLink?
    var counter:LabelCounter?
    var format:NSString?
    var method:UILabelCountingMethod = .EaseIn
    

    struct InnerConstaint {
        static let kUILabelCounterRate:Float = 3.0
        static let CountingAnimationDuration = 0.5
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    

    

    
    func setTextValue(value:Double)  {
        
        if let format = self.format {
            self.text = NSString.localizedStringWithFormat(format, value) as String
        }else {
            self.text = "\(value)"
        }
    }

    
    func countTo(to: Double, duration: TimeInterval = InnerConstaint.CountingAnimationDuration) {
        let old = self.text?.toDouble() ?? 0
        countForm(startValue: old, to: to, duration: duration)
    }
    
    func countForm(startValue:Double, to: Double, duration: TimeInterval = InnerConstaint.CountingAnimationDuration) {
        
        self.startValue = startValue
        self.destinationValue = to
        
        self.timer?.invalidate()
        self.timer = nil
        
        if duration == 0.0 {
            self.setTextValue(value: to)
        }
        easingRate = 3.0
        progress = 0
        totalTime = duration
        lastUpdate = NSDate.timeIntervalSinceReferenceDate
        if format == nil {
            format = "%f"
        }
        
        switch method {
        case .Linear:
            self.counter = LabelCounterLinear()
            break
        case .EaseIn:
            self.counter = LabelCounterEaseIn()
            break
        case .EaseOut:
            self.counter = LabelCounterEaseOut()
            break
        case .EaseInOut:
            self.counter = LabelCounterEaseInOut()
            break
        }
        
        let timer = CADisplayLink(target: self, selector: #selector(LLCountingLabel.updateValue))
        timer.frameInterval = 2
        timer.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        timer.add(to: RunLoop.main, forMode: .UITrackingRunLoopMode)
        self.timer = timer
    }
    
    
    @objc func updateValue(timer:Timer)  {
        let now  = NSDate.timeIntervalSinceReferenceDate
        self.progress = (now - self.lastUpdate!) + self.progress
        self.lastUpdate = now
        if self.progress >= self.totalTime!
        {
            self.timer?.invalidate()
            self.timer = nil
            self.progress = self.totalTime ?? 0
        }
        setTextValue(value: self.currentValue() ?? 0.00)
    }
    func currentValue() -> Double? {
        if progress>=totalTime! {
            return self.destinationValue
        }
        
        guard  let totalT = self.totalTime else{
            return 0
        }
        
        let percent = progress/totalT
        let updateVal = self.counter?.update(t: Double(percent)) ?? 0
        return startValue + (updateVal * ((destinationValue ?? 0) - startValue))
    }
    
}
