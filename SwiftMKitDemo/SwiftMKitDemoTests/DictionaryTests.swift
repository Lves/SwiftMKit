//
//  DictionaryTests.swift
//  SwiftMKitDemo
//
//  Created by Mao on 6/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import Foundation
import EZSwiftExtensions
@testable import SwiftMKitDemo

class DictionaryTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStringString() {
        var left = [
            "a": "123",
            "b": "345",
            "c": "123"
        ]
        let right = [
            "a": "1",
            "c": "2"
        ]
        
        let res = left + right
        XCTAssertNotNil(res, "should notnil")
        XCTAssertEqual(res["a"], right["a"], "should be refreshed")
        XCTAssertEqual(res["b"], left["b"], "should be refreshed")
        XCTAssertEqual(res["c"], right["c"], "should be refreshed")
        
        XCTAssertNotNil(res.stringFromHttpParameters(), "should notnil")
        
        var results = res.stringFromHttpParameters().componentsSeparatedByString("&")
        XCTAssertTrue(results.contains("a=1"), "should equal to 'a=1&b=345&c=2'")
        XCTAssertTrue(results.contains("b=345"), "should equal to 'a=1&b=345&c=2'")
        XCTAssertTrue(results.contains("c=2"), "should equal to 'a=1&b=345&c=2'")
        
        let temp = left
        left += right
        XCTAssertNotNil(left, "should notnil")
        XCTAssertEqual(left["a"], right["a"], "should be refreshed")
        XCTAssertEqual(left["b"], temp["b"], "should be refreshed")
        XCTAssertEqual(left["c"], right["c"], "should be refreshed")
        
        XCTAssertNotNil(left.stringFromHttpParameters(), "should notnil")
        results = res.stringFromHttpParameters().componentsSeparatedByString("&")
        XCTAssertTrue(results.contains("a=1"), "should equal to 'a=1&b=345&c=2'")
        XCTAssertTrue(results.contains("b=345"), "should equal to 'a=1&b=345&c=2'")
        XCTAssertTrue(results.contains("c=2"), "should equal to 'a=1&b=345&c=2'")
    }
    
    func testStringDouble() {
        var left = [
            "a": 0.6,
            "b": 1.2
        ]
        let right = [
            "c": 1.8,
            "d": 2.4
        ]
        
        let res = left + right
        XCTAssertNotNil(res, "should notnil")
        XCTAssertEqual(res["a"], left["a"], "should be refreshed")
        XCTAssertEqual(res["b"], left["b"], "should be refreshed")
        XCTAssertEqual(res["c"], right["c"], "should be refreshed")
        XCTAssertEqual(res["d"], right["d"], "should be refreshed")
        
        XCTAssertNotNil(res.stringFromHttpParameters(), "should notnil")
        
        var results = res.stringFromHttpParameters().componentsSeparatedByString("&")
        XCTAssertTrue(results.contains("a=0.6"), "should equal to 'a=0.6&b=1.2&c=1.8&d=2.4'")
        XCTAssertTrue(results.contains("b=1.2"), "should equal to 'a=0.6&b=1.2&c=1.8&d=2.4'")
        XCTAssertTrue(results.contains("c=1.8"), "should equal to 'a=0.6&b=1.2&c=1.8&d=2.4'")
        XCTAssertTrue(results.contains("d=2.4"), "should equal to 'a=0.6&b=1.2&c=1.8&d=2.4'")
        
        let temp = left
        left += right
        XCTAssertNotNil(left, "should notnil")
        XCTAssertEqual(left["a"], temp["a"], "should be refreshed")
        XCTAssertEqual(left["b"], temp["b"], "should be refreshed")
        XCTAssertEqual(left["c"], right["c"], "should be refreshed")
        XCTAssertEqual(left["d"], right["d"], "should be refreshed")
        
        XCTAssertNotNil(left.stringFromHttpParameters(), "should notnil")
        results = res.stringFromHttpParameters().componentsSeparatedByString("&")
        XCTAssertTrue(results.contains("a=0.6"), "should equal to 'a=0.6&b=1.2&c=1.8&d=2.4'")
        XCTAssertTrue(results.contains("b=1.2"), "should equal to 'a=0.6&b=1.2&c=1.8&d=2.4'")
        XCTAssertTrue(results.contains("c=1.8"), "should equal to 'a=0.6&b=1.2&c=1.8&d=2.4'")
        XCTAssertTrue(results.contains("d=2.4"), "should equal to 'a=0.6&b=1.2&c=1.8&d=2.4'")
    }
    
    func testNil() {
        var left = [String:String]()
        let right = [String:String]()
        
        let res = left + right
        XCTAssertNotNil(res, "should be empty")
        XCTAssertEqual(res.count, 0, "should be empty")
        
        XCTAssertNotNil(res.stringFromHttpParameters(), "should notnil")
        XCTAssertEqual(res.stringFromHttpParameters(), "", "should equal to ''")
        
        left += right
        XCTAssertNotNil(left, "should be empty")
        XCTAssertEqual(left.count, 0, "should be empty")
        
        XCTAssertNotNil(left.stringFromHttpParameters(), "should notnil")
        XCTAssertNotNil(left.stringFromHttpParameters(), "should notnil")
        XCTAssertEqual(left.stringFromHttpParameters(), "", "should equal to ''")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
