//
//  NSMutableData+Extension.swift
//  JimuDudu
//
//  Created by jimubox on 16/9/5.
//  Copyright © 2016年 pintec. All rights reserved.
//

import UIKit

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
