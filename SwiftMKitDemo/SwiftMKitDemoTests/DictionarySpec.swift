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

    override func spec() {
        
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
                    expect(res["a"]).to(equal(right["a"]))
                    expect(res["b"]).to(equal(left["b"]))
                    expect(res["c"]).to(equal(right["c"]))
                }
                
                it("should notnil") {
                    expect(res.stringFromHttpParameters()).toNot(beNil())
                }
                it("should equal to 'a=1&b=2'") {
                    let results = res.stringFromHttpParameters().componentsSeparatedByString("&")
                    expect(results).to(contain("a=1","b=345","c=2"))
                }
                
                let temp = left
                left += right
                it("should notnil") {
                    expect(left).toNot(beNil())
                }
                it("should be refreshed") {
                    expect(left["a"]).to(equal(right["a"]))
                    expect(left["b"]).to(equal(temp["b"]))
                    expect(left["c"]).to(equal(right["c"]))
                }
                
                it("should notnil") {
                    expect(left.stringFromHttpParameters()).toNot(beNil())
                }
                it("should equal to 'a=1&b=2'") {
                    let results = res.stringFromHttpParameters().componentsSeparatedByString("&")
                    expect(results).to(contain("a=1","b=345","c=2"))
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
                    expect(res["a"]).to(equal(left["a"]))
                    expect(res["b"]).to(equal(left["b"]))
                    expect(res["c"]).to(equal(right["c"]))
                    expect(res["d"]).to(equal(right["d"]))
                }
                
                it("should notnil") {
                    expect(res.stringFromHttpParameters()).toNot(beNil())
                }
                it("should equal to '1=2&2=6&3=9&4=12'") {
                    let results = res.stringFromHttpParameters().componentsSeparatedByString("&")
                    expect(results).to(contain("a=0.6","b=1.2","c=1.8","d=2.4"))
                }
                
                let temp = left
                left += right
                it("should notnil") {
                    expect(left).toNot(beNil())
                }
                it("should be refreshed") {
                    expect(left["a"]).to(equal(temp["a"]))
                    expect(left["b"]).to(equal(temp["b"]))
                    expect(left["c"]).to(equal(right["c"]))
                    expect(left["d"]).to(equal(right["d"]))
                }
                
              
                it("should notnil") {
                    expect(left.stringFromHttpParameters()).toNot(beNil())
                }
                it("should equal to 'a=0.6&b=1.2&c=1.8&d=2.4'") {
                    let results = res.stringFromHttpParameters().componentsSeparatedByString("&")
                    expect(results).to(contain("a=0.6","b=1.2","c=1.8","d=2.4"))
                }
            }
            
            
            context("test nil") {
                var left = [String:String]()
                let right = [String:String]()
                
                let res = left + right
                it("should be empty") {
                    expect(res).notTo(beNil())
                    expect(res.count).to(be(0))
                }
                
                it("should equal to ''") {
                    expect(res.stringFromHttpParameters()).notTo(beNil())
                    expect(res.stringFromHttpParameters()).to(equal(""))
                }
                
                
                left += right
                it("should be empty") {
                    expect(left).notTo(beNil())
                    expect(left.count).to(be(0))
                }
                it("should equal to ''") {
                    expect(left.stringFromHttpParameters()).to(equal(""))
                }
            }

        }
        
    }

}
