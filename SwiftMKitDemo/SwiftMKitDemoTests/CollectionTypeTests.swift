//
//  CollectionTypeTests.swift
//  SwiftMKitDemo
//
//  Created by Juxin on 4/28/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
@testable import SwiftMKitDemo

class CollectionTypeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCollectionType() {
        
        let testarry = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        XCTAssertEqual(testarry[0], testarry[0])
        XCTAssertEqual(testarry[6], testarry[6])
        XCTAssertEqual(testarry[9], testarry[9])
        XCTAssertNil(testarry[11])
        
        let nilarry:[Int] = []
        XCTAssertNil(nilarry[0])
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
