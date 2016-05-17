//
//  GesturePasswordView.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

@IBDesignable
public class GesturePasswordView: UIView {
    
    @IBInspectable
    public var padding: CGFloat = 20 { didSet { setNeedsDisplay() } }
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
    
    public var buttons = [GesturePasswordButton]()
    
    
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
    
    public override func drawRect(rect: CGRect) {
        let length = (self.w - 2 * padding) / 3
        self.removeSubviews()
        for index in 0..<9 {
            let row = index / 3
            let col = index % 3
            let button = GesturePasswordButton(frame: CGRectMake(CGFloat(row) * (length + padding), CGFloat(col) * (length + padding), length, length))
            button.lineSuccessColor = lineSuccessColor
            button.lineFailureColor = lineFailureColor
            button.dotSuccessColor = dotSuccessColor
            button.dotFailureColor = dotFailureColor
            button.colorFillAlpha = colorFillAlpha
            button.dotNormalColor = dotNormalColor
            button.buttonBorderWidth = buttonBorderWidth
            button.tag = index + 1
            buttons.append(button)
            self.addSubview(button)
        }
    }
}
