//
//  UIFont+Extension.swift
//
//  Created by Mao on 9/6/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

extension UIFont {
    
    /**
     打印系统所有已注册的字体名称
     
     - returns: 系统所有已注册的字体名称
     */
    class func allFontNames() -> [String] {
        var fontNames = [String]()
        for familyName in UIFont.familyNames {
            let names = UIFont.fontNames(forFamilyName: familyName)
            for name in names {
                fontNames.append(name)
            }
        }
        return fontNames
    }
}
