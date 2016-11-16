//
//  GesturePasswordButton.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import EZSwiftExtensions

@IBDesignable
public class GesturePasswordButton: UIView {
    public var selected: Bool = false { didSet { setNeedsDisplay() } }
    public var success: Bool = true { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var lineSuccessColor: UIColor = UIColor(red: 2/255, green: 174/255, blue: 240/255, alpha: 1) { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var lineFailureColor: UIColor = UIColor(red: 208/255, green: 36/255, blue: 36/255, alpha: 1) { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var dotSuccessColor: UIColor = UIColor(red: 2/255, green: 174/255, blue: 240/255, alpha: 1) { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var dotFailureColor: UIColor = UIColor(red: 208/255, green: 36/255, blue: 36/255, alpha: 1) { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var colorFillAlpha: CGFloat = 0.3 { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var dotNormalColor: UIColor = UIColor.whiteColor() { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var buttonBorderWidth: CGFloat = 2 { didSet { setNeedsDisplay() } }
    @IBInspectable
    public var innerCircleSizePercent: CGFloat = 0.25 { didSet { setNeedsDisplay() } }
    /// 标识是否画实心内圆
    public var innerCircleSolid = false { didSet { setNeedsDisplay() } }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public func setupUI() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    public override func drawRect(rect: CGRect) {
        // Drawing code
        
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        
        if(selected){
            if(success){
                var (r,g,b,a) = lineSuccessColor.colorComponents()
                CGContextSetRGBStrokeColor(context, r, g, b, a) //线条颜色
                (r,g,b,a) = dotSuccessColor.colorComponents()
                CGContextSetRGBFillColor(context, r, g, b, a)
                
            }else{
                var (r,g,b,a) = lineFailureColor.colorComponents()
                CGContextSetRGBStrokeColor(context, r, g, b, a) //线条颜色
                (r,g,b,a) = dotFailureColor.colorComponents()
                CGContextSetRGBFillColor(context, r, g, b, a)
            }
            
            let frame: CGRect = CGRectMake(bounds.size.width/2-bounds.size.width*innerCircleSizePercent/2+1, bounds.size.height/2-bounds.size.height*innerCircleSizePercent/2, bounds.size.width * innerCircleSizePercent, bounds.size.height * innerCircleSizePercent);
            
            CGContextAddEllipseInRect(context,frame);
            CGContextFillPath(context);
            
        }else{
            CGContextSetLineWidth(context, buttonBorderWidth)
            let (r,g,b,a) = dotNormalColor.colorComponents()
            CGContextSetRGBStrokeColor(context, r,g,b,a);//线条颜色
            let frame: CGRect = CGRectMake(bounds.size.width/2-bounds.size.width*innerCircleSizePercent/2+1, bounds.size.height/2-bounds.size.height*innerCircleSizePercent/2, bounds.size.width * innerCircleSizePercent, bounds.size.height * innerCircleSizePercent);
            frame.x
            CGContextAddEllipseInRect(context, frame)
            if innerCircleSolid {
                CGContextSetRGBFillColor(context, r, g, b, a)
                CGContextFillPath(context)
            } else {
                CGContextStrokePath(context)
            }
        }
        
        CGContextSetLineWidth(context, buttonBorderWidth)
        
        let frame: CGRect = CGRectMake(buttonBorderWidth, buttonBorderWidth, bounds.size.width-buttonBorderWidth*1.5, bounds.size.height-buttonBorderWidth*1.5)
        CGContextAddEllipseInRect(context, frame)
        
        CGContextStrokePath(context)
        
        if (selected) {
            let (r,g,b,_) = success ? dotSuccessColor.colorComponents() : dotFailureColor.colorComponents()
            CGContextSetRGBFillColor(context, r, g, b, colorFillAlpha)
            CGContextAddEllipseInRect(context, frame)
        }
        
        CGContextFillPath(context)
    }
    
    
    
}

