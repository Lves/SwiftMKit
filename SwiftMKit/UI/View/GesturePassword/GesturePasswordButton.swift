//
//  GesturePasswordButton.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class GesturePasswordButton: UIView {
    open var selected: Bool = false { didSet { setNeedsDisplay() } }
    open var success: Bool = true { didSet { setNeedsDisplay() } }
    @IBInspectable
    open var lineSuccessColor: UIColor = UIColor(red: 2/255, green: 174/255, blue: 240/255, alpha: 1) { didSet { setNeedsDisplay() } }
    @IBInspectable
    open var lineFailureColor: UIColor = UIColor(red: 208/255, green: 36/255, blue: 36/255, alpha: 1) { didSet { setNeedsDisplay() } }
    @IBInspectable
    open var dotSuccessColor: UIColor = UIColor(red: 2/255, green: 174/255, blue: 240/255, alpha: 1) { didSet { setNeedsDisplay() } }
    @IBInspectable
    open var dotFailureColor: UIColor = UIColor(red: 208/255, green: 36/255, blue: 36/255, alpha: 1) { didSet { setNeedsDisplay() } }
    @IBInspectable
    open var colorFillAlpha: CGFloat = 0.3 { didSet { setNeedsDisplay() } }
    @IBInspectable
    open var dotNormalColor: UIColor = UIColor.white { didSet { setNeedsDisplay() } }
    @IBInspectable
    open var buttonBorderWidth: CGFloat = 2 { didSet { setNeedsDisplay() } }
    @IBInspectable
    open var innerCircleSizePercent: CGFloat = 0.25 { didSet { setNeedsDisplay() } }
    /// 标识是否画实心内圆
    open var innerCircleSolid = false { didSet { setNeedsDisplay() } }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    open func setupUI() {
        self.backgroundColor = UIColor.clear
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    open override func draw(_ rect: CGRect) {
        // Drawing code
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        if(selected){
            if(success){
                var (r,g,b,a) = lineSuccessColor.colorComponents()
                context.setStrokeColor(red: r, green: g, blue: b, alpha: a) //线条颜色
                (r,g,b,a) = dotSuccessColor.colorComponents()
                context.setFillColor(red: r, green: g, blue: b, alpha: a)
                
            }else{
                var (r,g,b,a) = lineFailureColor.colorComponents()
                context.setStrokeColor(red: r, green: g, blue: b, alpha: a) //线条颜色
                (r,g,b,a) = dotFailureColor.colorComponents()
                context.setFillColor(red: r, green: g, blue: b, alpha: a)
            }
            
            let frame: CGRect = CGRect(x: bounds.size.width/2-bounds.size.width*innerCircleSizePercent/2+1, y: bounds.size.height/2-bounds.size.height*innerCircleSizePercent/2, width: bounds.size.width * innerCircleSizePercent, height: bounds.size.height * innerCircleSizePercent);
            
            context.addEllipse(in: frame);
            context.fillPath();
            
        }else{
            context.setLineWidth(buttonBorderWidth)
            let (r,g,b,a) = dotNormalColor.colorComponents()
            context.setStrokeColor(red: r,green: g,blue: b,alpha: a);//线条颜色
            let frame: CGRect = CGRect(x: bounds.size.width/2-bounds.size.width*innerCircleSizePercent/2+1, y: bounds.size.height/2-bounds.size.height*innerCircleSizePercent/2, width: bounds.size.width * innerCircleSizePercent, height: bounds.size.height * innerCircleSizePercent);
            context.addEllipse(in: frame)
            if innerCircleSolid {
                context.setFillColor(red: r, green: g, blue: b, alpha: a)
                context.fillPath()
            } else {
                context.strokePath()
            }
        }
        
        context.setLineWidth(buttonBorderWidth)
        
        let frame: CGRect = CGRect(x: buttonBorderWidth, y: buttonBorderWidth, width: bounds.size.width-buttonBorderWidth*1.5, height: bounds.size.height-buttonBorderWidth*1.5)
        context.addEllipse(in: frame)
        
        context.strokePath()
        
        if (selected) {
            let (r,g,b,_) = success ? dotSuccessColor.colorComponents() : dotFailureColor.colorComponents()
            context.setFillColor(red: r, green: g, blue: b, alpha: colorFillAlpha)
            context.addEllipse(in: frame)
        }
        
        context.fillPath()
    }
    
    
    
}

