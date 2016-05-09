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

//
//                            _ooOoo_
//                           o8888888o
//                           88" . "88
//                           (| -_- |)
//                            O\ = /O
//                        ____/`---'\____
//                      .   ' \\| |// `.
//                       / \\||| : |||// \
//                     / _||||| -:- |||||- \
//                       | | \\\ - /// | |
//                     | \_| ''\---/'' | |
//                      \ .-\__ `-` ___/-. /
//                   ___`. .' /--.--\ `. . __
//                ."" '< `.___\_<|>_/___.' >'"".
//               | | : `- \`.;`\ _ /`;.`/ - ` : | |
//                 \ \ `-. \_ __\ /__ _/ .-` / /
//         ======`-.____`-.___\_____/___.-`____.-'======
//                            `=---='
//
//         .............................................
//                  佛祖保佑             永无BUG
//          佛曰:
//                  写字楼里写字间，写字间里程序员；
//                  程序人员写程序，又拿程序换酒钱。
//                  酒醒只在网上坐，酒醉还来网下眠；
//                  酒醉酒醒日复日，网上网下年复年。
//                  但愿老死电脑间，不愿鞠躬老板前；
//                  奔驰宝马贵者趣，公交自行程序员。
//                  别人笑我忒疯癫，我笑别人看不穿；
//                  不见满街漂亮妹，哪个归得程序员？

public struct CachePoolConstant {
    // 取手机剩余空间 DefaultCapacity = MIN(剩余空间, 100M)
    static let DefaultCapacity: Int64 = 100*1024*1024 // 默认缓存池空间 100M
    static let DefaultCachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first! + "/"
    static let MimeType4Image = "image"
}

private class CacheModel : NSObject, NSCoding, CacheModelProtocol {
    var key: String = ""
    var name: String = ""
    var filePath: NSURL = NSURL()
    var size: Int64 = 0
    var mimeType: String = ""
    var createTime: NSTimeInterval = 0
    var lastVisitTime: NSTimeInterval = 0
    var expireTime: NSTimeInterval = 0
    
    @objc func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.key, forKey: "key")
        aCoder.encodeObject(self.filePath, forKey: "filePath")
        aCoder.encodeObject(self.createTime, forKey: "createTime")
        aCoder.encodeInt64(self.size, forKey: "size")
        aCoder.encodeObject(self.mimeType, forKey: "mimeType")
    }
    
    @objc required init(coder aDecoder: NSCoder) {
        super.init()
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.key = aDecoder.decodeObjectForKey("key") as! String
        self.filePath = aDecoder.decodeObjectForKey("filePath") as! NSURL
        self.createTime = aDecoder.decodeObjectForKey("createTime") as! NSTimeInterval
        self.size = aDecoder.decodeInt64ForKey("size")
        self.mimeType = aDecoder.decodeObjectForKey("mimeType") as! String
    }
    
    override init() {
        super.init()
    }
    
    override var description: String {
        return "\(key)  \(name)  \(createTime)  \(size)"
    }
}

/// 缓存池：用于存储文件
public class CachePool: CachePoolProtocol {
    let fileManager = NSFileManager.defaultManager()
    var cache: PINCache?
    public var namespace: String = "CachePool"
    public var capacity: Int64 = CachePoolConstant.DefaultCapacity
    public var size: Int64 {
        // 遍历配置文件
        // 取出缓存字典
        let cachedDict = (cache!.objectForKey(cacheDictKey) as? [String: CacheModel]) ?? [:]
        var cachedSize: Int64 = 0
        for value in cachedDict.values {
            cachedSize += value.size
        }
        return cachedSize
    }
    public var basePath: NSURL?
    
    init() {
        cache = PINCache(name: "Config", rootPath: cachePath())
        createFolder(namespace, baseUrl: baseCacheUrl())
    }
    
    init(namespace: String?) {
        self.namespace = namespace ?? self.namespace
        cache = PINCache(name: "Config", rootPath: cachePath())
        createFolder(self.namespace, baseUrl: baseCacheUrl())
    }
    
    public func addCache(data: NSData, name: String?) -> String {
        return addCache(data, name: name, mimeType: nil)
    }
    
    public func addCache(image: UIImage, name: String?) -> String {
        let data = UIImagePNGRepresentation(image)
        return self.addCache(data!, name: name, mimeType: CachePoolConstant.MimeType4Image)
    }
    
