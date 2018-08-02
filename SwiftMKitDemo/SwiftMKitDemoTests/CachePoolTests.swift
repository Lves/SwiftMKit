//
//  CachePoolTests.swift
//  SwiftMKitDemo
//
//  Created by Mao on 6/16/16.
//  Copyright © 2016 cdts. All rights reserved.
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

    func testClearCache() {
        let cachePool: CachePoolProtocol = CachePool()
        let isCleared = cachePool.clear()
        XCTAssertTrue(isCleared)
        XCTAssertEqual(cachePool.size, 0)
    }
    
    func testCacheModel() {
        let cachePool: CachePoolProtocol = CachePool()
        cachePool.clear()
        let fileName = "icon_user_head"
        let image = UIImage(named: fileName)
        XCTAssertNotNil(image)
        let sizeBeforeCache = cachePool.size
        let key = (cachePool.addCache(image!, name: fileName))
        XCTAssertNotNil(key)
        sleep(1)
        let cachedImage = (cachePool.getCache(forKey: key)) as? UIImage
        XCTAssertNotNil(cachedImage)
        
        let sizeAfterCache = cachePool.size
        
        var all = cachePool.all()
        XCTAssertNotNil(all)
        XCTAssertEqual(all?.count ?? 0, 1)
        let model = all?.first
        XCTAssertEqual(model?.size ?? 0, sizeAfterCache-sizeBeforeCache)
        cachePool.clear()
        all = cachePool.all()
        XCTAssertNotNil(all)
        XCTAssertEqual(all?.count ?? 0, 0)
        
    }
    
    func testCacheImage() {
        let cachePool: CachePoolProtocol = CachePool()
        cachePool.clear()
        let fileName = "icon_user_head"
        let image = UIImage(named: fileName)
        XCTAssertNotNil(image)
        let sizeBeforeCache = cachePool.size
        let key = (cachePool.addCache(image!, name: fileName))
        XCTAssertNotNil(key)
        
        sleep(1)
        let cachedImage = (cachePool.getCache(forKey: key)) as? UIImage
        XCTAssertNotNil(cachedImage)
        
        let sizeAfterCache = cachePool.size
        XCTAssertLessThan(sizeBeforeCache, sizeAfterCache)
        XCTAssertLessThanOrEqual(cachePool.size, cachePool.capacity)
        
        let isRemoved = cachePool.removeCache(forKey: key)
        XCTAssertTrue(isRemoved)
        let sizeAfterRemoved = cachePool.size
        XCTAssertEqual(sizeBeforeCache, sizeAfterRemoved)
        XCTAssertLessThanOrEqual(cachePool.size, cachePool.capacity)
        let object = (cachePool.getCache(forKey: key))
        XCTAssertNil(object)
        cachePool.clear()
    }
    func testCacheNSData() {
        let cachePool: CachePoolProtocol = CachePool()
        cachePool.clear()
        let fileName = "icon_user_head"
        let data = UIImagePNGRepresentation(UIImage(named: fileName)!)
        XCTAssertNotNil(data)
        let sizeBeforeCache = cachePool.size
        let key = (cachePool.addCache(data!, name: fileName))
        XCTAssertNotNil(key)
        
        sleep(1)
        let cachedData = (cachePool.getCache(forKey: key)) as? NSData
        XCTAssertNotNil(cachedData)
        
        let sizeAfterCache = cachePool.size
        XCTAssertLessThan(sizeBeforeCache, sizeAfterCache)
        XCTAssertLessThanOrEqual(cachePool.size, cachePool.capacity)
        
        let isRemoved = cachePool.removeCache(forKey: key)
        XCTAssertTrue(isRemoved)
        let sizeAfterRemoved = cachePool.size
        XCTAssertEqual(sizeBeforeCache, sizeAfterRemoved)
        XCTAssertLessThanOrEqual(cachePool.size, cachePool.capacity)
        let object = (cachePool.getCache(forKey: key))
        XCTAssertNil(object)
        cachePool.clear()
    }
    func testCacheFile() {
        let cachePool: CachePoolProtocol = CachePool()
        cachePool.clear()
        let filePath = Bundle.main.path(forResource: "testhaha", ofType: "jpg")
        let fileName = " "
        XCTAssertNotNil(filePath)
        let fileUrl = URL(fileURLWithPath: filePath!)
        XCTAssertNotNil(fileUrl)
        let sizeBeforeCache = cachePool.size
        let key = (cachePool.addCache(fileUrl, name: fileName))
        XCTAssertNotNil(key)
        
        
        sleep(1)
        let cachedFile = UIImage(data: (cachePool.getCache(forKey: key) as! Data))
        XCTAssertNotNil(cachedFile)
        
        let sizeAfterCache = cachePool.size
        XCTAssertLessThan(sizeBeforeCache, sizeAfterCache)
        XCTAssertLessThanOrEqual(cachePool.size, cachePool.capacity)
        
        let isRemoved = cachePool.removeCache(forKey: key)
        XCTAssertTrue(isRemoved)
        let sizeAfterRemoved = cachePool.size
        XCTAssertEqual(sizeBeforeCache, sizeAfterRemoved)
        XCTAssertLessThanOrEqual(cachePool.size, cachePool.capacity)
        let object = (cachePool.getCache(forKey: key))
        XCTAssertNil(object)
        cachePool.clear()
    }
    func testCacheSizeOnlyMatch1() {
        var cachePool: CachePoolProtocol = CachePool()
        cachePool.clear()
        let fileName = "icon_user_head"
        let image = UIImage(named: fileName)
        XCTAssertNotNil(image)
        let sizeBeforeCache = cachePool.size
        let key = (cachePool.addCache(image!, name: fileName))
        XCTAssertNotNil(key)
        
        sleep(1)
        
        let sizeAfterCache = cachePool.size
        let sizeOfImage = sizeAfterCache - sizeBeforeCache
        cachePool.clear()
        cachePool.capacity = sizeOfImage * 1
        let key1 = (cachePool.addCache(image!, name: fileName + "1"))
        XCTAssertNotNil(key1)
        sleep(1)
        var cachedImage1 = (cachePool.getCache(forKey: key1)) as? UIImage
        XCTAssertNotNil(cachedImage1)
        XCTAssertLessThanOrEqual(cachePool.size, cachePool.capacity)
        let key2 = (cachePool.addCache(image!, name: fileName + "2"))
        XCTAssertNotNil(key2)
        sleep(1)
        let cachedImage2 = (cachePool.getCache(forKey: key2)) as? UIImage
        XCTAssertNotNil(cachedImage2)
        XCTAssertLessThanOrEqual(cachePool.size, cachePool.capacity)
        
        cachedImage1 = (cachePool.getCache(forKey: key1)) as? UIImage
        XCTAssertNil(cachedImage1)
        cachePool.clear()
    }
    func testCacheSizeMatchManyObjects() {
        var cachePool: CachePoolProtocol = CachePool()
        cachePool.clear()
        let fileName = "icon_user_head"
        let cacheCount = 10
        let image = UIImage(named: fileName)
        XCTAssertNotNil(image)
        let sizeBeforeCache = cachePool.size
        let key = (cachePool.addCache(image!, name: fileName))
        XCTAssertNotNil(key)
        let sizeAfterCache = cachePool.size
        let sizeOfImage = sizeAfterCache - sizeBeforeCache
        cachePool.clear()
        cachePool.capacity = sizeOfImage * Int64(cacheCount)
        
        for i in 0..<cacheCount*2 {
            let key1 = (cachePool.addCache(image!, name: fileName + i.toString))
            XCTAssertNotNil(key1)
            sleep(1)
            let cachedImage1 = (cachePool.getCache(forKey: key1)) as? UIImage
            XCTAssertNotNil(cachedImage1)
            XCTAssertLessThanOrEqual(cachePool.size, cachePool.capacity)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
