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

    override func spec() {
        describe("clear cache"){
            context("clear will be success"){
                let isCleared = self.cachePool?.clear()
                it("return true"){
                    expect(isCleared).to(beTrue())
                }
                it("cache size should be equal to capacity"){
                    expect(self.cachePool?.size).to(equal(0))
                }
            }
        }

        describe("cache model"){
            context("cache model should work"){
                
                self.cachePool?.clear()
                let fileName = "icon_user_head"
                let image = UIImage(named: fileName)
                it("image should exist") {
                    expect(image).toNot(beNil())
                }
                let sizeBeforeCache = self.cachePool?.size ?? 0
                let key = (self.cachePool?.addCache(image!, name: fileName))
                it("key should exist") {
                    expect(key).toNot(beNil())
                }
                
                let cachedImage = (self.cachePool?.getCache(key!)) as? UIImage
                it("cached image should equal to image") {
                    expect(cachedImage).to(equal(image!))
                }
                let sizeAfterCache = self.cachePool?.size ?? 0
                
                var all = self.cachePool?.all()
                it("all should have 1 model") {
                    expect(all).notTo(beNil())
                    expect(all?.count).to(equal(1))
                }
                let model = all?.first
                it("cache size should be right"){
                    expect(model?.size).to(equal(sizeAfterCache-sizeBeforeCache))
                }
                
                self.cachePool?.clear()
                all = self.cachePool?.all()
                it("all should have 0 model") {
                    expect(all).notTo(beNil())
                    expect(all?.count).to(equal(0))
                }
                
            }
        }

        describe("normal cache") {
            beforeEach {
                self.cachePool?.clear()
            }
            afterEach {
                self.cachePool?.clear()
            }
            
            context("cache image") {
                
                let fileName = "icon_user_head"
                let image = UIImage(named: fileName)
                it("image should exist") {
                    expect(image).toNot(beNil())
                }
                
                let sizeBeforeCache = self.cachePool?.size
                let key = (self.cachePool?.addCache(image!, name: fileName))
                it("key should exist") {
                    expect(key).toNot(beNil())
                }
                
                let sizeAfterCache = self.cachePool?.size
                it("cache size will be larger"){
                    expect((sizeBeforeCache)!).to(beLessThan(sizeAfterCache))
                }
                it("cache size is less than capacity"){
                    expect((self.cachePool?.size)!).to(beLessThanOrEqualTo((self.cachePool?.capacity)!))
                }
                
                let cachedImage = (self.cachePool?.getCache(key!)) as? UIImage
                it("cached image should equal to image") {
                    expect(cachedImage).toNot(beNil())
                }
                
                let isRemoved = self.cachePool?.removeCache(key!)
                it("image should be removed successfully"){
                    expect(isRemoved).to(beTrue())
                }
                
                let sizeAfterRemoved = self.cachePool?.size
                it("cache size should be recovered"){
                    expect((sizeBeforeCache)!).to(equal(sizeAfterRemoved))
                }
                it("cache size is less than capacity"){
                    expect((self.cachePool?.size)!).to(beLessThanOrEqualTo((self.cachePool?.capacity)!))
                }
                
                let object = (self.cachePool?.getCache(key!))
                it("cached image should be nil") {
                    expect(object).to(beNil())
                }
            }
            
            
            context("cache nsdata") {
                
                let fileName = "icon_user_head"
                let data = UIImage(named: fileName)?.asData()
                it("data should exist") {
                    expect(data).toNot(beNil())
                }
                
                let sizeBeforeCache = self.cachePool?.size
                let key = (self.cachePool?.addCache(data!, name: fileName))
                it("key should exist") {
                    expect(key).toNot(beNil())
                }
                
                let sizeAfterCache = self.cachePool?.size
                it("cache size will be larger"){
                    expect((sizeBeforeCache)!).to(beLessThan(sizeAfterCache))
                }
                it("cache size is less than capacity"){
                    expect((self.cachePool?.size)!).to(beLessThanOrEqualTo((self.cachePool?.capacity)!))
                }
                
                let cachedData = (self.cachePool?.getCache(key!)) as? NSData
                it("cached image should equal to image") {
                    expect(cachedData).toNot(beNil())
                }
                
                let isRemoved = self.cachePool?.removeCache(key!)
                it("data should be removed successfully"){
                    expect(isRemoved).to(beTrue())
                }
                
                let sizeAfterRemoved = self.cachePool?.size
                it("cache size should be recovered"){
                    expect((sizeBeforeCache)!).to(equal(sizeAfterRemoved))
                }
                it("cache size is less than capacity"){
                    expect((self.cachePool?.size)!).to(beLessThanOrEqualTo((self.cachePool?.capacity)!))
                }
                
                let object = (self.cachePool?.getCache(key!))
                it("cached data should be nil") {
                    expect(object).to(beNil())
                }
            }
            
            context("cache file") {
                
                let filePath = NSBundle.mainBundle().pathForResource("testhaha", ofType: "jpg")
                let fileName = " "
                it("path should exist") {
                    expect(filePath).toNot(beNil())
                }
                
                let fileUrl = NSURL(fileURLWithPath: filePath!)
            
                it("URL should exist") {
                    expect(fileUrl).toNot(beNil())
                }
                
                let sizeBeforeCache = self.cachePool?.size
                let key = (self.cachePool?.addCache(fileUrl, name: fileName))
                it("key should exist") {
                    expect(key).toNot(beNil())
                }
                
                let cachedfile = (self.cachePool?.getCache(key!)) as? UIImage
                it("cached file should equal to file") {
                    expect(cachedfile).toNot(beNil())
                }
                
                let sizeAfterCache = self.cachePool?.size
                it("cache size will be larger"){
                    expect((sizeBeforeCache)!).to(beLessThan(sizeAfterCache))
                }
                it("cache size is less than capacity"){
                    expect((self.cachePool?.size)!).to(beLessThanOrEqualTo((self.cachePool?.capacity)!))
                }
                
                let isRemoved = self.cachePool?.removeCache(key!)
                it("file should be removed successfully"){
                    expect(isRemoved).to(beTrue())
                }
                let sizeAfterRemoved = self.cachePool?.size
                it("cache size should be recovered"){
                    expect((sizeBeforeCache)!).to(equal(sizeAfterRemoved))
                }
                it("cache size is less than capacity"){
                    expect((self.cachePool?.size)!).to(beLessThanOrEqualTo((self.cachePool?.capacity)!))
                }
                let object = (self.cachePool?.getCache(key!))
                it("cached data should be nil") {
                    expect(object).to(beNil())
                }
            }

            
        }

        describe("edge cache") {
            beforeEach {
                self.cachePool?.clear()
            }
            afterEach {
                self.cachePool?.clear()
            }
            context("cache size only match 1") {
                
                let fileName = "icon_user_head"
                let image = UIImage(named: fileName)
                it("image should exist") {
                    expect(image).toNot(beNil())
                }
                let sizeBeforeCache = self.cachePool?.size ?? 0
                let key = (self.cachePool?.addCache(image!, name: fileName))
                it("key should exist") {
                    expect(key).toNot(beNil())
                }
                let sizeAfterCache = self.cachePool?.size ?? 0
                let sizeOfImage = sizeAfterCache - sizeBeforeCache
                
                self.cachePool?.clear()
                self.cachePool?.capacity = sizeOfImage * 2
                
                let key1 = (self.cachePool?.addCache(image!, name: fileName + "1"))
                it("key1 should exist") {
                    expect(key1).toNot(beNil())
                }
                var cachedImage1 = (self.cachePool?.getCache(key1!)) as? UIImage
                it("cached image 1 should equal to image") {
                    expect(cachedImage1).notTo(beNil())
                }
                it("cache size is less than capacity"){
                    expect((self.cachePool?.size)!).to(beLessThanOrEqualTo((self.cachePool?.capacity)!))
                }
                let key2 = (self.cachePool?.addCache(image!, name: fileName + "2"))
                it("key2 should exist") {
                    expect(key2).toNot(beNil())
                }
                let cachedImage2 = (self.cachePool?.getCache(key2!)) as? UIImage
                it("cached image 2 should equal to image") {
                    expect(cachedImage2).notTo(beNil())
                }
                it("cache size is less than capacity"){
                    expect((self.cachePool?.size)!).to(beLessThanOrEqualTo((self.cachePool?.capacity)!))
                }
                
                cachedImage1 = (self.cachePool?.getCache(key1!)) as? UIImage
                it("cached image 1 should be nil") {
                    expect(cachedImage1).to(beNil())
                }
                
            }
            
            context("cache size match many objects") {
                
                let fileName = "icon_user_head"
                let cacheCount = 10
                let image = UIImage(named: fileName)
                it("image should exist") {
                    expect(image).toNot(beNil())
                }
                let sizeBeforeCache = self.cachePool?.size ?? 0
                let key = (self.cachePool?.addCache(image!, name: fileName))
                it("key should exist") {
                    expect(key).toNot(beNil())
                }
                let sizeAfterCache = self.cachePool?.size ?? 0
                let sizeOfImage = sizeAfterCache - sizeBeforeCache
                
                self.cachePool?.clear()
                self.cachePool?.capacity = sizeOfImage * Int64(cacheCount)
                
                for i in 0..<cacheCount*2 {
                    let key1 = (self.cachePool?.addCache(image!, name: fileName + i.toString))
                    it("key\(i) should exist") {
                        expect(key1).toNot(beNil())
                    }
                    let cachedImage1 = (self.cachePool?.getCache(key1!)) as? UIImage
                    it("cached image \(i) should equal to image") {
                        expect(cachedImage1).notTo(beNil())
                    }
                    it("cache size is less than capacity"){
                        expect((self.cachePool?.size)!).to(beLessThanOrEqualTo((self.cachePool?.capacity)!))
                    }
                }
                
            }
        }
    }
    

}