    public func addCache(filePath: NSURL, name: String?) -> String {
        // 拷贝文件
        // 生成目标路径
        let timestamp = NSDate().timeIntervalSince1970
        let nameTime = ( name ?? "" ) + "\(timestamp)"
        let encryptName = nameTime.md5
        let dir = self.cachePath()
        let destFilePath:String = dir + encryptName
        try! fileManager.copyItemAtPath(filePath.path!, toPath: destFilePath)
        DDLogInfo("filePath: \(filePath)")
        DDLogInfo("destFilePath: \(destFilePath)")
        // 获取文件信息
        if let attrs = self.getFileAttributes(destFilePath) {
            DDLogInfo("file info:\(attrs)")
            // 更新配置文件
            let size: Int64 = attrs[NSFileSize] as? Int64 ?? 0
            return self.updateConfig(name, timestamp:timestamp, size: size)
        }
        // TODO: 返回值需要思考一下
        return encryptName
    }
    
    public func getCache(key: String) -> AnyObject? {
        let dir = self.cachePath()
        let filePath:String = dir + key
        DDLogInfo("objectForName filePath：" + filePath)
        let cachedDict = (cache!.objectForKey(cacheDictKey) as? [String: CacheModel]) ?? [:]
        if let obj = cachedDict[key] {
            if obj.mimeType == CachePoolConstant.MimeType4Image {
                return UIImage(data: fileManager.contentsAtPath(filePath)!)
            }
        }
        return fileManager.contentsAtPath(filePath)
    }
    
    public func all() -> [CacheModelProtocol]? {
        let cachedDict = (cache!.objectForKey(cacheDictKey) as? [String: CacheModel]) ?? [:]
        var cacheModelList:[CacheModelProtocol] = []
        for obj in cachedDict.values {
            cacheModelList.append(obj)
        }
        return cacheModelList
    }
    
    public func removeCache(key: String) -> Bool {
        var cachedDict = (cache!.objectForKey(cacheDictKey) as? [String: CacheModel]) ?? [:]
        if let obj = cachedDict[key] {
            print(obj)
            // 从沙河中删除
            let filePathStr = cachePath() + obj.key
            if fileManager.fileExistsAtPath(filePathStr) {
                try! fileManager.removeItemAtPath(filePathStr)
            }
            // 从配置文件中删除
            cachedDict.removeValueForKey(key)
            cacheDict = cachedDict
            return true
        }
        return false
    }
    
    public func clear() -> Bool {
        let cachepath = cachePath()
        if fileManager.fileExistsAtPath(cachepath) {
            let fileArray:[AnyObject]? = fileManager.subpathsAtPath(cachepath)
            for fn in fileArray!{
                let subpath = cachepath + "/\(fn)";
                if fileManager.fileExistsAtPath(subpath) {
                    try! fileManager.removeItemAtPath(subpath)
                }
            }
//            try! fileManager.removeItemAtPath(cachepath)
//            try! fileManager.createDirectoryAtPath(cachepath, withIntermediateDirectories: true, attributes: nil)
            // 清空缓存配置文件
            cacheDict?.removeAll()
            // 重新生成配置文件
            cache = PINCache(name: "Config", rootPath: cachePath())
            createFolder(namespace, baseUrl: baseCacheUrl())
            return true
        }
        return size == 0
    }
    
    // 缓存相关
    let cacheDictKey = "CacheModels"
    private var cacheDict: Dictionary<String, CacheModel>? {
        get {
            return cache!.objectForKey(cacheDictKey) as? Dictionary<String, CacheModel>
        }
        set {
            if let value = newValue {
                cache!.setObject(value, forKey: cacheDictKey)
            } else {
                cache!.removeObjectForKey(cacheDictKey)
            }
        }
    }
}

extension CachePool {
    private func addCache(data: NSData, name: String?, mimeType: String?) -> String {
        // 更新配置文件
        let timestamp = NSDate().timeIntervalSince1970
        let encryptName = self.updateConfig(name, timestamp:timestamp, size: Int64(data.length), mimeType: mimeType)
        // 保存对象到沙盒
        let dir = self.cachePath()
        let filePath:String = dir + encryptName
        Async.background {
            if data.writeToFile(filePath, atomically: true) {
                print("文件写入成功：\(filePath)")
            } else {
                print("文件写入失败！")
            }
        }
        return encryptName
    }
    
