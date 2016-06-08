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
        //Range.Lenth will greater than 0 if user is deleting text - Allow it to replce
        if range.length > 0
        {
            return true
        }
        
        //Dont allow empty strings
        if string == " "
        {
            return false
        }
        
        //Check for max length including the spacers we added
        if range.location == 20
        {
            return false
        }
        
        var originalText = self.text
        let replacementText = string.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        //Verify entered text is a numeric value
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        for char in replacementText.unicodeScalars
        {
            if !digits.longCharacterIsMember(char.value)
            {
                return false
            }
        }
        
        //Put an empty space after every 4 places
        if originalText!.length % 5 == 0
        {
            originalText?.appendContentsOf(" ")
            self.text = originalText
        }
        return true

    }
}