//
//  NSMutableData+Extension.swift
//
//  Created by cdts on 16/9/5.
//  Copyright © 2016年 All rights reserved.
//

import UIKit

extension NSMutableData {
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
