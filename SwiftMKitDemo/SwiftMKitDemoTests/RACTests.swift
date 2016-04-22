//
//  RACTests.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/22/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import ReactiveCocoa
@testable import SwiftMKitDemo

class RACTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCombineLatestSignal() {
        let expectation = self.expectationWithDescription("CombineLatest Signal then reduce")
        let signal1 = SignalProducer<Int, NSError> { sink, dispose in
            sink.sendNext(1)
            sink.sendCompleted()
        }
        let signal2 = SignalProducer<Int, NSError> { sink, dispose in
            sink.sendNext(2)
            sink.sendCompleted()
        }
        let signal3: SignalProducer<Int, NSError> = combineLatest(signal1, signal2).reduce(0) { x, data in
            let (a, b) = data
            return a + b
        }.on(next: { x in
                print(x)
                XCTAssertEqual(3, x)
                expectation.fulfill()
            }, failed: { error in
                print(error)
                expectation.fulfill()
        })
        signal3.start()
        
        self.waitForExpectationsWithTimeout(100, handler: nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
