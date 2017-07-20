//
//  String+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import CocoaLumberjack

extension String {
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        var str:String?
        if #available(iOS 9, *){
            str = self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
        }else {
            str = self
        }
        return str
    }
    
    func withoutSeparator() -> String {
        return self.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined(separator: "")
    }
    /// 解码Url
    var decodeUrl: String {
        return self.removingPercentEncoding!
    }
    /// 编码Url
    var encodeUrl: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    // MARK: Format
    func formatCurrency(locale: String = "en_US") -> String {
        return NSString(string: self).doubleValue.formatCurrency(locale: locale)
    }
    func formatCurrencyWithoutDot(locale: String = "en_US") -> String {
        return NSString(string: self).doubleValue.formatCurrencyWithoutDot(locale: locale)
    }
    
    func jsonStringToDictionary() -> [String: AnyObject]? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                DDLogError(error.description)
            }
        }
        return nil
    }
    
    func formatMask(_ range : NSRange) -> String {
        
        var mask: String = ""
        
        for _ in 0..<range.length {
            mask += "*"
        }
        let result: NSMutableString = NSMutableString(string: self)
        if self.length >= range.location + range.length {
            result.replaceCharacters(in: range, with: mask)
            return result as String
        } else if self.length >= range.location {
            return result.substring(to: range.location) + mask
        } else {
            return mask
        }
    }
    
    func urlEncode() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
    }
    
    // MARK: Encrypt
    
    var md5: String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestLen)
        
        let encryptString = String(format: hash as String)
        
        DDLogVerbose("Encrypt before：\(self)")
        DDLogVerbose("Encrypt after：\(encryptString)")
        return encryptString
    }
    
    func fromBase64() -> String {
        let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0))
        return String(data: data!, encoding: String.Encoding.utf8)!
    }
    
    func toBase64() -> String {
        let data = self.data(using: String.Encoding.utf8)
        return data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
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
        return String(self.characters.reversed())
    }
    
    ///  加密手机号（186****6789）
    func encryPhoneNo() -> String {
        if self.length == 11 {
            let startIndex = self.characters.index(self.startIndex, offsetBy: 3)
            let endIndex = self.characters.index(startIndex, offsetBy: 4)
            let range = (startIndex ..< endIndex)
            let newPhone = self.replacingCharacters(in: range, with: "****")
            return newPhone
        } else {
            return self
        }
    }
    func formatToDateString(withFormat format: String = "yyyy-MM-dd") -> String {
        guard self.length > 0 else { return "" }
        let timestamp = self.toDouble() ?? 0
        let date = Date(timeIntervalSince1970: timestamp)
        let fmt = DateFormatter()
        fmt.dateFormat = format
        return fmt.string(from: date)
    }
    func formatTimestampToDateString(withFormat format: String = "yyyy-MM-dd") -> String {
        guard self.length > 0 else { return "" }
        let tmp = self.toDouble() ?? 0
        // NSTimeInterval
        let timestamp = self.length >= 13 ? tmp / 1000.0 : tmp
        let date = Date(timeIntervalSince1970: timestamp)
        let fmt = DateFormatter()
        fmt.dateFormat = format
        return fmt.string(from: date)
    }
    func formatDateStringToOtherFormat(orignFormat oFormat:String = "yyyyMMdd", targetFormat toFormat:String = "yyyy-MM-dd") -> String {
        guard self.length > 0 else { return "" }
        let date = Date(fromString: self, format: oFormat)
        let fmt = DateFormatter()
        fmt.dateFormat = toFormat
        return  date == nil ? self : fmt.string(from: date!)
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
    
    
    static func getAttributedStringHeight(matchWidth width:CGFloat, attributedString:NSAttributedString?) -> CGFloat {
        let options: NSStringDrawingOptions = [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading]

        let size = attributedString?.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                                                   options: options,
                                                   context: nil)
        return size?.height ?? 0
    }

    func getAttributedString(withFont font: UIFont, lineSpacing: CGFloat, alignment: NSTextAlignment? = .left) -> NSMutableAttributedString {
        guard self.length > 0 else { return NSMutableAttributedString() }
        let attributedString = NSMutableAttributedString(string: self,
                                                         attributes: [NSFontAttributeName:font])
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.alignment = alignment ?? .left
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }

    
    /**
     *  获取字符串的宽度和高度
     *
     *  @param text:NSString
     *  @param font:UIFont
     *
     *  @return CGRect
     */
    func getTextRectSize(text:NSString,font:UIFont,size:CGSize) -> CGRect {
        let attributes = [NSFontAttributeName: font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect:CGRect = text.boundingRect(with: size, options: option, attributes: attributes, context: nil)
        return rect;
    }
    /*
     *  url字符串拼接参数
     */
    func urlStringAddParams(params: [String:Any]?) -> String {
        guard let params = params ,params.count > 0 else {
            return self
        }
        //获得参数字符串
        var paramsStr:String = ""
        for (index ,key) in params.keys.enumerated() {
            if let value = params[key] {
                if type(of: value) is AnyClass {
                    continue
                }
                if index == (params.count-1) {
                    paramsStr +=  "\(key)=\(value)"
                }else {
                    paramsStr +=  "\(key)=\(value)&"
                }
            }
        }
        //拼接到url
        var resultUrl = self
        if paramsStr.length > 0 {
            if self.contains("?"){ //url上已有参数
                resultUrl += ("&"+paramsStr)
            }else{
                resultUrl += ("?"+paramsStr)
            }
        }
        return resultUrl.encodeUrl
    }
}
