//
//  LinkTextModel.swift
//  SwiftMKitDemo
//
//  Created by lixingle on 2018/2/7.
//  Copyright © 2018年 cdts. All rights reserved.
//

import UIKit

public class LinkTextModel: NSObject {
    public var url:String?
    public var range:NSRange = NSRange(location: 0, length: 0)
    public var font:UIFont?
    public var textColor:UIColor?
    public var highlightedBgColor:UIColor?
    public var showUnderline:Bool = false
    public override init() {
        super.init()
    }
    public init(range:NSRange, textColor:UIColor? = nil, url:String?, font:UIFont? = nil, highlightedBgColor:UIColor? = nil, showUnderline:Bool = false) {
        super.init()
        self.range = range
        self.textColor = textColor
        self.url = url
        self.font = font
        self.highlightedBgColor = highlightedBgColor
        self.showUnderline = showUnderline
    }
}
