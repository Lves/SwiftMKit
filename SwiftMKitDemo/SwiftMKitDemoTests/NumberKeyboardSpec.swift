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
                }
            }
            
            context("nodot type") {
                it("should output nodot number") {
                    numberKeyboard.type = .NoDot
                    
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
                    
                    old = "1"
                    new = "01"
                    (final, _) = numberKeyboard.matchInputNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("01"))
                }
            }
            
        }
    
        describe("matchDeleteNumber") {
            context("normal type") {
                it("should output natrual number") {
                    numberKeyboard.type = .Normal
                    
                    var old = "01"
                    var new = "0"
                    var (final, _) = numberKeyboard.matchDeleteNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0"))
                    
                    old = "01"
                    new = "1"
                    (final, _) = numberKeyboard.matchDeleteNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("1"))
                    
                    old = "0.1"
                    new = ".1"
                    (final, _) = numberKeyboard.matchDeleteNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal(".1"))
                    
                    old = "0.1"
                    new = "0."
                    (final, _) = numberKeyboard.matchDeleteNumber(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("0."))
                }
            }
        }
        
        describe("matchDeleteDot") {
            context("normal type") {
                it("should output natrual number") {
                    numberKeyboard.type = .Normal
                    
                    var old = "0.1"
                    var new = "01"
                    var (final, _) = numberKeyboard.matchDeleteDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("1"))
                    
                    old = "00.1"
                    new = "001"
                    (final, _) = numberKeyboard.matchDeleteDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("1"))
                    
                    old = "01.1"
                    new = "011"
                    (final, _) = numberKeyboard.matchDeleteDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("11"))
                    
                    old = "1.23"
                    new = "123"
                    (final, _) = numberKeyboard.matchDeleteDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("123"))
                    
                    old = "12."
                    new = "12"
                    (final, _) = numberKeyboard.matchDeleteDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("12"))
                    
                    old = ".23"
                    new = "23"
                    (final, _) = numberKeyboard.matchDeleteDot(old, new: new)
                    expect(final).toNot(beNil())
                    expect(final).to(equal("23"))
                }
            }
        }
        
        describe("matchConfirm") {
            context("normal type") {
                it("should output natrual number") {
                    numberKeyboard.type = .Normal
                    
                    var input = "1"
                    var (output) = numberKeyboard.matchConfirm(input)
                    expect(output).toNot(beNil())
                    expect(output).to(equal("1"))
                    
                    input = "0.1"
                    (output) = numberKeyboard.matchConfirm(input)
                    expect(output).toNot(beNil())
                    expect(output).to(equal("0.1"))
                    
                    input = "01"
                    (output) = numberKeyboard.matchConfirm(input)
                    expect(output).toNot(beNil())
                    expect(output).to(equal("1"))
                    
                    input = "00001"
                    (output) = numberKeyboard.matchConfirm(input)
                    expect(output).toNot(beNil())
                    expect(output).to(equal("1"))
                    
                    input = ".1"
                    (output) = numberKeyboard.matchConfirm(input)
                    expect(output).toNot(beNil())
                    expect(output).to(equal("0.1"))
                    
                    input = "00.1"
                    (output) = numberKeyboard.matchConfirm(input)
                    expect(output).toNot(beNil())
                    expect(output).to(equal("0.1"))
                    
                    input = "01.5"
                    (output) = numberKeyboard.matchConfirm(input)
                    expect(output).toNot(beNil())
                    expect(output).to(equal("1.5"))
                    
                    input = "1.50"
                    (output) = numberKeyboard.matchConfirm(input)
                    expect(output).toNot(beNil())
                    expect(output).to(equal("1.5"))
                    
                    input = "1.00"
                    (output) = numberKeyboard.matchConfirm(input)
                    expect(output).toNot(beNil())
                    expect(output).to(equal("1"))
                    
                    input = "0.0"
                    (output) = numberKeyboard.matchConfirm(input)
                    expect(output).toNot(beNil())
                    expect(output).to(equal("0"))
                    
                    input = "0.00000005"
                    (output) = numberKeyboard.matchConfirm(input)
                    expect(output).toNot(beNil())
                    expect(output).to(equal("0.00000005"))
                    
                    input = ""
                    (output) = numberKeyboard.matchConfirm(input)
                    expect(output).toNot(beNil())
                    expect(output).to(equal(""))
                }
            }
        }
        
    }

}
