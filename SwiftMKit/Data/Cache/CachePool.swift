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
//                  别人笑我忒疯癫，我笑自己命太贱；
//                  不见满街漂亮妹，哪个归得程序员？

/**
 *
 * ━━━━━━神兽出没━━━━━━
 * 　　　┏┓　　　┏┓
 * 　　┏┛┻━━━┛┻┓
 * 　　┃　　　　　　　┃
 * 　　┃　　　━　　　┃
 * 　　┃　┳┛　┗┳　┃
 * 　　┃　　　　　　　┃
 * 　　┃　　　┻　　　┃
 * 　　┃　　　　　　　┃
 * 　　┗━┓　　　┏━┛Code is far away from bug with the animal protecting
 * 　　　　┃　　　┃    神兽保佑,代码无bug
 * 　　　　┃　　　┃
 * 　　　　┃　　　┗━━━┓
 * 　　　　┃　　　　　　　┣┓
 * 　　　　┃　　　　　　　┏┛
 * 　　　　┗┓┓┏━┳┓┏┛
 * 　　　　　┃┫┫　┃┫┫
 * 　　　　　┗┻┛　┗┻┛
 *
 * ━━━━━━感觉萌萌哒━━━━━━
 */

/**
 * 　　　　　　　　┏┓　　　┏┓
 * 　　　　　　　┏┛┻━━━┛┻┓
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┃　　　━　　　┃
 * 　　　　　　　┃　＞　　　＜　┃
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┃...　⌒　...　┃
 * 　　　　　　　┃　　　　　　　┃
 * 　　　　　　　┗━┓　　　┏━┛
 * 　　　　　　　　　┃　　　┃　Code is far away from bug with the animal protecting
 * 　　　　　　　　　┃　　　┃   神兽保佑,代码无bug
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┃
 * 　　　　　　　　　┃　　　┗━━━┓
 * 　　　　　　　　　┃　　　　　　　┣┓
 * 　　　　　　　　　┃　　　　　　　┏┛
 * 　　　　　　　　　┗┓┓┏━┳┓┏┛
 * 　　　　　　　　　　┃┫┫　┃┫┫
 * 　　　　　　　　　　┗┻┛　┗┻┛
 */

/**
 *　　　　　　　　┏┓　　　┏┓+ +
 *　　　　　　　┏┛┻━━━┛┻┓ + +
 *　　　　　　　┃　　　　　　　┃
 *　　　　　　　┃　　　━　　　┃ ++ + + +
 *　　　　　　 ████━████ ┃+
 *　　　　　　　┃　　　　　　　┃ +
 *　　　　　　　┃　　　┻　　　┃
 *　　　　　　　┃　　　　　　　┃ + +
 *　　　　　　　┗━┓　　　┏━┛
 *　　　　　　　　　┃　　　┃
 *　　　　　　　　　┃　　　┃ + + + +
 *　　　　　　　　　┃　　　┃　　　　Code is far away from bug with the animal protecting
 *　　　　　　　　　┃　　　┃ + 　　　　神兽保佑,代码无bug
 *　　　　　　　　　┃　　　┃
 *　　　　　　　　　┃　　　┃　　+
 *　　　　　　　　　┃　 　　┗━━━┓ + +
 *　　　　　　　　　┃ 　　　　　　　┣┓
 *　　　　　　　　　┃ 　　　　　　　┏┛
 *　　　　　　　　　┗┓┓┏━┳┓┏┛ + + + +
 *　　　　　　　　　　┃┫┫　┃┫┫
 *　　　　　　　　　　┗┻┛　┗┻┛+ + + +
 */

public struct CachePoolConstant {
    // 取手机剩余空间 DefaultCapacity = MIN(剩余空间, 100M)
    static let DefaultCapacity: Double = min(100*1024*1024, CachePool.freeDiskspace().1) // 默认缓存池空间 100M
    static let baseCachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first! + "/"
}

private class CacheModel : NSObject, NSCoding {
    var name: String = ""
    var encryptName: String = ""
    var createTime: NSTimeInterval = 0
    var size: Double = 0
    var lastVisitTime: NSTimeInterval = 0
    var expireTime: NSTimeInterval = 0
    var mimeType : String = ""
    
    @objc func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.encryptName, forKey: "encryptName")
        aCoder.encodeObject(self.createTime, forKey: "createTime")
        aCoder.encodeDouble(self.size, forKey: "size")
        aCoder.encodeObject(self.mimeType, forKey: "mimeType")
    }
    
    @objc required init(coder aDecoder: NSCoder) {
        super.init()
        self.name = aDecoder.decodeObjectForKey("name") as! String
        self.encryptName = aDecoder.decodeObjectForKey("encryptName") as! String
        self.createTime = aDecoder.decodeObjectForKey("createTime") as! NSTimeInterval
        self.size = aDecoder.decodeDoubleForKey("size")
        self.mimeType = aDecoder.decodeObjectForKey("mimeType") as! String
    }
    
    override init() {
        
    }
    
    override var description: String {
        return "\(name)  \(encryptName)  \(createTime)  \(size)"
    }
}

