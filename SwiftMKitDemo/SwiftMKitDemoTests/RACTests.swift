//
//  RACTests.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/22/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import ReactiveCocoa
import Result
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
    
    var mproperty: MutableProperty<Int> = MutableProperty<Int>(1)
    dynamic var property: Int = 1
    var textfield: UITextField = UITextField()
    var mmessage: MutableProperty<String> = MutableProperty<String>("")
    
    func testRACObserver() {
        let expectation1 = self.expectationWithDescription("Observe Signal")
        let expectation2 = self.expectationWithDescription("Observe Signal")
        let expectation3 = self.expectationWithDescription("Observe Signal")
        var index = 1
        mproperty.producer.skip(1).startWithNext { x in
            XCTAssertEqual(index, x)
            print("mproperty: \(x)")
            expectation1.fulfill()
        }
        DynamicProperty(object: self, keyPath: "property").producer.skip(1).map { x in
            x as! Int
        }.startWithNext { x in
            XCTAssertEqual(index, x)
            print("property: \(x)")
            expectation2.fulfill()
        }
        let message = "abc"
        mmessage <~ textfield.rac_textSignalProducer()
        XCTAssertEqual("", mmessage.value)
        textfield.text = message
        textfield.sendActionsForControlEvents(.EditingChanged)
        XCTAssertEqual(textfield.text, mmessage.value)
        textfield.rac_textSignalProducer().skip(1).startWithNext { text in
            XCTAssertEqual(message, text)
            print("message: \(text)")
            expectation3.fulfill()
        }
        index = 2
        mproperty.value = index
        property = index
        textfield.text = message
        textfield.sendActionsForControlEvents(.EditingChanged)
        self.waitForExpectationsWithTimeout(100, handler: nil)
    }
    
    var button: UIButton = UIButton()
    
    func testRACSignalCombineAndMap() {
        let validTextFieldSignal = textfield.rac_textSignal().toSignalProducer().map{ ($0 as! String).length >= 3 }.flatMapError { _ in return SignalProducer<Bool, NoError>.empty }
        DynamicProperty(object: self.button, keyPath: "enabled") <~ combineLatest(validTextFieldSignal, mproperty.producer).map { textValid, value in
            let result = textValid && value > 0
            print("\(textValid) \(value): \(result)")
            return result
        }
        mproperty.value = 0
        textfield.text = "12"
        textfield.sendActionsForControlEvents(.EditingChanged)
        XCTAssertFalse(button.enabled)
        textfield.text = "123"
        textfield.sendActionsForControlEvents(.EditingChanged)
        XCTAssertFalse(button.enabled)
        mproperty.value = 1
        XCTAssertTrue(button.enabled)
        textfield.text = "12"
        textfield.sendActionsForControlEvents(.EditingChanged)
        XCTAssertFalse(button.enabled)
    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
