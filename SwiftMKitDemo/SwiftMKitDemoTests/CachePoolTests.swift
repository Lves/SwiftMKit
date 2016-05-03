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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFreeDiskSpace() {
        let result = CachePool.freeDiskspace()
        print("手机剩余存储空间为：\(result/1024/1024/1024)GB")
    }
    
    let fileName = "fileName-\(arc4random_uniform(10000))"
    let namespace = "Test"
    func testInsertObject() {
        let cache = CachePool(namespace: namespace)
        cache.addObject(fileName, data: "content14556")
    }
    
    func testReadObject() {
        let cache = CachePool(namespace: namespace)
        let data = cache.objectForName(fileName)
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
    
}
