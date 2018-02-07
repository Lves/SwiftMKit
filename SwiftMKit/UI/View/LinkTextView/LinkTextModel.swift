//
//  LinkTextModel.swift
//  SwiftMKitDemo
//
//  Created by lixingle on 2018/2/7.
//  Copyright © 2018年 cdts. All rights reserved.
//

import UIKit

class LinkTextModel: NSObject {
    var url:String?
    var range:NSRange = NSRange(location: 0, length: 0)
    var font:UIFont?
    var textColor:UIColor?
    var highlightedBgColor:UIColor?
    var showUnderline:Bool = false
    override init() {
        super.init()
    }
    init(range:NSRange, textColor:UIColor? = nil, url:String?, font:UIFont? = nil, highlightedBgColor:UIColor? = nil, showUnderline:Bool = false) {
        super.init()
        self.range = range
        self.textColor = textColor
        self.url = url
        self.font = font
        self.highlightedBgColor = highlightedBgColor
        self.showUnderline = showUnderline
    }
}
