//
//  StringTests.swift
//  SwiftMKitDemo
//
//  Created by Mao on 6/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
@testable import SwiftMKitDemo

class StringTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFormatMask() {
        var string = "18600001234"
        XCTAssertEqual("186****1234", string.formatMask(NSRange(location: 3,length: 4)))
        string = "18600"
        XCTAssertEqual("186****", string.formatMask(NSRange(location: 3,length: 4)))
        string = "18"
        XCTAssertEqual("****", string.formatMask(NSRange(location: 3,length: 4)))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
