//
//  DictionarySpec.swift
//  SwiftMKitDemo
//
//  Created by Juxin on 5/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import Quick
import Nimble
import Foundation
import EZSwiftExtensions
@testable import SwiftMKitDemo

class DictionarySpec: QuickSpec {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDictionar() {
        
        describe("test dictrionary") {
            
            context("test string:string") {
                var left = [
                    "a": "123",
                    "b": "345",
                    "c": "123"
                ]
                let right = [
                    "a": "1",
                    "c": "2"
                ]
                
                let res = left + right
                it("should notnil") {
                    expect(res).toNot(beNil())
                }
                it("should be refreshed") {
                    expect(res["a"]).to(be(right["a"]))
                    expect(res["b"]).to(be(left["b"]))
                    expect(res["c"]).to(be(right["c"]))
                }
                
                it("should notnil") {
                    expect(res.stringFromHttpParameters()).toNot(beNil())
                }
                it("should equal to 'a=1&b=2'") {
                    expect(res.stringFromHttpParameters()).to(equal("a=1&b=345&c=2"))
                }
                
                let temp = left
                left += right
                it("should notnil") {
                    expect(left).toNot(beNil())
                }
                it("should be refreshed") {
                    expect(left["a"]).to(be(right["a"]))
                    expect(left["b"]).to(be(temp["b"]))
                    expect(left["c"]).to(be(right["c"]))
                }
                
                it("should notnil") {
                    expect(left.stringFromHttpParameters()).toNot(beNil())
                }
                it("should equal to 'a=1&b=2'") {
                    expect(left.stringFromHttpParameters()).to(equal("a=1&b=345&c=2"))
                }
            }
            
            
            
            context("test string:double") {
                var left = [
                    "a": 0.6,
                    "b": 1.2
                ]
                let right = [
                    "c": 1.8,
                    "d": 2.4
                ]
                
                let res = left + right
                it("should notnil") {
                    expect(res).toNot(beNil())
                }
                it("should be refreshed") {
                    expect(res["a"]).to(be(left["a"]))
                    expect(res["b"]).to(be(left["b"]))
                    expect(res["c"]).to(be(right["c"]))
                    expect(res["d"]).to(be(right["d"]))
                }
                
                it("should notnil") {
                    expect(res.stringFromHttpParameters()).toNot(beNil())
                }
                it("should equal to '1=2&2=6&3=9&4=12'") {
                    expect(res.stringFromHttpParameters()).to(equal("1=2&2=6&3=9&4=12"))
                }
                
                let temp = left
                left += right
                it("should notnil") {
                    expect(left).toNot(beNil())
                }
                it("should be refreshed") {
                    expect(left["a"]).to(be(temp["a"]))
                    expect(left["b"]).to(be(temp["b"]))
                    expect(left["c"]).to(be(right["c"]))
                    expect(left["d"]).to(be(right["d"]))
                }
                
              
                it("should notnil") {
                    expect(left.stringFromHttpParameters()).toNot(beNil())
                }
                it("should equal to 'a=0.6&b=1.2&c=1.8&d=2.4'") {
                    expect(left.stringFromHttpParameters()).to(equal("a=0.6&b=1.2&c=1.8&d=2.4"))
                }
            }
            
            
            context("test nil") {
                var left = [String:String]()
                let right = [String:String]()
                
                let res = left + right
                it("should betnil") {
                    expect(res).to(beNil())
                }
                
                it("should benil") {
                    expect(res.stringFromHttpParameters()).to(beNil())
                }
                it("should equal to ''") {
                    expect(res.stringFromHttpParameters()).to(equal(""))
                }
                
                
                left += right
                it("should benil") {
                    expect(left).to(beNil())
                }
                it("should equal to ''") {
                    expect(left.stringFromHttpParameters()).to(equal(""))
                }
            }

        }
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
