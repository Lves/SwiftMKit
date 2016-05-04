//
//  CachePoolTests.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/4/29.
//  Copyright © 2016年 cdts. All rights reserved.
//

import XCTest
@testable import SwiftMKitDemo

class CachePoolTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let fileName = "fileName-\(arc4random_uniform(10000))"
    let namespace = "Test"
    func testMoveFile() {
        let cache = CachePool(namespace: namespace)
        let filePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first! + "/Test/com.pinterest.PINDiskCache.PINCache/CacheDict"
        let encryptName = cache.addObject(fileName, filePath: filePath)
        let dir = cache.cachePath()
        let destFilePath:String = dir + encryptName
        assert(cache.fileManager.fileExistsAtPath(destFilePath), "文件复制失败！")
    }
    
    func testInsertImage() {
        let cache = CachePool(namespace: namespace)
        let encryptName = cache.addObject(fileName, image: UIImage(named: "icon_user_head")!)
        NSThread.sleepForTimeInterval(1)
        assert(cache.objectForName(encryptName) != nil, "有延迟，或者文件被删除，或者缓存失败！")
    }

    func testReadObject() {
        let cache = CachePool(namespace: namespace)
        let data = cache.objectForName("fileName-6571")
        print("==> \(data)")
    }

    func testPreparePoolForSize() {
        let cache = CachePool(namespace: namespace)
        cache.preparePoolForSize(0)
    }
    
    func testCleanDisk() {
        let cache = CachePool(namespace: namespace)
        var lastSize: Double = 10
        cache.cleanDisk(&lastSize, size: 11)
    }
    
    func testCachedDiskspace() {
        let cache = CachePool(namespace: namespace)
        assert(cache.cachedDiskspace() > 0, "获取已缓存文件大小失败")
    }
    
    func testFreeDiskspace() {
        let (totalSpace, totalFreeSpace) = CachePool.freeDiskspace()
        assert(totalSpace < totalFreeSpace, "获取设备可用空间大小失败")
    }
    
    func testMD5() {
        let encryptStr = CachePool.md5(string: "Hello")
        assert(encryptStr == "8b1a9953c4611296a827abf8c47804d7", "md5加密失败！")
    }
    
}