    ///  存储文件之前，判断是否有足够的空间存储
    ///
    ///  :param: size 即将存储的文件大小
    private func preparePoolForSize(size: Int64) -> Bool {
        // 比较 设备剩余可用空间 & 文件大小
        var leftCapacity = capacity - self.size
        leftCapacity = min(UIDevice.freeDiskSpaceInBytes, leftCapacity)  // 取出最小可用空间
        DDLogVerbose("可用空间：\(leftCapacity), 文件大小：\(size), 正常保存")
        if leftCapacity < size {
            // 读取配置文件，删除已过期、即将过期、最近未访问的文件，直至可以保存为止
            DDLogInfo("需要删除文件后保存")
            leftCapacity = self.cleanDisk(leftCapacity, size: size)
        }
        return size <= leftCapacity
    }
    
    ///  更新配置文件
    ///
    ///  :param: name 文件名
    ///  :param: size 文件大小
    ///
    ///  :returns: 加密后的文件名
    private func updateConfig(name: String?, timestamp: NSTimeInterval, size: Int64) -> String {
        return updateConfig(name, timestamp: timestamp, size: size, mimeType: nil)
    }
    
    private func updateConfig(name: String?, timestamp: NSTimeInterval, size: Int64, mimeType: String?) -> String {
        // 核心方法：判断是否有足够的空间存储
        if !(self.preparePoolForSize(size)) {
            return ""
        }
        let cacheObj = CacheModel()
        // 已缓存的字典
        var cachedDict = (cache!.objectForKey(cacheDictKey) as? [String: CacheModel]) ?? [:]
        let nameTime = name ?? "" + "\(timestamp)"
        let encryptName = nameTime.md5
        cacheObj.name = name ?? ""
        cacheObj.key = encryptName
        cacheObj.createTime = timestamp
        cacheObj.mimeType = (mimeType ?? "")
        cacheObj.size = size
        cacheObj.filePath = NSURL(fileURLWithPath: (cachePath() + encryptName))
        cachedDict[encryptName] = cacheObj
        // 同步到PINCache
        cacheDict = cachedDict
        return encryptName
    }
    
    ///  创建文件夹
    private func createFolder(name: String, baseUrl: NSURL) {
        let folder = baseUrl.URLByAppendingPathComponent(name, isDirectory: true)
        let exist = fileManager.fileExistsAtPath(folder.path!)
        if !exist {
            try! fileManager.createDirectoryAtURL(folder, withIntermediateDirectories: true, attributes: nil)
            DDLogVerbose("缓存文件夹：" + folder.path!)
        }
    }
    
    ///  获取文件属性
    ///
    ///  :param: filePath 文件路径
    private func getFileAttributes(filePath: String) -> [String: AnyObject]? {
        let attributes = try? fileManager.attributesOfItemAtPath(filePath)
        return attributes
    }
    
    private func cachePath() -> String {
        let baseStr = ((basePath) != nil) ? basePath!.path! : CachePoolConstant.DefaultCachePath
        return baseStr + "/" + namespace + "/"
    }
    
    private func baseCacheUrl() -> NSURL {
        let baseUrl = ((basePath) != nil) ? basePath! : NSURL(fileURLWithPath: CachePoolConstant.DefaultCachePath)
        self.basePath = baseUrl
        return baseUrl
    }
    
    ///  设备剩余空间不足时，删除本地缓存文件
    ///
    ///  :param: lastSize 剩余空间
    ///  :param: size     至少需要的空间
    private func cleanDisk(lastSize: Int64, size: Int64) -> Int64 {
        var leftCapacity = lastSize
        // 遍历配置文件
        // 取出缓存字典
        var cachedDict = (cache!.objectForKey(cacheDictKey) as? [String: CacheModel]) ?? [:]
        DDLogInfo("排序前：\(cachedDict)")
        // 升序，最新的数据在最下面(目的：删除日期最小的旧数据)
        let sortedList = cachedDict.sort { $0.1.createTime < $1.1.createTime }
        print("=========================================================")
        DDLogInfo("排序后：\(sortedList)")
        
        // obj 是一个元组类型
        for (key, model) in sortedList {
            // 从沙河中删除
            let filePathStr = cachePath() + key
            if fileManager.fileExistsAtPath(filePathStr) {
                try! fileManager.removeItemAtPath(filePathStr)
            }
            // 从配置文件中删除
            cachedDict.removeValueForKey(key)
            cacheDict = cachedDict
            // 更新剩余空间大小
            leftCapacity += model.size
            DDLogError("remove=\(key), save=\(model.size) byte  lastSize=\(leftCapacity)  size=\(size)")
            if leftCapacity > size {
                break
            }
        }
        return leftCapacity
    }
    
    private func dateStringToTimestamp(stringTime: String) -> Double {
        let format = NSDateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = format.dateFromString(stringTime)
        let datestamp = date!.timeIntervalSince1970
        return datestamp
    }
}