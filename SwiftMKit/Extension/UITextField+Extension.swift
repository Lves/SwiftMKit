//
//  UITextField+Extension.swift
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
            self.selectedTextRange = NSRange(location: range.location, length: 0).toTextRange(textInput: self)
        }
        return false
    }
}