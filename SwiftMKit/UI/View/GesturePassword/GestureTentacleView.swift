//
//  TentacleView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import CocoaLumberjack

public enum GestureTentacleStyle : Int {
    case Verify, Reset
}

public protocol GestureTentacleDelegate : class {
    func gestureTouchBegin()
    func verification(result: String) -> Bool
    func resetPassword(result: String) -> Bool
}
public extension GestureTentacleDelegate {
    func gestureTouchBegin() {}
}

public class GestureTentacleView: UIView {
    
    public var lineSuccessColor: UIColor = UIColor(red: 2/255, green: 174/255, blue: 240/255, alpha: 1) { didSet { setNeedsDisplay() } }
    public var lineFailureColor: UIColor = UIColor(red: 208/255, green: 36/255, blue: 36/255, alpha: 1) { didSet { setNeedsDisplay() } }
    public var lineColorAlpha: CGFloat = 0.7 { didSet { setNeedsDisplay() } }
    public var lineWidth: CGFloat = 5 { didSet { setNeedsDisplay() } }
    
    var buttonArray = [GesturePasswordButton]()
    var touchesArray = [Dictionary<String, Float>]()
    var touchedArray = [String]()
    
    var lineStartPoint:CGPoint?
    var lineEndPoint:CGPoint?
    
    public weak var delegate: GestureTentacleDelegate?
    
    public var style: GestureTentacleStyle = .Verify
    
    var success: Bool = false
    var drawed: Bool = false
    
    private var touching: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(self.dynamicType))")
    }
    
    
    public func setupUI() {
        self.backgroundColor = UIColor.clearColor()
        self.userInteractionEnabled = true
        success = true
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touching = true
        var touchPoint: CGPoint
        let touch: UITouch? = touches.first
        
        touchesArray.removeAll()
        touchedArray.removeAll()
        
        delegate?.gestureTouchBegin()
        
        success = true
        drawed = false
        
        if (touch != nil) {
            touchPoint = touch!.locationInView(self)
            for i in 0..<buttonArray.count {
                let buttonTemp = buttonArray[i]
                buttonTemp.success = true
                buttonTemp.selected = false
                if (CGRectContainsPoint(buttonTemp.frame, touchPoint)) {
                    let frameTemp = buttonTemp.frame
                    let point = CGPointMake(frameTemp.origin.x + frameTemp.size.width/2 + 1, frameTemp.origin.y + frameTemp.size.height/2)
                    var dict: Dictionary<String,Float> = [:]
                    dict["x"] = Float(point.x)
                    dict["y"] = Float(point.y)
                    //dict["num"] = Float(i)
                    
                    touchesArray.append(dict)
                    lineStartPoint = touchPoint
                }
                buttonTemp.setNeedsDisplay()
            }
            self.setNeedsDisplay()
        }
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touchPoint: CGPoint
        let touch: UITouch? = touches.first
        if (touch != nil) {
            touchPoint = touch!.locationInView(self)
            for i in 0..<buttonArray.count {
                let buttonTemp = buttonArray[i]
                if (CGRectContainsPoint(buttonTemp.frame, touchPoint)){
                    let tps = touchedArray.filter{ el in el == "num\(i)" }
                    if(tps.count > 0){
                        lineEndPoint = touchPoint
                        self.setNeedsDisplay()
                        return
                    }
                    touchedArray.append("num\(i)")
                    buttonTemp.selected = true
                    
                    buttonTemp.setNeedsDisplay()
                    
                    let frameTemp = buttonTemp.frame
                    let point = CGPointMake(frameTemp.origin.x + frameTemp.size.width/2 + 1, frameTemp.origin.y + frameTemp.size.height/2)
                    var dict: Dictionary<String,Float> = [:]
                    dict["x"] = Float(point.x)
                    dict["y"] = Float(point.y)
                    dict["num"] = Float(i)
                    
                    touchesArray.append(dict)
                    break;
                }
            }
            lineEndPoint = touchPoint
            self.setNeedsDisplay()
        }
        
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touching = false
        var resultString:String = ""
        
        //println("end....\(touchedArray)")
        for p in touchesArray {
            if (p["num"] == nil) {
                continue
            }
            let num = Int(p["num"]!)
            resultString = resultString + "\(num)"
        }
        drawed = true
        
        switch style {
        case .Verify:
            success = delegate?.verification(resultString) ?? false
        case .Reset:
            success = delegate?.resetPassword(resultString) ?? false
        }
        
        for i in 0..<touchesArray.count {
            
            if(touchesArray[i]["num"] == nil){
                continue
            }
            
            let selection:Int = Int(touchesArray[i]["num"]!)
            let buttonTemp = buttonArray[selection]
            buttonTemp.success = success
            buttonTemp.setNeedsDisplay()
        }
        self.setNeedsDisplay()
        
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    public override func drawRect(rect: CGRect) {
        // Drawing code
        
        if(touchesArray.count<=0){
            return;
        }
        // println("drawRect\(touchedArray)")
        
        for var i in 0..<touchesArray.count {
            if i >= touchedArray.count { break }
            let context: CGContextRef = UIGraphicsGetCurrentContext()!
            
            if(touchesArray[i]["num"] == nil){
                touchesArray.removeAtIndex(i)
                i = i-1
                continue
            }
            
            let (r,g,b,_) = success ? lineSuccessColor.colorComponents() : lineFailureColor.colorComponents()
            CGContextSetRGBStrokeColor(context, r, g, b, lineColorAlpha) //线条颜色
            
            CGContextSetLineWidth(context, lineWidth)
            
            CGContextMoveToPoint(context,CGFloat(touchesArray[i]["x"]!),CGFloat(touchesArray[i]["y"]!))
            
            if (i < touchesArray.count-1) {
                
                CGContextAddLineToPoint(context,CGFloat(touchesArray[i+1]["x"]!),CGFloat(touchesArray[i+1]["y"]!))
            }else {
                
                if (success && drawed != true) {
                    CGContextAddLineToPoint(context, lineEndPoint!.x,lineEndPoint!.y);
                }
            }
            CGContextStrokePath(context)
            
        }
    }
    
    
    public func enterArgin() {
        if touching {
            return
        }
        touchesArray.removeAll()
        touchedArray.removeAll()
        for i in 0..<buttonArray.count {
            let buttonTemp = buttonArray[i]
            buttonTemp.success = true
            buttonTemp.selected = false
            buttonTemp.setNeedsDisplay()
        }
        self.setNeedsDisplay()
    }
    
    
}
