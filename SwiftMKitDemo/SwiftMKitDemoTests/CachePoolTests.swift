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
        let result = CachePool.getFreeDiskspace()
        print("手机剩余存储空间为：\(result / 1024 / 1024)MB")
    }
    
}
