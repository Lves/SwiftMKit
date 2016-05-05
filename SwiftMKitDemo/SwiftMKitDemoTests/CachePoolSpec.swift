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
    
    
    func testEnouphCache() {
        describe("EnouphCache test") {
//            let cache: CacheProtocol = CachePool()
            var cache: CacheProtocol?
            
            let fileName = "icon_user_head"
            var uniquename :String?
            
            context("image test") {
                let inimage = UIImage(named: fileName)!
                uniquename = cache?.addObject(fileName, image: inimage)
                let outimage: UIImage = (cache?.objectForName(uniquename!))!
                
                it("uniquename should exist") {
                    expect(uniquename).toNot(beNil())
                }
                it("outimage should equal to inimage") {
                    expect(outimage).to(equal(inimage))
                }
                
            }
            
            context("NSdata test") {
                let indata: NSData = (UIImage(named: fileName)!).asData()
                uniquename = cache?.addObject(fileName, data: indata)
                let outdata: UIImage = (cache?.objectForName(uniquename!))!
                
                
                it("uniquename should exist") {
                    expect(uniquename).toNot(beNil())
                }
                it("outdata should equal to indata") {
                    expect(outdata).to(equal(indata))
                }
            }
        }
        
        describe("notEnouphCache test") {
            context("image test") {
            }
        }
    }

}
