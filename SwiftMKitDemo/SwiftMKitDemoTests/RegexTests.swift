//
//  RegexTests.swift
//  SwiftMKitDemo
//
//  Created by Mao on 6/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
@testable import SwiftMKitDemo

class RegexTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRegex() {
        let match = ("onev@onevcat.com" =~ "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$")
        XCTAssertTrue(match, "email regex should match")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
