//
//  NSUserDefault+Extension.swift
//  Jimubox
//
//  Created by Mao on 9/6/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import UIKit

extension UserDefaults {
    /**
     删除所有NSUserDefault记录
     */
    class func resetDefaults() {
        let defs = UserDefaults.standard
        let dict = defs.dictionaryRepresentation()
        for (key, _) in dict {
            defs.removeObject(forKey: key)
        }
        defs.synchronize()
    }

}
