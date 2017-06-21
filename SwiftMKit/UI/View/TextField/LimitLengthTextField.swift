//
//  LimitLengthTextField.swift
//  JimuDuMiao
//
//  Created by Mao on 04/01/2017.
//  Copyright © 2017 jm. All rights reserved.
//

import UIKit
import Foundation

public class UITextFieldMaxLengthObserver: NSObject {
    
    public func textChanged(textField: UITextField) {
        let destText = textField.text
        let maxLength = textField.maxLength
        if let destText = destText {
            // 对中文的特殊处理，shouldChangeCharactersInRangeWithReplacementString 并不响应中文输入法的选择事件
            // 如拼音输入时，拼音字母处于选中状态，此时不判断是否超长
            let selectedRange = textField.markedTextRange
            if selectedRange == nil || selectedRange!.start == selectedRange!.end {
                if destText.length > maxLength {
                    textField.text = destText.substring(to: destText.index(destText.startIndex, offsetBy: maxLength))
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
            guard let length = objc_getAssociatedObject(self, &AssociatedKeys.maxLength) as? NSNumber else {
                return Int.max
            }
            return length.intValue
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.maxLength, NSNumber(value: Int32(newValue)), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if maxLength > 0 {
                self.addTarget(observer, action:#selector(UITextFieldMaxLengthObserver.textChanged), for: .editingChanged)
            }
        }
    }
}
