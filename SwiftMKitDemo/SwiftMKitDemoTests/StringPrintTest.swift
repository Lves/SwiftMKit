//
//  StringPrintTest.swift
//  SwiftMKitDemoTests
//
//  Created by wei.mao on 2018/8/2.
//  Copyright © 2018年 cdts. All rights reserved.
//

import XCTest

class StringPrintTest: XCTestCase {
    
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
        let str = "\\u5f20\\u4e09"
        let str2 = NSMutableString(string: str)
        CFStringTransform(str2, nil, "Any-Hex/Java" as NSString, true )
        print(str2 as String)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
