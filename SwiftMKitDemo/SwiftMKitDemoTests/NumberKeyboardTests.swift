//
//  NumberKeyboardTests.swift
//  SwiftMKitDemo
//
//  Created by Mao on 6/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
@testable import SwiftMKitDemo

class NumberKeyboardTests: XCTestCase {
    
    var numberKeyboard: NumberKeyboardProtocol = NumberKeyboard()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInputDotNormalType() {
        numberKeyboard.type = .Normal
        
        var old = "12.3"
        var new = "1.2.3"
        var (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "12.3")
        old = "123"
        new = "12.3"
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "12.3")
        old = "123"
        new = ".123"
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0.123")
        
        old = "123"
        new = "123."
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "123.")
        
        old = "10"
        new = "1.0"
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "1.0")
        
        old = "0"
        new = ".0"
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0.0")
        
        old = ""
        new = "."
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0.")

    }
    func testInputDotMoneyType() {
        numberKeyboard.type = .Money
        var old = "12.3"
        var new = "1.2.3"
        var (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "12.3")
        
        old = "123"
        new = "12.3"
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "12.3")
        
        old = "123"
        new = ".123"
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0.12")
        
        old = "123"
        new = "123."
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "123.")
        
        old = "10"
        new = "1.0"
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "1.0")
        
        old = "100"
        new = ".100"
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0.10")
        
        old = "0"
        new = ".0"
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0.0")
        
        old = ""
        new = "."
        (final, _) = numberKeyboard.matchInputDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0.")
        
    }
    func testInputNumberNormalType() {
        numberKeyboard.type = .Normal
        var old = "0"
        var new = "01"
        var (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "01")
        
        old = "0"
        new = "00"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "00")
        
        old = "0.1"
        new = "00.1"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "00.1")
        
        old = "0.1"
        new = "0.01"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0.01")
        
        old = "0.1"
        new = "0.10"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0.10")
        
        old = "0.1"
        new = "10.1"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "10.1")
        
        old = "0.1"
        new = "02.1"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "02.1")
        
        old = "10.10"
        new = "10.105"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "10.105")
        
        old = "10.10"
        new = "10.100"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "10.100")
        
        old = "123.21"
        new = "123.321"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "123.321")
    }
    func testInputNumberMoneyType() {
        numberKeyboard.type = .Money
        
        var old = "0"
        var new = "01"
        var (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "01")
        
        old = "0"
        new = "00"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "00")
        
        old = "0.1"
        new = "00.1"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "00.1")
        
        old = "0.1"
        new = "0.01"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0.01")
        
        old = "0.1"
        new = "0.10"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0.10")
        
        old = "0.1"
        new = "10.1"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "10.1")
        
        old = "0.1"
        new = "02.1"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "02.1")
        
        old = "10.10"
        new = "10.105"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "10.10")
        
        old = "10.10"
        new = "10.100"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "10.10")
        
        old = "10.10"
        new = "10.120"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "10.10")
    }
    func testInputNoDotType() {
        numberKeyboard.type = .NoDot
        
        var old = "0"
        var new = "01"
        var (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "01")
        
        old = "0"
        new = "00"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "00")
        
        old = "1"
        new = "01"
        (final, _) = numberKeyboard.matchInputNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "01")
    }
    func testDeleteNumberNormalType() {
        numberKeyboard.type = .Normal
        
        var old = "01"
        var new = "0"
        var (final, _) = numberKeyboard.matchDeleteNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0")
        
        old = "01"
        new = "1"
        (final, _) = numberKeyboard.matchDeleteNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "1")
        
        old = "0.1"
        new = ".1"
        (final, _) = numberKeyboard.matchDeleteNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, ".1")
        
        old = "0.1"
        new = "0."
        (final, _) = numberKeyboard.matchDeleteNumber(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "0.")
    }
    func testDeleteDotNormalType() {
        numberKeyboard.type = .Normal
        
        var old = "0.1"
        var new = "01"
        var (final, _) = numberKeyboard.matchDeleteDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "1")
        
        old = "00.1"
        new = "001"
        (final, _) = numberKeyboard.matchDeleteDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "1")
        
        old = "01.1"
        new = "011"
        (final, _) = numberKeyboard.matchDeleteDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "11")
        
        old = "1.23"
        new = "123"
        (final, _) = numberKeyboard.matchDeleteDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "123")
        
        old = "12."
        new = "12"
        (final, _) = numberKeyboard.matchDeleteDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "12")
        
        old = ".23"
        new = "23"
        (final, _) = numberKeyboard.matchDeleteDot(old, new: new)
        XCTAssertNotNil(final)
        XCTAssertEqual(final, "23")
    }
    func testmatchConfirmNormalType() {
        numberKeyboard.type = .Normal
        
        var input = "1"
        var (output) = numberKeyboard.matchConfirm(input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "1")
        
        input = "0.1"
        (output) = numberKeyboard.matchConfirm(input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "0.1")
        
        input = "01"
        (output) = numberKeyboard.matchConfirm(input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "1")
        
        input = "00001"
        (output) = numberKeyboard.matchConfirm(input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "1")
        
        input = ".1"
        (output) = numberKeyboard.matchConfirm(input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "0.1")
        
        input = "00.1"
        (output) = numberKeyboard.matchConfirm(input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "0.1")
        
        input = "01.5"
        (output) = numberKeyboard.matchConfirm(input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "1.5")
        
        input = "1.50"
        (output) = numberKeyboard.matchConfirm(input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "1.5")
        
        input = "1.00"
        (output) = numberKeyboard.matchConfirm(input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "1")
        
        input = "0.0"
        (output) = numberKeyboard.matchConfirm(input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "0")
        
        input = "0.00000005"
        (output) = numberKeyboard.matchConfirm(input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "0.00000005")
        
        input = ""
        (output) = numberKeyboard.matchConfirm(input)
        XCTAssertNotNil(output)
        XCTAssertEqual(output, "")
    }



    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
