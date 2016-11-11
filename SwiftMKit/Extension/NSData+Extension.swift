//
//  NSData+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 09/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit


extension NSData {
    
    var hexString: String? {
        let buf = UnsafePointer<UInt8>(bytes)
        let charA = UInt8(UnicodeScalar("a").value)
        let char0 = UInt8(UnicodeScalar("0").value)
        
        func itoh(value: UInt8) -> UInt8 {
            return (value > 9) ? (charA + value - 10) : (char0 + value)
        }
        
        let ptr = UnsafeMutablePointer<UInt8>.alloc(length * 2)
        
        for i in 0 ..< length {
            ptr[i*2] = itoh((buf[i] >> 4) & 0xF)
            ptr[i*2+1] = itoh(buf[i] & 0xF)
        }
        
        return String(bytesNoCopy: ptr, length: length*2, encoding: NSUTF8StringEncoding, freeWhenDone: true)
    }
}
