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
    override init() {
        super.init()
    }
    init(range:NSRange, textColor:UIColor? = nil, url:String?, font:UIFont? = nil, highlightedBgColor:UIColor? = nil) {
        super.init()
        self.range = range
        self.textColor = textColor
        self.url = url
        self.font = font
        self.highlightedBgColor = highlightedBgColor
    }
}
