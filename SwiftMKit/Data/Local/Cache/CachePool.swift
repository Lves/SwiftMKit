//
//  CachePool.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/26/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import PINCache
import CocoaLumberjack

public struct CachePoolConstant {
    // 取手机剩余空间 DefaultCapacity = MIN(剩余空间, 100M)
    static let DefaultCapacity: Int64 = 100*1024*1024 // 默认缓存池空间 100M
    static let DefaultCachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/"
    static let MimeType4Image = "image"
}

private class CacheModel : NSObject, NSCoding, CacheModelProtocol {
    var key: String = ""
    var name: String = ""
    var filePath: URL?
    var size: Int64 = 0
    var mimeType: String = ""
    var createTime: TimeInterval = 0
    var lastVisitTime: TimeInterval = 0
    var expireTime: TimeInterval = 0
    
    @objc func encode(with aCoder: NSCoder){
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.key, forKey: "key")
        aCoder.encode(self.filePath, forKey: "filePath")
        aCoder.encode(self.createTime, forKey: "createTime")
        aCoder.encode(self.size, forKey: "size")
        aCoder.encode(self.mimeType, forKey: "mimeType")
    }
    
    @objc required init(coder aDecoder: NSCoder) {
        super.init()
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.key = aDecoder.decodeObject(forKey: "key") as! String
        self.filePath = aDecoder.decodeObject(forKey: "filePath") as? URL
        self.createTime = aDecoder.decodeObject(forKey: "createTime") as! TimeInterval
        self.size = aDecoder.decodeInt64(forKey: "size")
        self.mimeType = aDecoder.decodeObject(forKey: "mimeType") as! String
    }
    
    override init() {
        super.init()
    }
    
    override var description: String {
        return "\(key)  \(name)  \(createTime)  \(size)"
    }
}

/// 缓存池：用于存储文件
open class CachePool: CachePoolProtocol {
    let fileManager = FileManager.default
    var cache: PINCache?
    open var namespace: String = "CachePool"
    open var capacity: Int64 = CachePoolConstant.DefaultCapacity
    open var size: Int64 {
        // 遍历配置文件
        // 取出缓存字典
        let cachedDict = (cache!.object(forKey: cacheDictKey) as? [String: CacheModel]) ?? [:]
        var cachedSize: Int64 = 0
        for value in cachedDict.values {
            cachedSize += value.size
        }
        return cachedSize
    }
    open var basePath: URL?
    
    init() {
        cache = PINCache(name: "Config", rootPath: cachePath())
        createFolder(forName: namespace, baseUrl: baseCacheUrl())
    }
    
    init(namespace: String?) {
        self.namespace = namespace ?? self.namespace
        cache = PINCache(name: "Config", rootPath: cachePath())
        createFolder(forName: self.namespace, baseUrl: baseCacheUrl())
    }
    
    open func addCache(_ data: Data, name: String?) -> String {
        return addCache(data, name: name, mimeType: nil)
    }
    
    open func addCache(_ image: UIImage, name: String?) -> String {
        let data = UIImagePNGRepresentation(image)
        return self.addCache(data!, name: name, mimeType: CachePoolConstant.MimeType4Image)
    }
    
    open func addCache(_ filePath: URL, name: String?) -> String {
        // 拷贝文件
        // 生成目标路径
        let timestamp = Date().timeIntervalSince1970
        let nameTime = ( name ?? "" ) + "\(timestamp)"
        let encryptName = nameTime.md5
        let dir = self.cachePath()
        let destFilePath:String = dir + encryptName
        try! fileManager.copyItem(atPath: filePath.path, toPath: destFilePath)
        DDLogInfo("filePath: \(filePath.path)")
        DDLogInfo("destFilePath: \(destFilePath)")
        // 获取文件信息
        if let attrs = self.getFileAttributes(withFilePath: destFilePath) {
            DDLogInfo("file info:\(attrs)")
            // 更新配置文件
            let num = attrs[FileAttributeKey.size] as? NSNumber ?? 0
            let size = num.int64Value
            return self.updateConfig(forName: name, timestamp:timestamp, size: size)
        }
        // TODO: 返回值需要思考一下
        return encryptName
    }
    
