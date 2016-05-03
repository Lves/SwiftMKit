//
//  CachePool.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/26/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import PINCache

public struct CachePoolConstant {
    // 取手机剩余空间 DefaultCapacity = MIN(剩余空间, 100M)DefaultCapacity = MIN(剩余空间, 100M)
    static let DefaultCapacity: Double = min(100*1024*1024, CachePool.freeDiskspace()) // 默认缓存池空间 100M
    static let baseCachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first! + "/"
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
    public var namespace: String = "CachePool"
    public var capacity: Double = CachePoolConstant.DefaultCapacity {
        didSet {
            capacity = min(oldValue, CachePool.freeDiskspace())
        }
    }
    
    override init() {
        super.init()
        self.createFolder(namespace, baseUrl: NSURL(fileURLWithPath: CachePoolConstant.baseCachePath, isDirectory: true))
    }
    
    init(namespace: String?) {
        super.init()
        self.namespace = namespace ?? self.namespace
        self.createFolder(self.namespace, baseUrl: NSURL(fileURLWithPath: CachePoolConstant.baseCachePath, isDirectory: true))
    }
    
    
    ///  缓存对象
    ///
    ///  :param: name 键【 MD5(name+time) 】
    ///  :param: data 值
    public func addObject(name: String, data: AnyObject) {
        // 核心方法：判断是否有足够的空间存储
        self.preparePoolForSize(0)
        // 保存属性字典
        cacheDict = [
            CacheDictKey.Name : name,
            CacheDictKey.CreateTime : NSDate()
        ]
        print("\(cacheDict!)")
        // 保存对象到沙河
        let dir = CachePoolConstant.baseCachePath + namespace + "/"
        let filePath:String = dir + name
        let encodedObj = NSKeyedArchiver.archivedDataWithRootObject(data)
        if encodedObj.writeToFile(filePath, atomically: true) {
            print("文件写入成功：\(filePath)")
            let attrs = self.getFileAttributes(filePath)
            print("attrs = \(attrs)")
        } else {
            print("文件写入失败！")
        }
    }
    
    ///  取缓存对象
    ///
    ///  :param: name 键
    ///
    ///  :returns: 值
    public func objectForName(name: String) -> AnyObject? {
        let dir = CachePoolConstant.baseCachePath + namespace + "/"
        let filePath:String = dir + name
        let manager = NSFileManager.defaultManager()
        let data = manager.contentsAtPath(filePath)
        return NSKeyedUnarchiver.unarchiveObjectWithData(data!)
    }
    
    ///  清空磁盘缓存
    public func clearDisk() {
        let fileManager = NSFileManager.defaultManager()
        
        let dir = CachePoolConstant.baseCachePath + namespace
        try! fileManager.removeItemAtPath(dir)
        try! fileManager.createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil)
    }
    
    // 缓存相关
    var cache = PINCache.sharedCache()
    let cacheDictKey = "CacheDict"
    var cacheDict: Dictionary<String, AnyObject>? {
        get {
            return cache.objectForKey(cacheDictKey) as? Dictionary<String, AnyObject>
        }
        set {
            if let value = newValue {
                cache.setObject(value, forKey: cacheDictKey)
            }else {
                cache.removeObjectForKey(cacheDictKey)
            }
        }
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
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
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
    
    ///  创建文件夹
    private func createFolder(name: String,baseUrl: NSURL){
        let manager = NSFileManager.defaultManager()
        let folder = baseUrl.URLByAppendingPathComponent(name, isDirectory: true)
        print("文件夹: \(folder)")
        let exist = manager.fileExistsAtPath(folder.path!)
        if !exist {
            try! manager.createDirectoryAtURL(folder, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    ///  获取文件属性
    ///
    ///  :param: filePath 文件路径
    private func getFileAttributes(filePath: String) -> [String: AnyObject]? {
        let manager = NSFileManager.defaultManager()
        let attributes = try? manager.attributesOfItemAtPath(filePath)
        return attributes
    }

}