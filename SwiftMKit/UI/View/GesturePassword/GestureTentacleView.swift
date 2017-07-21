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
    case verify, reset
}

public protocol GestureTentacleDelegate : class {
    func gestureTouchBegin()
    func verification(_ result: String) -> Bool
    func resetPassword(_ result: String) -> Bool
}
public extension GestureTentacleDelegate {
    func gestureTouchBegin() {}
}

open class GestureTentacleView: UIView {
    
    open var lineSuccessColor: UIColor = UIColor(red: 2/255, green: 174/255, blue: 240/255, alpha: 1) { didSet { setNeedsDisplay() } }
    open var lineFailureColor: UIColor = UIColor(red: 208/255, green: 36/255, blue: 36/255, alpha: 1) { didSet { setNeedsDisplay() } }
    open var lineColorAlpha: CGFloat = 0.7 { didSet { setNeedsDisplay() } }
    open var lineWidth: CGFloat = 5 { didSet { setNeedsDisplay() } }
    
    var buttonArray = [GesturePasswordButton]()
    var touchesArray = [Dictionary<String, Float>]()
    var touchedArray = [String]()
    
    var lineStartPoint:CGPoint?
    var lineEndPoint:CGPoint?
    
    open weak var delegate: GestureTentacleDelegate?
    
    open var style: GestureTentacleStyle = .verify
    
    var success: Bool = false
    var drawed: Bool = false
    
    fileprivate var touching: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(type(of: self)))")
    }
    
    
    open func setupUI() {
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        success = true
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touching = true
        var touchPoint: CGPoint
        let touch: UITouch? = touches.first
        
        touchesArray.removeAll()
        touchedArray.removeAll()
        
        delegate?.gestureTouchBegin()
        
        success = true
        drawed = false
        
        if (touch != nil) {
            touchPoint = touch!.location(in: self)
            for i in 0..<buttonArray.count {
                let buttonTemp = buttonArray[i]
                buttonTemp.success = true
                buttonTemp.isSelected = false
                if (buttonTemp.frame.contains(touchPoint)) {
                    let frameTemp = buttonTemp.frame
                    let point = CGPoint(x: frameTemp.origin.x + frameTemp.size.width/2 + 1, y: frameTemp.origin.y + frameTemp.size.height/2)
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
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touchPoint: CGPoint
        let touch: UITouch? = touches.first
        if (touch != nil) {
            touchPoint = touch!.location(in: self)
            for i in 0..<buttonArray.count {
                let buttonTemp = buttonArray[i]
                if (buttonTemp.frame.contains(touchPoint)){
                    let tps = touchedArray.filter{ el in el == "num\(i)" }
                    if(tps.count > 0){
                        lineEndPoint = touchPoint
                        self.setNeedsDisplay()
                        return
                    }
                    touchedArray.append("num\(i)")
                    buttonTemp.isSelected = true
                    
                    buttonTemp.setNeedsDisplay()
                    
                    let frameTemp = buttonTemp.frame
                    let point = CGPoint(x: frameTemp.origin.x + frameTemp.size.width/2 + 1, y: frameTemp.origin.y + frameTemp.size.height/2)
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
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        case .verify:
            success = delegate?.verification(resultString) ?? false
        case .reset:
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
    open override func draw(_ rect: CGRect) {
        // Drawing code
        
        if(touchesArray.count<=0){
            return;
        }
        // println("drawRect\(touchedArray)")
        
        for var i in 0..<touchesArray.count {
            if i >= touchedArray.count { break }
            let context: CGContext = UIGraphicsGetCurrentContext()!
            
            if(touchesArray[i]["num"] == nil){
                touchesArray.remove(at: i)
                i = i-1
                continue
            }
            
            let (r,g,b,_) = success ? lineSuccessColor.colorComponents() : lineFailureColor.colorComponents()
            context.setStrokeColor(red: r, green: g, blue: b, alpha: lineColorAlpha) //线条颜色
            
            context.setLineWidth(lineWidth)
            
            context.move(to: CGPoint(x: CGFloat(touchesArray[i]["x"]!), y: CGFloat(touchesArray[i]["y"]!)))
            
            if (i < touchesArray.count-1) {
                
                context.addLine(to: CGPoint(x: CGFloat(touchesArray[i+1]["x"]!), y: CGFloat(touchesArray[i+1]["y"]!)))
            }else {
                
                if (success && drawed != true) {
                    context.addLine(to: CGPoint(x: lineEndPoint!.x, y: lineEndPoint!.y));
                }
            }
            context.strokePath()
            
        }
    }
    
    
    open func enterArgin() {
        if touching {
            return
        }
        touchesArray.removeAll()
        touchedArray.removeAll()
        for i in 0..<buttonArray.count {
            let buttonTemp = buttonArray[i]
            buttonTemp.success = true
            buttonTemp.isSelected = false
            buttonTemp.setNeedsDisplay()
        }
        self.setNeedsDisplay()
    }
    
    
}