/// 缓存池：用于存储文件
public class CachePool: NSObject {
    let fileManager = NSFileManager.defaultManager()
    var cache: PINCache?
    public var namespace: String = "CachePool"
    public var capacity: Double = CachePoolConstant.DefaultCapacity {
        didSet {
            capacity = min(oldValue, CachePool.freeDiskspace().1)
        }
    }
    
    override init() {
        super.init()
        cache = PINCache(name: "PINCache", rootPath: self.cachePath())
        self.createFolder(namespace, baseUrl: NSURL(fileURLWithPath: CachePoolConstant.baseCachePath, isDirectory: true))
    }
    
    init(namespace: String?) {
        super.init()
        self.namespace = namespace ?? self.namespace
        cache = PINCache(name: "PINCache", rootPath: self.cachePath())
        self.createFolder(self.namespace, baseUrl: NSURL(fileURLWithPath: CachePoolConstant.baseCachePath, isDirectory: true))
    }
    
    
    ///  缓存对象
    ///
    ///  :param: name 键【 MD5(name+time) 】
    ///  :param: data 值
    ///
    ///  :returns: 加密后的文件名
    public func addObject(name: String, data: NSData) -> String {
        // 更新配置文件
        let timestamp = NSDate().timeIntervalSince1970
        let encryptName = self.updateConfig(name, timestamp:timestamp, size: Double(data.length))
        // 保存对象到沙河
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
    
    ///  缓存图片
    ///
    ///  :param: name  文件名称
    ///  :param: image 图片
    ///
    ///  :returns: 加密后的文件名
    public func addObject(name: String, image: UIImage) -> String {
        let data = UIImagePNGRepresentation(image)
        return self.addObject(name, data: data!)
    }
    
    ///  缓存文件（拷贝）
    ///
    ///  :param: name     文件名称
    ///  :param: filePath 源地址
    ///
    ///  :returns: 加密后的文件名
    public func addObject(name: String, filePath: String) -> String {
        // 拷贝文件
        // 生成目标路径
        let timestamp = NSDate().timeIntervalSince1970
        let nameTime = name + "\(timestamp)"
        let encryptName = CachePool.md5(string: nameTime)
        let dir = self.cachePath()
        let destFilePath:String = dir + encryptName
        try! fileManager.copyItemAtPath(filePath, toPath: destFilePath)
        DDLogInfo("filePath: \(filePath)")
        DDLogInfo("destFilePath: \(destFilePath)")
        // 获取文件信息
        if let attrs = self.getFileAttributes(destFilePath) {
            DDLogInfo("file info:\(attrs)")
            // 更新配置文件
            let size = attrs[NSFileSize] as! Double
            return self.updateConfig(name, timestamp:timestamp, size: size)
        }
        return name
    }
    
    ///  更新配置文件
    ///
    ///  :param: name 文件名
    ///  :param: size 文件大小
    ///
    ///  :returns: 加密后的文件名
    private func updateConfig(name: String, timestamp: NSTimeInterval, size: Double) -> String {
        // 核心方法：判断是否有足够的空间存储
        self.preparePoolForSize(size)
        let cacheObj = CacheModel()
        // 已缓存的字典
        var cachedDict = (cache!.objectForKey(cacheDictKey) as? [String: CacheModel]) ?? [:]
        let nameTime = name + "\(timestamp)"
        let encryptName = CachePool.md5(string: nameTime)
        cacheObj.name = name
        cacheObj.encryptName = encryptName
        cacheObj.createTime = timestamp
        cacheObj.size = size
        cachedDict[name] = cacheObj
        // 同步到PINCache
        cacheDict = cachedDict
        return encryptName
    }
    
    ///  取缓存对象
    public func objectForName(name: String) -> NSData? {
        let dir = self.cachePath()
        let filePath:String = dir + name
        DDLogInfo("objectForName filePath：" + filePath)
        let data = fileManager.contentsAtPath(filePath)
        if data == nil {
            return nil
        }
        return data!
    }
    
    ///  清空磁盘缓存
    public func clearDisk() {
        let dir = CachePoolConstant.baseCachePath + namespace
        try! fileManager.removeItemAtPath(dir)
        try! fileManager.createDirectoryAtPath(dir, withIntermediateDirectories: true, attributes: nil)
    }
    
    ///  已缓存对象大小
    public func cachedDiskspace() -> Double {
        // 遍历配置文件
        // 取出缓存字典
        let cachedDict = (cache!.objectForKey(cacheDictKey) as? [String: CacheModel]) ?? [:]
        var cachedSize: Double = 0
        for value in cachedDict.values {
            cachedSize += value.size
        }
        return cachedSize
    }
    
    /// 获取设备剩余可用空间
    public class func freeDiskspace() -> (Double, Double) {
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
        return (totalSpace, totalFreeSpace)
    }
    
    // 缓存相关
    let cacheDictKey = "CacheDict"
    private var cacheDict: Dictionary<String, CacheModel>? {
        get {
            return cache!.objectForKey(cacheDictKey) as? Dictionary<String, CacheModel>
        }
        set {
            if let value = newValue {
                cache!.setObject(value, forKey: cacheDictKey)
            }else {
                cache!.removeObjectForKey(cacheDictKey)
            }
        }
    }
}

extension CachePool {
    ///  存储文件之前，判断是否有足够的空间存储
    ///
    ///  :param: size 即将存储的文件大小
    public func preparePoolForSize(size: Double) {
        // 剩余空间
        var (_, lastSize) = CachePool.freeDiskspace()
        // 比较 设备剩余可用空间 & 文件大小
        lastSize = min(lastSize, capacity)  // 取出最小可用空间
        if lastSize > size {
            // 正常保存
            print("设备可用空间：\(CachePool.freeDiskspace()), 文件大小：\(size), 正常保存")
        } else {
            // 读取配置文件，删除已过期、即将过期、最近未访问的文件，直至可以保存为止
            print("设备可用空间：\(CachePool.freeDiskspace()), 文件大小：\(size), 删除文件后保存")
            self.cleanDisk(&lastSize, size: size)
        }
    }
    
