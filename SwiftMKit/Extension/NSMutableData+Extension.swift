//
//  NSMutableData+Extension.swift
//  JimuDudu
//
//  Created by jimubox on 16/9/5.
//  Copyright © 2016年 pintec. All rights reserved.
//

import UIKit

extension NSMutableData {
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
