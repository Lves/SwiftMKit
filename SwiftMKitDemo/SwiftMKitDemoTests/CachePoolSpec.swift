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
    
    
    var cachePool: CachePoolProtocol?

    func testClear() {
        describe("EnouphCache"){
            context("clear will be success"){
                let isClear = self.cachePool?.clear()
                it("return true"){
                    expect(isClear).to(beTrue())
                }
                it("cachesize should be equal to cachecapacity"){
                    expect(self.cachePool?.size).to(equal(self.cachePool?.capacity))
                }
            }
        }
    }
    
    func testEnouphCache() {
        describe("EnouphCache") {
            
            context("imagename is notnil") {
                
                self.cachePool?.clear()
                let fileName = "icon_user_head"
                let inImage = UIImage(named: fileName)!
                it("inimage should exist") {
                    expect(inImage).toNot(beNil())
                }
                
                let uniqueName = (self.cachePool?.addImage(inImage, name: fileName))!
                it("key should exist") {
                    expect(uniqueName).toNot(beNil())
                }
                
                let outImage: UIImage = (self.cachePool?.getImage(uniqueName))!
                it("outimage should equal to inimage") {
                    expect(outImage).to(equal(inImage))
                }
                
                it("cachesize is less than cachecapacity"){
                    expect((self.cachePool?.size)!).to(beLessThan((self.cachePool?.capacity)!))
                }
                
                let isRemoved = self.cachePool?.removeImage(uniqueName)
                it("removeimage should be success"){
                    expect(isRemoved).to(beTrue())
                }
                it("cachesize should be equal to cachecapacity"){
                    expect(self.cachePool?.size).to(equal(self.cachePool?.capacity))
                }
            }
            
            context("imagename is nil") {
                self.cachePool?.clear()
                
                let fileName = ""
                let inImage = UIImage(named: fileName)!
                it("inimage should be nil") {
                    expect(inImage).to(beNil())
                }
                
                let uniqueName = (self.cachePool?.addImage(inImage, name: fileName))!
                it("key should be nil") {
                    expect(uniqueName).to(beNil())
                }
                
                let outImage: UIImage = (self.cachePool?.getImage(uniqueName))!
                it("outimage should be nil") {
                    expect(outImage).to(beNil())
                }
                
                let cacheUsedSize = (self.cachePool?.capacity)! - (self.cachePool?.size)!
                it("filesize should be 0"){
                    expect(cacheUsedSize).to(equal(0))
                }
                it("cachesize should be equal to cachecapacity"){
                    expect(self.cachePool?.size).to(equal(self.cachePool?.capacity))
                }
                
                let isRemoved = self.cachePool?.removeImage(uniqueName)
                it("removeimage should be success"){
                    expect(isRemoved).to(beTrue())
                }
                it("cachesize should be equal to cachecapacity"){
                    expect(self.cachePool?.size).to(equal(self.cachePool?.capacity))
                }
            }
            
            context("NSdataname is notnil") {
                self.cachePool?.clear()
                
                let fileName = "icon_user_head"
                let inData: NSData = (UIImage(named: fileName)!).asData()
                it("indata should exist") {
                    expect(inData).toNot(beNil())
                }
                
                let uniqueName = (self.cachePool?.addData(inData, name: fileName))!
                it("key should exist") {
                    expect(uniqueName).toNot(beNil())
                }
                
                let outData: NSData = (self.cachePool?.getData(uniqueName))!
                it("outdata should equal to indata") {
                    expect(outData).to(equal(inData))
                }
                it("cachesize is less than cachecapacity"){
                    expect((self.cachePool?.size)!).to(beLessThan((self.cachePool?.capacity)!))
                }
                
                let isRemoved = self.cachePool?.removeData(uniqueName)
                it("removedata should be success"){
                    expect(isRemoved).to(beTrue())
                }
                it("cachesize should be equal to cachecapacity"){
                    expect(self.cachePool?.size).to(equal(self.cachePool?.capacity))
                }
            }
            
            context("NSdataname is nil") {
                self.cachePool?.clear()
                
                let fileName = ""
                let inData: NSData = (UIImage(named: fileName)!).asData()
                it("indata should be nil") {
                    expect(inData).to(beNil())
                }
                
                let uniqueName = (self.cachePool?.addData(inData, name: fileName))!
                it("key should be nil") {
                    expect(uniqueName).to(beNil())
                }
                
                let outData: NSData = (self.cachePool?.getData(uniqueName))!
                it("outdata should be nil") {
                    expect(outData).to(beNil())
                }
                it("cachesize should be equal to cachecapacity"){
                    expect(self.cachePool?.size).to(equal(self.cachePool?.capacity))
                }
                
                let isRemoved = self.cachePool?.removeData(uniqueName)
                it("removeimage should be success"){
                    expect(isRemoved).to(beTrue())
                }
                it("cachesize should be equal to cachecapacity"){
                    expect(self.cachePool?.size).to(equal(self.cachePool?.capacity))
                }
            }
        }
    }
    
        func testNotEnouphCache() {
            describe("notEnouphCache") {
                
                
            }
    }

}
