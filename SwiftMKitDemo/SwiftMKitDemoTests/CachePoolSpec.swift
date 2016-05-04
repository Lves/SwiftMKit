//
//  CachePoolSpec.swift
//  SwiftMKitDemo
//
//  Created by Juxin on 5/4/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import SwiftMKitDemo

class CachePoolSpec: QuickSpec {
    
    
    override func spec() {
//        var cache: CacheProtocol = CacheProtocol()
        
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
