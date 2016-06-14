//
//  PasswordText.swift
//  SwiftMKitDemo
//
//  Created by jimubox on 16/5/24.
//  Copyright © 2016年 cdts. All rights reserved.
//

import Foundation
import UIKit

public protocol PasswordTextViewDelegate: class {
    func pt_didInputSixNumber(textView: PasswordTextView?, password : String)
}
public extension PasswordTextViewDelegate {
    func pt_didInputSixNumber(textView: PasswordTextView?){}
}

public class PasswordTextView : UIView, UITextFieldDelegate {
    private struct InnerConstant {
        static let MaxCount = 6
        static let InputViewBackGroundColor: UInt32 = 0xF3F6FC
    }
    
    var isShow: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    var inputNumArray = NSMutableArray()
    var inputTextField = UITextField()
    
    public weak var delegate: PasswordTextViewDelegate?
    public var password: String = ""
    public var inputViewColor = InnerConstant.InputViewBackGroundColor
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    func setupUI() {
        backgroundColor = UIColor(hex6: inputViewColor)
        inputTextField.delegate = self
        inputTextField.inputView = NumberKeyboard.keyboard(inputTextField, type: .NoDot)
        addSubview(inputTextField)
        addTapGesture(target: self, action: #selector(tapGestureRecognized(_:)))
    }
    func tapGestureRecognized(recognizer : UITapGestureRecognizer) {
        inputTextField.becomeFirstResponder()
    }
    
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let rectangleWidth = rect.width / CGFloat(InnerConstant.MaxCount)
        let rectangleHeight = rect.height
        for index in 0...InnerConstant.MaxCount {
            let rectangleX = CGFloat(index) + CGFloat(index) * rectangleWidth
            let path = UIBezierPath(rect: CGRect(x:rectangleX, y:0, width:rectangleWidth, height:rectangleHeight))
            UIColor.whiteColor().setFill()
            UIColor.clearColor().setStroke()
            path.stroke()
            path.fill()
        }
        inputNumArray.enumerateObjectsUsingBlock { (string, index, stop) in
            let floatIndex = CGFloat(index)
            let centerX = floatIndex + floatIndex * rectangleWidth + rectangleWidth/2
            let centerY = rectangleHeight/2
            if self.isShow {
                let strSize = string.sizeWithAttributes(nil)
                let center = CGPointMake(centerX - strSize.width/2, centerY - strSize.height/2)
                string.drawAtPoint(center, withAttributes: nil)
            } else {
                let path = UIBezierPath()
                let center = CGPointMake(centerX, centerY)
                path.addArcWithCenter(center, radius: 8, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
                UIColor.blackColor().setFill()
                path.fill()
            }
        }
    }
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            inputNumArray.removeLastObject()
            password = password.toNSString.substringToIndex(password.length - 1)
        } else {
            inputNumArray.addObject(string)
            password += string
        }
        if inputNumArray.count >= 6 {
            self.delegate?.pt_didInputSixNumber(self, password: password)
            setNeedsDisplay()
            return false
        } else {
            setNeedsDisplay()
            return true
        }
    }
}


