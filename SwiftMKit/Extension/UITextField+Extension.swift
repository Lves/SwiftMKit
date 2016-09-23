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
    
    private struct AssociatedKeys {
        static var isFirstNan = 0
    }
    var isFirstNan: Bool {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.isFirstNan) as? Bool) ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.isFirstNan, newValue, .OBJC_ASSOCIATION_ASSIGN)
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
//    private var isFirstNan: NSNumber? {
//        get {
//            return
//        }
//        set {
//            self.isFirstNan = newValue
//        }
//    }
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
        func selectedRange() -> NSRange {
            let beginning = self.beginningOfDocument;
            //光标选择区域
            if let selectedRange = self.selectedTextRange {
                //选择的开始位置
                let selectionStart = selectedRange.start;
                //选择的结束位置
                let selectionEnd = selectedRange.end;
                //选择的实际位置
                var location = self.offsetFromPosition(beginning, toPosition: selectionStart)
                //选择的长度
                let length = self.offsetFromPosition(selectionStart, toPosition: selectionEnd)
                let txt = self.text ?? ""
                let index = txt.startIndex.advancedBy(location)
                let splitTxt = txt.substringToIndex(index)
                let list = splitTxt.split(" ")
                let count = list.count - 1
                if count == 1 {
                    
                } else if count == 2 {
                    location = location - 1
                } else if count == 0 {
                    location = location + 1
                }
                return NSMakeRange(location, length)
            }
            return NSMakeRange(0, 0)
        }
        func setSelectedRange(range : NSRange) {
            let beginning = self.beginningOfDocument;
            let startPosition = self.positionFromPosition(beginning, offset: range.location) ?? UITextPosition()
            let endPosition = self.positionFromPosition(beginning, offset: range.location + range.length) ??  UITextPosition()
            let selectionRange = self.textRangeFromPosition(startPosition, toPosition: endPosition)
            self.selectedTextRange = selectionRange
            self.sendActionsForControlEvents(.EditingChanged)
        }
        
        let RegStr4Number = "^\\d+$"
        // 判断用户输入的是否都是数字
        let predicate = NSPredicate(format: "SELF MATCHES %@", RegStr4Number)
        let xxx = "\(self.text ?? "")\(string)"
        let match = predicate.evaluateWithObject(noneSpaseString(xxx))
        if match == false && (self.text ?? "").length > 0 {
            // 如果有非整数的字符，就当做用户输入的是用户名
            // 清空之前自动产生的空格
            if isFirstNan == false {
                let range = selectedRange()
                self.insertText(string)
                self.text = noneSpaseString(self.text)
                print("=================================== 第一次不都是整数  \(self.text)")
                isFirstNan = true
                //获取光标位置
                setSelectedRange(range)
                return false
            }
            return true
        } else {
            isFirstNan = false
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