    ///  创建文件夹
    private func createFolder(name: String,baseUrl: NSURL) {
        let folder = baseUrl.URLByAppendingPathComponent(name, isDirectory: true)
        let exist = fileManager.fileExistsAtPath(folder.path!)
        if !exist {
            try! fileManager.createDirectoryAtURL(folder, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    ///  获取文件属性
    ///
    ///  :param: filePath 文件路径
    private func getFileAttributes(filePath: String) -> [String: AnyObject]? {
        let attributes = try? fileManager.attributesOfItemAtPath(filePath)
        return attributes
    }
    
    public func cachePath() -> String {
        return CachePoolConstant.baseCachePath + namespace + "/"
    }
    
    ///  设备剩余空间不足时，删除本地缓存文件
    ///
    ///  :param: lastSize 剩余空间
    ///  :param: size     至少需要的空间
    public func cleanDisk(inout lastSize: Double, size: Double) {
        // 遍历配置文件
        // 取出缓存字典
        var cachedDict = (cache!.objectForKey(cacheDictKey) as? [String: CacheModel]) ?? [:]
        DDLogInfo("排序前：")
        for (key, value) in cachedDict {
            print("\(key):\(value.description)")
        }
        // 升序，最新的数据在最下面(目的：删除日期最小的旧数据)
        let sortedList = cachedDict.sort { (obj1, obj2) -> Bool in
            if obj1.1.createTime < obj2.1.createTime {
                return true
            }
            if obj1.1.createTime < obj2.1.createTime {
                return obj1.0 < obj2.0
            }
            return false
        }
        print("=========================================================")
        DDLogInfo("排序后：")
        for obj in sortedList {
            print("\(obj.0):\(obj.1.description)")
        }
        // obj 是一个元组类型
        for obj in sortedList {
            let (key, model) = obj
            // 从沙河中删除
            let dir = self.cachePath()
            let filePath:String = dir + model.name
            if fileManager.fileExistsAtPath(filePath) {
                try! fileManager.removeItemAtURL(NSURL(fileURLWithPath: filePath))
            }
            // 从配置文件中删除
            cachedDict.removeValueForKey(key)
            cacheDict = cachedDict
            // 更新剩余空间大小
            lastSize += model.size
            DDLogError("remove=\(key), save=\(model.size) byte  lastSize=\(lastSize)")
            if lastSize > size {
                break
            }
        }
    }
    
    public class func md5(string string: String) -> String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        DDLogError("加密前：\(string)")
        DDLogError("加密后：\(digestHex)")
        return digestHex
    }
    
    private func dateStringToTimestamp(stringTime: String) -> Double {
        let format = NSDateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = format.dateFromString(stringTime)
        let datestamp = date!.timeIntervalSince1970
        return datestamp
    }
}