//
//  NumberKeyboardSpec.swift
//  SwiftMKitDemo
//
//  Created by jimubox on 16/5/19.
//  Copyright © 2016年 cdts. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import SwiftMKitDemo

class NumberKeyboardSpec: QuickSpec {
    
    override func spec() {

        var numberKeyboard: NumberKeyboardProtocol = NumberKeyboard()
        
        describe("clear") {
            
            context("") {

                it("") {

                
                }
            }
        }
        
        describe("matchInputDot") {
            context("normal type") {
                it("should output natrual number") {
                    numberKeyboard.type = .Normal
                    
                    var old = "12.3"
                    var new = "1.2.3"
                    var (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("12.3"))
                    
                    old = "123"
                    new = "12.3"
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("12.3"))
                    
                    old = "123"
                    new = ".123"
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0.123"))
                    
                    old = "123"
                    new = "123."
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("123."))
                    
                    old = "10"
                    new = "1.0"
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("1.0"))
                    
                    old = "0"
                    new = ".0"
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0.0"))
                    
                    old = ""
                    new = "."
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0."))
                }
            }
            
            context("money type") {
                it("should output money number") {
                    numberKeyboard.type = .Money
                    
                    var old = "12.3"
                    var new = "1.2.3"
                    var (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("12.3"))
                    
                    old = "123"
                    new = "12.3"
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("12.3"))
                    
                    old = "123"
                    new = ".123"
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0.12"))
                    
                    old = "123"
                    new = "123."
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("123."))
                    
                    old = "10"
                    new = "1.0"
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("1.0"))
                    
                    old = "100"
                    new = ".100"
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0.10"))
                    
                    old = "0"
                    new = ".0"
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0.0"))
                    
                    old = ""
                    new = "."
                    (final, _) = numberKeyboard.matchInputDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0."))
                }
            }

        }
        
        describe("matchInputNumber") {
            context("normal type") {
                it("should output natrual number") {
                    numberKeyboard.type = .Normal
                    
                    var old = "0"
                    var new = "01"
                    var (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("1"))
                    
                    old = "0"
                    new = "00"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0"))
                    
                    old = "0.1"
                    new = "00.1"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0.1"))
                    
                    old = "0.1"
                    new = "0.01"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0.01"))
                    
                    old = "0.1"
                    new = "0.10"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0.10"))
                    
                    old = "0.1"
                    new = "10.1"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("10.1"))
                    
                    old = "0.1"
                    new = "02.1"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("2.1"))
                    
                    old = "10.10"
                    new = "10.105"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("10.105"))
                    
                    old = "10.10"
                    new = "10.100"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("10.100"))
                    
                    old = "123.21"
                    new = "123.321"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("123.321"))
                }
            }
            context("money type") {
                it("should output money number") {
                    numberKeyboard.type = .Money
                    
                    var old = "0"
                    var new = "01"
                    var (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("01"))
                    
                    old = "0"
                    new = "00"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("00"))
                    
                    old = "0.1"
                    new = "00.1"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("00.1"))
                    
                    old = "0.1"
                    new = "0.01"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0.01"))
                    
                    old = "0.1"
                    new = "0.10"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0.10"))
                    
                    old = "0.1"
                    new = "10.1"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("10.1"))
                    
                    old = "0.1"
                    new = "02.1"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("02.1"))
                    
                    old = "10.10"
                    new = "10.105"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("10.10"))
                    
                    old = "10.10"
                    new = "10.100"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("10.10"))
                    
                    //无法再次从小数部分输入数字
                    old = "123.21"
                    new = "123.21"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("123.21"))
                }
            }
            
            context("nodot type") {
                it("should output nodot number") {
                    numberKeyboard.type = .NoDot
                    
                    var old = "0"
                    var new = "01"
                    var (final, _) = numberKeyboard.matchInputDel(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("01"))
                    
                    old = "0"
                    new = "00"
                    (final, _) = numberKeyboard.matchInputDel(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("00"))
                    
                    old = "1"
                    new = "01"
                    (final, _) = numberKeyboard.matchInputDel(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("01"))
                    
                    //未完待续
                }
            }
            
        }
    
        describe("matchInputDel") {
            context("") {
    
                it("") {
    
                }
            }
        }
    
    }

}
