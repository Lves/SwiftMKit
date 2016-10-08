//
//  String+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import CocoaLumberjack
import CommonCrypto

extension String {
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
    }
    
    func withoutSeparator() -> String {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).joinWithSeparator("")
    }
    
    // MARK: Format
    func formatCurrency(locale: String = "en_US") -> String {
        return NSString(string: self).doubleValue.formatCurrency(locale)
    }
    func formatCurrencyWithoutDot(locale: String = "en_US") -> String {
        return NSString(string: self).doubleValue.formatCurrencyWithoutDot(locale)
    }
    
    func jsonStringToDictionary() -> [String: AnyObject]? {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                DDLogError(error.description)
            }
        }
        return nil
    }
    
    func formatMask(range : NSRange) -> String {
        
        var mask: String = ""
        
        for _ in 0..<range.length {
            mask += "*"
        }
        let result: NSMutableString = NSMutableString(string: self)
        if self.length >= range.location + range.length {
            result.replaceCharactersInRange(range, withString: mask)
            return result as String
        } else if self.length >= range.location {
            return result.substringToIndex(range.location) + mask
        } else {
            return mask
        }
    }
    
    func urlEncode() -> String? {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
    }
    
    // MARK: Encrypt
    
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        let encryptString = String(format: hash as String)
        
        DDLogVerbose("Encrypt before：\(self)")
        DDLogVerbose("Encrypt after：\(encryptString)")
        return encryptString
    }
    
    func fromBase64() -> String {
        let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions(rawValue: 0))
        return String(data: data!, encoding: NSUTF8StringEncoding)!
    }
    
    func toBase64() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
    }
    
    func transformToPinyin() -> String? {
        let str = NSMutableString(string: self) as CFMutableString
        if CFStringTransform(str, nil, kCFStringTransformMandarinLatin, false) == true {
            if CFStringTransform(str, nil, kCFStringTransformStripDiacritics, false) == true {
                return str as String
            }
        }
        return nil
    }
    
    // MARK: Reverse
    func reverse() -> String {
        return String(self.characters.reverse())
    }
    
    ///  加密手机号（186****6789）
    func encryPhoneNo() -> String {
        if self.length == 11 {
            let startIndex = self.startIndex.advancedBy(3)
            let endIndex = startIndex.advancedBy(4)
            let range = Range(start: startIndex, end: endIndex)
            let newPhone = self.stringByReplacingCharactersInRange(range, withString: "****")
            return newPhone
        } else {
            return self
        }
    }
    func formatTimestampToDateString(format: String = "yyyy-MM-dd") -> String {
        guard self.length > 0 else { return "" }
        let tmp = self.toDouble() ?? 0
        // NSTimeInterval
        let timestamp = self.length >= 13 ? tmp / 1000.0 : tmp
        let date = NSDate(timeIntervalSince1970: timestamp)
        let fmt = NSDateFormatter()
        fmt.dateFormat = format
        return fmt.stringFromDate(date)
    }
    func formatDateStringToOther(oFormat:String = "yyyyMMdd",toFormat:String = "yyyy-MM-dd") -> String {
        guard self.length > 0 else { return "" }
        let date = NSDate(fromString: self, format: oFormat)
        let fmt = NSDateFormatter()
        fmt.dateFormat = toFormat
        return fmt.stringFromDate(date!)
    }

//    ///  字符串 -> N为小数
//    ///
//    ///  :param: digit N
//    ///
//    ///  :returns: 指定格式的字符串
//    func formatFloatString(digit: UInt = 2) -> String {
//        let fmt = "%.\(digit)f"
//        return String(format: fmt, self.toDouble() ?? 0)
//    }
    
    ///  字符串 -> N为小数
    ///
    ///  :param: digit   N
    ///  :param: percent 标识是否显示成百分比字符串
    ///
    ///  :returns: 指定格式的字符串
    func formatFloatString(digit: UInt = 2, percent: Bool = false) -> String {
        var fmt = "%.\(digit)f"
        if percent {
            fmt = "%.\(digit)f%%"
        }
        return String(format: fmt, self.toDouble() ?? 0)
    }
}