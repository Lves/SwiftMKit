//
//  NSData+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 09/11/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit


extension Data {
    
    var hexString: String? {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
