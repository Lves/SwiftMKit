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
    
    let signal1 = SignalProducer<Int, NSError> { sink, dispose in
        sink.sendNext(1)
        sink.sendCompleted()
    }
    let signal2 = SignalProducer<Int, NSError> { sink, dispose in
        sink.sendNext(2)
        sink.sendCompleted()
    }
    let signalError = SignalProducer<Int, NSError> { sink, dispose in
        sink.sendFailed(NSError(domain: "TestError", code: -100, userInfo: nil))
    }
    
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
        
        let signal: SignalProducer<Int, NSError> = combineLatest(signal1, signal2).reduce(0) { x, data in
            let (a, b) = data
            XCTAssertEqual(1, a)
            XCTAssertEqual(2, b)
            return a + b
        }.on(next: { x in
                print(x)
                XCTAssertEqual(3, x)
                expectation.fulfill()
            }, failed: { error in
                print(error)
                XCTAssertTrue(false)
                expectation.fulfill()
        })
        signal.start()
        
        self.waitForExpectationsWithTimeout(100, handler: nil)
    }
    func testCombineLatestErrorSignal() {
        let expectation = self.expectationWithDescription("CombineLatest Signal then reduce with error")
        
        let signal: SignalProducer<Int, NSError> = combineLatest(signalError, signal2).reduce(0) { x, data in
            let (a, b) = data
            return a + b
            }.on(next: { x in
                print(x)
                XCTAssertTrue(false)
                expectation.fulfill()
                }, failed: { error in
                    print(error)
                    XCTAssertNotNil(error)
                    expectation.fulfill()
            })
        signal.start()
        self.waitForExpectationsWithTimeout(100, handler: nil)
    }
    func testCombineLatestEatErrorSignal() {
        let expectation = self.expectationWithDescription("CombineLatest Signal then reduce with eat error")
        
        let signalEatError: SignalProducer<Int, NSError> = signalError.flatMapError { error in
            print("I know the error: \(error)")
            XCTAssertNotNil(error)
            return SignalProducer<Int, NSError>(value: 0)
        }
        let signal: SignalProducer<Int, NSError> = combineLatest(signalEatError, signal2).reduce(0) { x, data in
            let (a, b) = data
            XCTAssertEqual(0, a)
            XCTAssertEqual(2, b)
            return a + b
            }.on(next: { x in
                print(x)
                XCTAssertEqual(2, x)
                expectation.fulfill()
                }, failed: { error in
                    print(error)
                    XCTAssertTrue(false)
                    expectation.fulfill()
            })
        signal.start()
        self.waitForExpectationsWithTimeout(100, handler: nil)
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}