//
//  CachePool.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/26/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public struct CachePoolConstant {
    // 取手机剩余空间 DefaultCapacity = MIN(剩余空间, 100M)DefaultCapacity = MIN(剩余空间, 100M)
    static let DefaultCapacity: Double = min(100*1024*1024, CachePool.freeDiskspace()) // 默认缓存池空间 100M
}

private class CacheModel : NSObject {
    var createTime: NSTimeInterval = 0
    var lastVisitTime: NSTimeInterval = 0
    var expireTime: NSTimeInterval = 0
    var size: Double = 0
    var name: String = ""
    var mimeType : String = ""
}

private struct CacheDictKey {
    static let CreateTime = "createTime"
    static let LastVisitTime = "lastVisitTime"
    static let ExpireTime = "expireTime"
    static let Size = "size"
    static let Name = "name"
    static let MimeType = "mimeType"
}


/// 缓存池：用于存储文件
public class CachePool: NSObject {
    public var basePath: String
    public var capacity: Double = CachePoolConstant.DefaultCapacity {
        didSet {
            capacity = min(oldValue, CachePool.freeDiskspace())
        }
    }
    
    init(basePath: String) {
        self.basePath = basePath
        super.init()
    }
    
    public func addObject(name: String, data: NSObject) {}
    public func objectForName(name: String) -> NSObject? {
        return nil
    }
    public func clearDisk() {
        
    }
}

extension CachePool {
    ///  存储文件之前，判断是否有足够的空间存储
    ///
    ///  :param: size 即将存储的文件大小
    private func preparePoolForSize(size: Double) {
        
    }
    
    /// 获取设备剩余可用空间
    public class func freeDiskspace() -> Double {
        var totalSpace = 0.0
        var totalFreeSpace = 0.0
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var dict:[String: AnyObject]?
        do {
            dict = try NSFileManager.defaultManager().attributesOfFileSystemForPath(paths.last!)
        } catch {
            print("error")
        }
        let fileSystemSizeInBytes = dict![NSFileSystemSize]
        let freeFileSystemSizeInBytes = dict![NSFileSystemFreeSize]
        totalSpace = fileSystemSizeInBytes!.doubleValue
        totalFreeSpace = freeFileSystemSizeInBytes!.doubleValue
        print("总空间：\(totalSpace/1024/1024/1024)GB <====>  可用空间：\(totalFreeSpace/1024/1024/1024)GB")
        return totalFreeSpace
    }
    
    ///  获取文件基本信息
    private func fileInfo() -> String? {
        return nil
    }
}