//
//  PasswordText.swift
//  SwiftMKitDemo
//
//  Created by jimubox on 16/5/24.
//  Copyright © 2016年 cdts. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManager

public protocol PasswordTextViewDelegate: class {
    func pt_didInputSixNumber(textView: PasswordTextView?, password : String)
}
public extension PasswordTextViewDelegate {
    func pt_didInputSixNumber(textView: PasswordTextView?, password : String){}
}

public class PasswordTextView : UIView, UITextFieldDelegate {
    private struct InnerConstant {
        static let MaxCount = 6
        static let InputViewBackGroundColor = UIColor(hex6: 0xF3F6FC)
        static let borderWidth = 1
        static let dotColor = UIColor.blackColor()
        static let textColor = UIColor.blackColor()
        static let textFont = UIFont.systemFontOfSize(20)
        static let originEnableAutoToolbar = false
    }
    
    var isShow: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    var inputTextField = UITextField()
    
    public weak var delegate: PasswordTextViewDelegate?
    public var password: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    public var inputViewColor = InnerConstant.InputViewBackGroundColor
    public var borderWidth = InnerConstant.borderWidth
    public var dotColor = InnerConstant.dotColor
    public var textColor = InnerConstant.textColor
    public var textFont = InnerConstant.textFont
    public var originEnableAutoToolbar = InnerConstant.originEnableAutoToolbar
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    func setupUI() {
        backgroundColor = inputViewColor
        inputTextField.delegate = self
        inputTextField.inputView = NumberKeyboard.keyboard(inputTextField, type: .NoDot)
        addSubview(inputTextField)
        addTapGesture(target: self, action: #selector(active))
    }
    func active() {
        
        inputTextField.becomeFirstResponder()
    }
    func inactive() {
        inputTextField.resignFirstResponder()
    }
    
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let times = CGFloat(borderWidth)
        let rectangleWidth = (rect.width - 7*times) / CGFloat(InnerConstant.MaxCount)
        let rectangleHeight = rect.height - times * 2
        for index in 0...InnerConstant.MaxCount {
            let rectangleX = CGFloat(index) + CGFloat(index) * rectangleWidth + times
            let path = UIBezierPath(rect: CGRect(x:rectangleX, y:times, width:rectangleWidth, height:rectangleHeight))
            UIColor.whiteColor().setFill()
            UIColor.clearColor().setStroke()
            path.stroke()
            path.fill()
        }
        for index in 0..<password.length {
            let string = "\(password[index])"
            let floatIndex = CGFloat(index)
            let centerX = floatIndex + floatIndex * rectangleWidth + rectangleWidth/2
            let centerY = rectangleHeight/2
            if self.isShow {
                let textAttribute = [NSForegroundColorAttributeName: textColor,
                                            NSFontAttributeName: textFont]
                let strSize = string.sizeWithAttributes(textAttribute)
                let center = CGPointMake(centerX - strSize.width/2, centerY - strSize.height/2)
                string.drawAtPoint(center, withAttributes: textAttribute)
            } else {
                let path = UIBezierPath()
                let center = CGPointMake(centerX, centerY)
                path.addArcWithCenter(center, radius: 8, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
                dotColor.setFill()
                path.fill()
            }
        }
    }
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if password.length >= 6 && string != "" {
            return false
        }
        if string == "" {
            if password.length == 0 {
                return false
            }
            password = password.toNSString.substringToIndex(password.length - 1)
        } else {
            password += string
        }
        if password.length >= 6 {
            self.delegate?.pt_didInputSixNumber(self, password: password)
            return false
        } else {
            return true
        }
    }
    public func textFieldDidBeginEditing(textField: UITextField) {
        originEnableAutoToolbar = IQKeyboardManager.sharedManager().enableAutoToolbar
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    public func textFieldDidEndEditing(textField: UITextField) {
        IQKeyboardManager.sharedManager().enableAutoToolbar = originEnableAutoToolbar
    }
}


