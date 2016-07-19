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
}