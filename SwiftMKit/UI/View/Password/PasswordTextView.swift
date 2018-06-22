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
    func pt_didInputSixNumber(_ textView: PasswordTextView?, password : String)
}
public extension PasswordTextViewDelegate {
    func pt_didInputSixNumber(_ textView: PasswordTextView?, password : String){}
}

open class PasswordTextView : UIView, UITextFieldDelegate {
    fileprivate struct InnerConstant {
        static let MaxCount = 6
        static let InputViewBackGroundColor = UIColor(hex6: 0xF3F6FC)
        static let borderWidth: CGFloat = 1
        static let dotColor = UIColor.black
        static let textColor = UIColor.black
        static let textFont = UIFont.systemFont(ofSize: 20)
        static let originEnableAutoToolbar = false
    }
    
    var isShow: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    var inputTextField = UITextField()
    
    open weak var delegate: PasswordTextViewDelegate?
    open var password: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    open var inputViewColor = InnerConstant.InputViewBackGroundColor
    open var borderWidth: CGFloat = InnerConstant.borderWidth
    open var dotColor = InnerConstant.dotColor
    open var textColor = InnerConstant.textColor
    open var textFont = InnerConstant.textFont
    open var originEnableAutoToolbar = InnerConstant.originEnableAutoToolbar
    
    var passwordPannelType: PasswordPannelType = .normal
    fileprivate var blackPointRadius: CGFloat = 8
    
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
        inputTextField.keyboardType = .numberPad //解决iPhoneX键盘会忽大忽小的问题
        inputTextField.delegate = self
        inputTextField.inputView = NumberKeyboard.keyboard(inputTextField, type: .noDot)
        addSubview(inputTextField)
        addTapGesture(target: self, action: #selector(active))
        blackPointRadius = (passwordPannelType == .normal) ? 8 : 5
        if passwordPannelType == .fund {
            borderWidth = 0.5
        }
    }
    @objc func active() {
        inputTextField.becomeFirstResponder()
    }
    func inactive() {
        inputTextField.resignFirstResponder()
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        let times = CGFloat(borderWidth)  // 竖线的宽度
        let rectangleWidth = (rect.width - 7*times) / CGFloat(InnerConstant.MaxCount)
        let rectangleHeight = rect.height - times * 2
        let fillColor = (passwordPannelType == .normal) ? UIColor.white : UIColor(hex6: 0xF8F8F8)
        let borderColor = (passwordPannelType == .normal) ? UIColor.clear : UIColor(hex6: 0xE5E5E5)
        for index in 0...InnerConstant.MaxCount {
            let rectangleX = CGFloat(index) + CGFloat(index) * rectangleWidth + times
            let path = UIBezierPath(rect: CGRect(x:rectangleX, y:times, width:rectangleWidth, height:rectangleHeight))
            fillColor.setFill()
            borderColor.setStroke()
            path.stroke()
            path.fill()
        }
        for index in 0..<password.length {
            let string = "\(password[index])"
            let floatIndex = CGFloat(index)
            let centerX = floatIndex + floatIndex * rectangleWidth + rectangleWidth/2
            let centerY = rectangleHeight/2
            if self.isShow {
                let textAttribute:[NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: textColor,
                                            NSAttributedStringKey.font: textFont]
                let strSize = string.size(withAttributes: textAttribute)
                let center = CGPoint(x: centerX - strSize.width/2, y: centerY - strSize.height/2)
                string.draw(at: center, withAttributes: textAttribute)
            } else {
                let path = UIBezierPath()
                let center = CGPoint(x: centerX, y: centerY)
                path.addArc(withCenter: center, radius: 5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
                dotColor.setFill()
                path.fill()
            }
        }
    }
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if password.length >= 6 && string != "" {
            return false
        }
        if string == "" {
            if password.length == 0 {
                return false
            }
            password = password.toNSString.substring(to: password.length - 1)
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
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        originEnableAutoToolbar = IQKeyboardManager.shared().isEnableAutoToolbar
        IQKeyboardManager.shared().isEnableAutoToolbar = false
    }
    open func textFieldDidEndEditing(_ textField: UITextField) {
        IQKeyboardManager.shared().isEnableAutoToolbar = originEnableAutoToolbar
    }
    
    deinit {
        print("PasswordTextView deinit")
    }
}