    open func getCache(forKey key: String) -> AnyObject? {
        let dir = self.cachePath()
        let filePath:String = dir + key
        DDLogInfo("objectForName filePath：" + filePath)
        let cachedDict = (cache!.object(forKey: cacheDictKey) as? [String: CacheModel]) ?? [:]
        if let obj = cachedDict[key] {
            if obj.mimeType == CachePoolConstant.MimeType4Image {
                if let data = fileManager.contents(atPath: filePath) {
                    return UIImage(data: data)
                } else {
                    return nil
                }
            }
            return fileManager.contents(atPath: filePath) as AnyObject?
        }
        return fileManager.contents(atPath: filePath) as AnyObject?
    }
    
    open func all() -> [CacheModelProtocol]? {
        let cachedDict = (cache!.object(forKey: cacheDictKey) as? [String: CacheModel]) ?? [:]
        var cacheModelList:[CacheModelProtocol] = []
        for obj in cachedDict.values {
            cacheModelList.append(obj)
        }
        return cacheModelList
    }
    
    open func removeCache(forKey key: String) -> Bool {
        var cachedDict = (cache!.object(forKey: cacheDictKey) as? [String: CacheModel]) ?? [:]
        if let obj = cachedDict[key] {
            print(obj)
            // 从沙河中删除
            let filePathStr = cachePath() + obj.key
            if fileManager.fileExists(atPath: filePathStr) {
                try! fileManager.removeItem(atPath: filePathStr)
            }
            // 从配置文件中删除
            cachedDict.removeValue(forKey: key)
            cacheDict = cachedDict
            return true
        }
        return false
    }
    
    open func clear() -> Bool {
        let cachepath = cachePath()
        if fileManager.fileExists(atPath: cachepath) {
            let fileArray:[AnyObject]? = fileManager.subpaths(atPath: cachepath) as [AnyObject]?
            for fn in fileArray!{
                let subpath = cachepath + "/\(fn)";
                var flag: ObjCBool = false
                if fileManager.fileExists(atPath: subpath, isDirectory: &flag) {
                    if flag.boolValue {
                        // 是文件夹
                        continue
                    } else {
                        try! fileManager.removeItem(atPath: subpath)
                    }
                }
//                if fileManager.fileExistsAtPath(subpath) {
//                    try! fileManager.removeItemAtPath(subpath)
//                }
            }
//            try! fileManager.removeItemAtPath(cachepath)
//            try! fileManager.createDirectoryAtPath(cachepath, withIntermediateDirectories: true, attributes: nil)
            // 清空缓存配置文件
            cacheDict?.removeAll()
            // 重新生成配置文件
            cache = PINCache(name: "Config", rootPath: cachePath())
            createFolder(forName: namespace, baseUrl: baseCacheUrl())
            return true
        }
        return size == 0
    }
    
    // 缓存相关
    let cacheDictKey = "CacheModels"
    fileprivate var cacheDict: Dictionary<String, CacheModel>? {
        get {
            return cache!.object(forKey: cacheDictKey) as? Dictionary<String, CacheModel>
        }
        set {
            if let value = newValue {
                cache!.setObject(value as NSCoding, forKey: cacheDictKey)
            } else {
                cache!.removeObject(forKey: cacheDictKey)
            }
        }
    }
}

