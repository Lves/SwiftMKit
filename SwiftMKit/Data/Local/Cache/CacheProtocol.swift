//
//  CacheProtocol.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/4/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit

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

public protocol CacheModelProtocol {
    var key: String { get }
    var name: String { get set }
    var filePath: NSURL { get }
    var size: Int64 { get }
    var mimeType : String { get set }
    var createTime: NSTimeInterval { get }
    var lastVisitTime: NSTimeInterval { get set }
    var expireTime: NSTimeInterval { get set }
}

public protocol CachePoolProtocol {
    // MARK: - 属性列表
    /// 缓存池容量
    var capacity: Int64 { get set }
    /// 已缓存大小
    var size: Int64 { get }
    /// 缓存根路径
    var basePath: NSURL? { get set }
    /// 缓存文件夹名称
    var namespace: String { get set }
    
    // MARK: - 方法列表
    ///  缓存对象
    ///
    ///  :param: name 键【 MD5(name+time) 】
    ///  :param: data 值
    ///
    ///  :returns: 加密后的文件名
    func addCache(data: NSData, name: String?) -> String
    ///  缓存图片
    func addCache(image: UIImage, name: String?) -> String
    ///  缓存文件（拷贝）
    ///
    ///  :param: name     文件名称
    ///  :param: filePath 源地址
    ///
    ///  :returns: 加密后的文件名
    func addCache(filePath: NSURL, name: String?) -> String
    ///  获取所有缓存对象
    func all() -> [CacheModelProtocol]?
    ///  获取缓存对象
    ///
    ///  :param: key key
    func getCache(key: String) -> AnyObject?
    ///  移除缓存对象
    ///
    ///  :param: key key
    func removeCache(key: String) -> Bool
    ///  清空缓存
    func clear() -> Bool
}