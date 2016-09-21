//
//  UIself+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/29/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

public extension UITextField {
    public func rac_textSignalProducer() -> SignalProducer<String, NoError> {
        return self.rac_textSignal().toSignalProducer().map { $0 as! String }.flatMapError { _ in SignalProducer.empty }
    }
    @IBInspectable public var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
    @IBInspectable public var placeHolderFont: UIFont? {
        get {
            return self.placeHolderFont
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSFontAttributeName: newValue!])
        }
    }
    
    public func reformatCardNumber(range: NSRange, replaceString string: String) -> Bool {
        var text = self.text?.toNSString ?? ""
        var range = range
        let characterSet = NSCharacterSet(charactersInString: "0123456789")
        let string = string.stringByReplacingOccurrencesOfString(" ", withString: "").toNSString ?? ""
        if string.rangeOfCharacterFromSet(characterSet.invertedSet).location != NSNotFound {
            return false
        }
        let oldString = text.stringByReplacingOccurrencesOfString(" ", withString: "").toNSString
        text = text.stringByReplacingCharactersInRange(range, withString: string as String).toNSString
        let newString = text.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if oldString == newString && string == "" {
            range.location -= 1
            text = text.stringByReplacingCharactersInRange(range, withString: string as String)
        }
        text = text.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        var result = ""
        let i = 4
        while text.length > 0 {
            let subString = text.substringToIndex(min(text.length, i))
            result = result.stringByAppendingString(subString)
            if subString.length == i {
                result = result.stringByAppendingString(" ")
            }
            text = text.substringFromIndex(min(text.length, i))
        }
        result = result.stringByTrimmingCharactersInSet(characterSet.invertedSet)
        self.text = result
        if string == "" {
            range.location = (range.location >= result.length ? result.length : range.location)
            self.selectedTextRange = NSRange(location: range.location, length: 0).toTextRange(textInput: self)
        } else if range.location < result.length - 1 {
            range.location += 1
            if result.hasSuffix(" " + (string as String)) {
                range.location += 1
            }
            range.location = (range.location >= result.length ? result.length : range.location)
//            self.selectedTextRange = NSMakeRange(range.location, 0)
        }
        return false
    }
    public func reformatMobile(range: NSRange, replaceString string: String) -> Bool {
        
        func noneSpaseString(string: String?) -> String {
            return (string ?? "").stringByReplacingOccurrencesOfString(" ", withString: "")
        }
        func parseString(string: String?) -> String? {
            guard let str = string else { return nil }
            let mStr = NSMutableString(string: str.stringByReplacingOccurrencesOfString(" ", withString: ""))
            if  mStr.length > 3 {
                mStr.insertString(" ", atIndex: 3)
            }
            if mStr.length > 8 {
                mStr .insertString(" ", atIndex: 8)
            }
            return mStr as String
        }
        
        let RegStr4Number = "^\\d+$"
        // 判断用户输入的是否都是数字
        let predicate = NSPredicate(format: "SELF MATCHES %@", RegStr4Number)
        let xxx = "\(self.text ?? "")\(string)"
        let match = predicate.evaluateWithObject(noneSpaseString(xxx));
        if match == false {
            // 如果有非整数的字符，就当做用户输入的是用户名，不做任何处理
            return true
        } else {
            let text = self.text ?? ""
            let nsText = NSString(string: text)
            // 删除
            if string == "" {
                let ch = unichar(" ")
                // 删除一位
                if range.length == 1 {
                    // 最后一位,遇到空格则多删除一
                    if range.location == text.length-1 {
                        if  nsText.characterAtIndex(text.length-1) == ch {
                            self.deleteBackward()
                        }
                        return true
                    } else { //从中间删除
                        var offset = range.location
                        if range.location < text.length && nsText.characterAtIndex(range.location) == ch && self.selectedTextRange?.empty == true {
                            self.deleteBackward()
                            offset -= 1
                        }
                        self.deleteBackward()
                        self.text = parseString(self.text)
                        let newPos = self.positionFromPosition(self.beginningOfDocument, offset: offset) ?? UITextPosition()
                        self.selectedTextRange = self.textRangeFromPosition(newPos, toPosition: newPos)
                        return false
                    }
                } else if range.length > 1 {
                    var isLast = false
                    if  range.location + range.length == self.text?.length {
                        isLast = true
                    }
                    self.deleteBackward()
                    self.text = parseString(self.text)
                    var offset = range.location
                    if range.location == 3 || range.location == 8 {
                        offset += 1
                    }
                    if isLast {
                        
                    } else {
                        let newPos = self.positionFromPosition(self.beginningOfDocument, offset: offset) ?? UITextPosition()
                        self.selectedTextRange = self.textRangeFromPosition(newPos, toPosition: newPos)
                    }
                    return false
                } else {
                    return true
                }
            } else if  string.length > 0 {
                if noneSpaseString(self.text).length + string.length - range.length > 11 {
                    return false
                }
                self.insertText(string)
                self.text = parseString(self.text)
                var offset = range.location + string.length
                if range.location == 3 || range.location == 8 {
                    offset += 1
                }
                let newPos = self.positionFromPosition(self.beginningOfDocument, offset: offset) ?? UITextPosition()
                self.selectedTextRange = self.textRangeFromPosition(newPos, toPosition: newPos)
                return false
            } else {
                return true
            }
        }
        
        
    }
}