//
//  NSTimeIntervalTests.swift
//  SwiftMKitDemo
//
//  Created by Juxin on 4/28/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
@testable import SwiftMKitDemo
public extension NSTimeInterval

class NSTimeIntervalTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNSTimeInterval() {
        validateTime()
    }
    
    
    func validateTime() {
        var test: NSTimeInterval = 0
        XCTAssertEqual(true, (0, 0, 0) == test.secondsToHHmmss())
        XCTAssertEqual("00:00:00", test.secondsToHHmmssString())
        test = 3600
        XCTAssertEqual((1, 0, 0), test.secondsToHHmmss())
        XCTAssertEqual("01:00:00", test.secondsToHHmmssString())
        test = 60
        XCTAssertEqual((0, 1, 0), test.secondsToHHmmss())
        XCTAssertEqual("00:01:00", test.secondsToHHmmssString())
        test = 1
        XCTAssertEqual((0, 0, 1), test.secondsToHHmmss())
        XCTAssertEqual("00:00:01", test.secondsToHHmmssString())
        test = 3661
        XCTAssertEqual((1, 1, 1), test.secondsToHHmmss())
        XCTAssertEqual("01:01:01", test.secondsToHHmmssString())
        test = 3601
        XCTAssertEqual((1, 0, 1), test.secondsToHHmmss())
        XCTAssertEqual("01:00:01", test.secondsToHHmmssString())
        test = 61
        XCTAssertEqual((0, 1, 1), test.secondsToHHmmss())
        XCTAssertEqual("00:01:01", test.secondsToHHmmssString())
        test = 360000
        XCTAssertEqual((0, 0, 0), test.secondsToHHmmss())
        XCTAssertEqual("100:00:00", test.secondsToHHmmssString())
        test = -3600
        XCTAssertEqual((0, 0, 0), test.secondsToHHmmss())
        XCTAssertEqual("00:00:00", test.secondsToHHmmssString())
        test = 20000000000000000000
        XCTAssertEqual((0, 0, 0), test.secondsToHHmmss())
        XCTAssertEqual("00:00:00", test.secondsToHHmmssString())
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
