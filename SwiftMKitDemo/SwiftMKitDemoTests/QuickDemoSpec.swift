//
//  QuickDemoSpec.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import Quick
import Nimble

class QuickDemoSpec: QuickSpec {
    
    override func spec() {
        describe("SimpleString") {
            context("when assigned to 'Hello world'") {
                let greeting = "Hello world"
                it("should exist") {
                    expect(greeting).toNot(beNil())
                }
                it("should equal to 'Hello world'") {
                    expect(greeting).to(equal("Hello world"))
                }
            }
        }
    }
    
}
