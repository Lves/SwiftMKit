//
//  LimitLengthTextField.swift
//  JimuDuMiao
//
//  Created by Mao on 04/01/2017.
//  Copyright © 2017 jm. All rights reserved.
//

import UIKit

public class UITextFieldMaxLengthObserver: NSObject {
    
    public func textChanged(textField: UITextField) {
        let destText = textField.text
        let maxLength = textField.maxLength
        // 对中文的特殊处理，shouldChangeCharactersInRangeWithReplacementString 并不响应中文输入法的选择事件
        // 如拼音输入时，拼音字母处于选中状态，此时不判断是否超长
        let selectedRange = textField.markedTextRange
        if selectedRange != nil {
            if let destText = destText {
                if (destText.length ?? 0) > maxLength {
                    textField.text = destText.substringToIndex(destText.startIndex.advancedBy(maxLength))
                }
            }
        }
    }
}

let observer = UITextFieldMaxLengthObserver()

public extension UITextField {
    private struct AssociatedKeys {
        static var maxLength = 0
    }
    @IBInspectable public var maxLength: Int {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.maxLength) as? Int) ?? 0
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.maxLength, newValue, .OBJC_ASSOCIATION_ASSIGN)
            if maxLength > 0 {
                self.addTarget(observer, action:#selector(UITextFieldMaxLengthObserver.textChanged), forControlEvents: .EditingChanged)
            }
        }
    }
}
