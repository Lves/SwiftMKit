//
//  NSTimeIntervalTests.swift
//  SwiftMKitDemo
//
//  Created by Juxin on 4/28/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import CocoaLumberjack
@testable import SwiftMKitDemo

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
        func validateItem(_ expectTuple: (Int,Int,Int), tuple: (Int,Int,Int), expectResult: String, result: String, source: TimeInterval) {
            XCTAssertEqual(expectTuple.0, tuple.0, "source: \(source)")
            XCTAssertEqual(expectTuple.1, tuple.1, "source: \(source)")
            XCTAssertEqual(expectTuple.2, tuple.2, "source: \(source)")
            XCTAssertEqual(expectResult, result, "source: \(source)")
        }
        var test: TimeInterval = 0
        validateItem((0,0,0), tuple: test.secondsToHHmmss(), expectResult: "00:00:00", result: test.secondsToHHmmssString(), source: test)
        
        test = 3600
        validateItem((1,0,0), tuple: test.secondsToHHmmss(), expectResult: "01:00:00", result: test.secondsToHHmmssString(), source: test)
        
        test = 60
        validateItem((0,1,0), tuple: test.secondsToHHmmss(), expectResult: "00:01:00", result: test.secondsToHHmmssString(), source: test)
        
        test = 1
        validateItem((0,0,1), tuple: test.secondsToHHmmss(), expectResult: "00:00:01", result: test.secondsToHHmmssString(), source: test)
        
        test = 3661
        validateItem((1,1,1), tuple: test.secondsToHHmmss(), expectResult: "01:01:01", result: test.secondsToHHmmssString(), source: test)
        
        test = 3601
        validateItem((1,0,1), tuple: test.secondsToHHmmss(), expectResult: "01:00:01", result: test.secondsToHHmmssString(), source: test)
        
        test = 61
        validateItem((0,1,1), tuple: test.secondsToHHmmss(), expectResult: "00:01:01", result: test.secondsToHHmmssString(), source: test)
        
        test = 360000
        validateItem((100,0,0), tuple: test.secondsToHHmmss(), expectResult: "100:00:00", result: test.secondsToHHmmssString(), source: test)
        
        test = 7272.72
        validateItem((2,1,12), tuple: test.secondsToHHmmss(), expectResult: "02:01:12", result: test.secondsToHHmmssString(), source: test)
        
        test = -3600
        validateItem((-1,0,0), tuple: test.secondsToHHmmss(), expectResult: "-1:00:00", result: test.secondsToHHmmssString(), source: test)
        
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
