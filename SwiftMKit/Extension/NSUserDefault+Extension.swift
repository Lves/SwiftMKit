//
//  NSUserDefault+Extension.swift
//  Jimubox
//
//  Created by Mao on 9/6/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import UIKit

extension NSUserDefaults {
    /**
     删除所有NSUserDefault记录
     */
    class func resetDefaults() {
        let defs = NSUserDefaults.standardUserDefaults()
        let dict = defs.dictionaryRepresentation()
        for (key, _) in dict {
            defs.removeObjectForKey(key)
        }
        defs.synchronize()
    }

}