extension CachePool {
    fileprivate func addCache(_ data: Data, name: String?, mimeType: String?) -> String {
        // 更新配置文件
        let timestamp = Date().timeIntervalSince1970
        let encryptName = self.updateConfig(forName: name, timestamp:timestamp, size: Int64(data.count), mimeType: mimeType)
        // 保存对象到沙盒
        let dir = self.cachePath()
        let filePath:String = dir + encryptName
        let _ = Async.background {
            if (try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])) != nil {
                DDLogDebug("文件写入成功：\(filePath)")
            } else {
                DDLogDebug("文件写入失败！")
            }
        }
        return encryptName
    }
    
    ///  存储文件之前，判断是否有足够的空间存储
    ///
    ///  :param: size 即将存储的文件大小
    fileprivate func preparePool(forSize size: Int64) -> Bool {
        // 比较 设备剩余可用空间 & 文件大小
        var leftCapacity = capacity - self.size
        leftCapacity = min(UIDevice.freeDiskSpaceInBytes, leftCapacity)  // 取出最小可用空间
        DDLogVerbose("可用空间：\(leftCapacity), 文件大小：\(size), 正常保存")
        if leftCapacity < size {
            // 读取配置文件，删除已过期、即将过期、最近未访问的文件，直至可以保存为止
            DDLogInfo("需要删除文件后保存")
            leftCapacity = self.cleanDisk(leftCapacity: leftCapacity, size: size)
        }
        return size <= leftCapacity
    }
    
    ///  更新配置文件
    ///
    ///  :param: name 文件名
    ///  :param: size 文件大小
    ///
    ///  :returns: 加密后的文件名
    fileprivate func updateConfig(forName name: String?, timestamp: TimeInterval, size: Int64) -> String {
        return updateConfig(forName: name, timestamp: timestamp, size: size, mimeType: nil)
    }
    
    fileprivate func updateConfig(forName name: String?, timestamp: TimeInterval, size: Int64, mimeType: String?) -> String {
        // 核心方法：判断是否有足够的空间存储
        if !(self.preparePool(forSize: size)) {
            return ""
        }
        let cacheObj = CacheModel()
        // 已缓存的字典
        var cachedDict = (cache!.object(forKey: cacheDictKey) as? [String: CacheModel]) ?? [:]
        let nameTime = (name ?? "") + "\(timestamp)"
        let encryptName = nameTime.md5 
        cacheObj.name = name ?? ""
        cacheObj.key = encryptName
        cacheObj.createTime = timestamp
        cacheObj.mimeType = (mimeType ?? "")
        cacheObj.size = size
        cacheObj.filePath = URL(fileURLWithPath: (cachePath() + encryptName))
        cachedDict[encryptName] = cacheObj
        // 同步到PINCache
        cacheDict = cachedDict
        return encryptName
    }
    
    ///  创建文件夹
    fileprivate func createFolder(forName name: String, baseUrl: URL) {
        let folder = baseUrl.appendingPathComponent(name, isDirectory: true)
        let exist = fileManager.fileExists(atPath: folder.path)
        if !exist {
            try! fileManager.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            DDLogVerbose("缓存文件夹：" + folder.path)
        }
    }
    
    ///  获取文件属性
    ///
    ///  :param: filePath 文件路径
    fileprivate func getFileAttributes(withFilePath filePath: String) -> [FileAttributeKey: Any]? {
        let attributes = try? fileManager.attributesOfItem(atPath: filePath)
        return attributes
    }
    
    fileprivate func cachePath() -> String {
        let baseStr = ((basePath) != nil) ? basePath!.path : CachePoolConstant.DefaultCachePath
        return baseStr + "/" + namespace + "/"
    }
    
    fileprivate func baseCacheUrl() -> URL {
        let baseUrl = ((basePath) != nil) ? basePath! : URL(fileURLWithPath: CachePoolConstant.DefaultCachePath)
        self.basePath = baseUrl
        return baseUrl
    }
    
    ///  设备剩余空间不足时，删除本地缓存文件
    ///
    ///  :param: leftCapacity 剩余空间
    ///  :param: size     至少需要的空间
    fileprivate func cleanDisk(leftCapacity lastSize: Int64, size: Int64) -> Int64 {
        var leftCapacity = lastSize
        // 遍历配置文件
        // 取出缓存字典
        var cachedDict = (cache!.object(forKey: cacheDictKey) as? [String: CacheModel]) ?? [:]
        DDLogVerbose("排序前：\(cachedDict)")
        // 升序，最新的数据在最下面(目的：删除日期最小的旧数据)
        let sortedList = cachedDict.sorted { $0.1.createTime < $1.1.createTime }
        DDLogVerbose("=========================================================")
        DDLogVerbose("排序后：\(sortedList)")
        
        // obj 是一个元组类型
        for (key, model) in sortedList {
            // 从沙河中删除
            let filePathStr = cachePath() + key
            if fileManager.fileExists(atPath: filePathStr) {
                try! fileManager.removeItem(atPath: filePathStr)
            }
            // 从配置文件中删除
            cachedDict.removeValue(forKey: key)
            cacheDict = cachedDict
            // 更新剩余空间大小
            leftCapacity += model.size
            DDLogVerbose("remove=\(key), save=\(model.size) byte  lastSize=\(leftCapacity)  size=\(size)")
            if leftCapacity > size {
                break
            }
        }
        return leftCapacity
    }
}
