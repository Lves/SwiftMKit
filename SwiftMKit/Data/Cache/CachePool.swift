//
//  CachePool.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/26/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public struct CachePoolConstant {
    static let DefaultCapacity: Double = 100*1024*1024 // 默认缓存池控件 100M
}

private class CacheModel : NSObject {
    var createTime: NSTimeInterval = 0
    var lastVisitTime: NSTimeInterval = 0
    var expireTime: NSTimeInterval = 0
    var size: Double = 0
    var name: String = ""
}

public class CachePool: NSObject {
    public var basePath: String
    public var capacity: Double = CachePoolConstant.DefaultCapacity
    
    init(basePath: String) {
        self.basePath = basePath
        super.init()
    }
    
    public func addObject(name: String, data: NSObject) {}
    public func objectForName(name: String) -> NSObject? {
        return nil
    }
    public func preparePoolForSize(size: Double) {
    }
}