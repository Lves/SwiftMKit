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
    
    

//    override func spec() {
//        describe("clear cache"){
//            let cachePool: CachePoolProtocol = CachePool()
//            context("clear will be success"){
//                let isCleared = cachePool.clear()
//                it("return true"){
//                    expect(isCleared).to(beTrue())
//                }
//                it("cache size should be equal to capacity"){
//                    expect(cachePool.size).to(equal(0))
//                }
//            }
//        }
//
//        describe("cache model"){
//            let cachePool: CachePoolProtocol = CachePool()
//            context("cache model should work"){
//                it("must work") {
//                    cachePool.clear()
//                    let fileName = "icon_user_head"
//                    let image = UIImage(named: fileName)
//                    //image should exist
//                    expect(image).toNot(beNil())
//                    
//                    let sizeBeforeCache = cachePool.size
//                    let key = (cachePool.addCache(image!, name: fileName))
//                    //key should exist
//                    expect(key).toNot(beNil())
//                    
//                    sleep(1)
//                    
//                    let cachedImage = (cachePool.getCache(key)) as? UIImage
//                    //cached image should equal to image
//                    expect(cachedImage).toNot(beNil())
//                    
//                    let sizeAfterCache = cachePool.size
//                    
//                    var all = cachePool.all()
//                    //all should have 1 model
//                    expect(all).notTo(beNil())
//                    expect(all?.count).to(equal(1))
//                    
//                    let model = all?.first
//                    //cache size should be right
//                    expect(model?.size).to(equal(sizeAfterCache-sizeBeforeCache))
//                    
//                    
//                    cachePool.clear()
//                    all = cachePool.all()
//                    //all should have 0 model
//                    expect(all).notTo(beNil())
//                    expect(all?.count).to(equal(0))
//                }
//                
//            }
//        }
//
//        describe("normal cache") {
//            let cachePool: CachePoolProtocol = CachePool()
//            beforeEach {
//                cachePool.clear()
//            }
//            afterEach {
//                cachePool.clear()
//            }
//            
//            context("cache image") {
//                it(""){
//                    let fileName = "icon_user_head"
//                    let image = UIImage(named: fileName)
//                    //image should exist
//                    expect(image).toNot(beNil())
//                    
//                    
//                    let sizeBeforeCache = cachePool.size
//                    let key = (cachePool.addCache(image!, name: fileName))
//                    //key should exist
//                    expect(key).toNot(beNil())
//                    
//                    
//                    let sizeAfterCache = cachePool.size
//                    //cache size will be larger
//                    expect(sizeBeforeCache).to(beLessThan(sizeAfterCache))
//                    
//                    //cache size is less than capacity
//                    expect(cachePool.size).to(beLessThanOrEqualTo(cachePool.capacity))
//                    
//                    sleep(1)
//                    let cachedImage = (cachePool.getCache(key)) as? UIImage
//                    //cached image should equal to image
//                    expect(cachedImage).toNot(beNil())
//                    
//                    
//                    let isRemoved = cachePool.removeCache(key)
//                    //image should be removed successfully
//                    expect(isRemoved).to(beTrue())
//                    
//                    
//                    let sizeAfterRemoved = cachePool.size
//                    //cache size should be recovered
//                    expect(sizeBeforeCache).to(equal(sizeAfterRemoved))
//                    
//                    //cache size is less than capacity
//                    expect(cachePool.size).to(beLessThanOrEqualTo(cachePool.capacity))
//                    
//                    
//                    let object = (cachePool.getCache(key))
//                    //cached image should be nil
//                    expect(object).to(beNil())
//                }
//            }
//            
//            
//            context("cache nsdata") {
//                let cachePool: CachePoolProtocol = CachePool()
//                let fileName = "icon_user_head"
//                let data = UIImage(named: fileName)?.asData()
//                it("data should exist") {
//                    expect(data).toNot(beNil())
//                }
//                
//                let sizeBeforeCache = cachePool.size
//                let key = (cachePool.addCache(data!, name: fileName))
//                it("key should exist") {
//                    expect(key).toNot(beNil())
//                }
//                
//                let sizeAfterCache = cachePool.size
//                it("cache size will be larger"){
//                    expect(sizeBeforeCache).to(beLessThan(sizeAfterCache))
//                }
//                it("cache size is less than capacity"){
//                    expect(cachePool.size).to(beLessThanOrEqualTo(cachePool.capacity))
//                }
//                
//                sleep(1)
//                let cachedData = (cachePool.getCache(key)) as? NSData
//                it("cached image should equal to image") {
//                    expect(cachedData).toNot(beNil())
//                }
//                
//                let isRemoved = cachePool.removeCache(key)
//                it("data should be removed successfully"){
//                    expect(isRemoved).to(beTrue())
//                }
//                
//                let sizeAfterRemoved = cachePool.size
//                it("cache size should be recovered"){
//                    expect(sizeBeforeCache).to(equal(sizeAfterRemoved))
//                }
//                it("cache size is less than capacity"){
//                    expect(cachePool.size).to(beLessThanOrEqualTo(cachePool.capacity))
//                }
//                
//                let object = (cachePool.getCache(key))
//                it("cached data should be nil") {
//                    expect(object).to(beNil())
//                }
//            }
//            
//            context("cache file") {
//                it("") {
//                    let filePath = NSBundle.mainBundle().pathForResource("testhaha", ofType: "jpg")
//                    let fileName = " "
//                    //path should exist
//                    expect(filePath).toNot(beNil())
//                    
//                    
//                    let fileUrl = NSURL(fileURLWithPath: filePath!)
//                    
//                    //URL should exist
//                    expect(fileUrl).toNot(beNil())
//                    
//                    
//                    let sizeBeforeCache = cachePool.size
//                    let key = cachePool.addCache(fileUrl, name: fileName)
//                    //key should exist
//                    expect(key).toNot(beNil())
//                    
//                    sleep(1)
//                    let cachedfile = UIImage(data: (cachePool.getCache(key) as! NSData))
//                    //cached file should equal to file
//                    expect(cachedfile).toNot(beNil())
//                    
//                    
//                    let sizeAfterCache = cachePool.size
//                    //cache size will be larger")
//                    expect(sizeBeforeCache).to(beLessThan(sizeAfterCache))
//                    
//                    //cache size is less than capacity
//                    expect(cachePool.size).to(beLessThanOrEqualTo(cachePool.capacity))
//                    
//                    
//                    let isRemoved = cachePool.removeCache(key)
//                    //file should be removed successfully
//                    expect(isRemoved).to(beTrue())
//                    
//                    let sizeAfterRemoved = cachePool.size
//                    //cache size should be recovered
//                    expect(sizeBeforeCache).to(equal(sizeAfterRemoved))
//                    
//                    //cache size is less than capacity
//                    expect(cachePool.size).to(beLessThanOrEqualTo(cachePool.capacity))
//                    
//                    let object = (cachePool.getCache(key))
//                    //cached data should be nil
//                    expect(object).to(beNil())
//                }
//            }
//
//            
//        }
//
//        describe("edge cache") {
//            var cachePool: CachePoolProtocol = CachePool()
//            beforeEach {
//                cachePool.clear()
//            }
//            afterEach {
//                cachePool.clear()
//            }
//            context("cache size only match 1") {
//                it("must work"){
//                    let fileName = "icon_user_head"
//                    let image = UIImage(named: fileName)
//                    //image should exist
//                    expect(image).toNot(beNil())
//                    
//                    let sizeBeforeCache = cachePool.size
//                    let key = (cachePool.addCache(image!, name: fileName))
//                    //key should exist
//                    expect(key).toNot(beNil())
//                    
//                    let sizeAfterCache = cachePool.size
//                    let sizeOfImage = sizeAfterCache - sizeBeforeCache
//                    
//                    cachePool.clear()
//                    cachePool.capacity = sizeOfImage * 1
//                    
//                    let key1 = (cachePool.addCache(image!, name: fileName + "1"))
//                    //key1 should exist
//                    expect(key1).toNot(beNil())
//                    
//                    sleep(1)
//                    var cachedImage1 = (cachePool.getCache(key1)) as? UIImage
//                    //cached image 1 should equal to image
//                    expect(cachedImage1).notTo(beNil())
//                    
//                    //cache size is less than capacity
//                    expect(cachePool.size).to(beLessThanOrEqualTo(cachePool.capacity))
//                    
//                    let key2 = (cachePool.addCache(image!, name: fileName + "2"))
//                    //key2 should exist
//                    expect(key2).toNot(beNil())
//                    
//                    sleep(1)
//                    let cachedImage2 = (cachePool.getCache(key2)) as? UIImage
//                    //cached image 2 should equal to image
//                    expect(cachedImage2).notTo(beNil())
//                    
//                    //cache size is less than capacity
//                    expect(cachePool.size).to(beLessThanOrEqualTo(cachePool.capacity))
//                    
//                    cachedImage1 = (cachePool.getCache(key1)) as? UIImage
//                    //cached image 1 should be nil
//                    expect(cachedImage1).to(beNil())
//                }
//            
//            }
//        
//            context("cache size match many objects") {
//                it("must work"){
//                    let fileName = "icon_user_head"
//                    let cacheCount = 10
//                    let image = UIImage(named: fileName)
//                    //image should exist
//                    expect(image).toNot(beNil())
//                    
//                    let sizeBeforeCache = cachePool.size
//                    let key = (cachePool.addCache(image!, name: fileName))
//                    //key should exist
//                    expect(key).toNot(beNil())
//                    
//                    let sizeAfterCache = cachePool.size
//                    let sizeOfImage = sizeAfterCache - sizeBeforeCache
//                    
//                    cachePool.clear()
//                    cachePool.capacity = sizeOfImage * Int64(cacheCount)
//                    
//                    for i in 0..<cacheCount*2 {
//                        let key1 = (cachePool.addCache(image!, name: fileName + i.toString))
//                        //key(i) should exist") {
//                        expect(key1).toNot(beNil())
//                        
//                        sleep(1)
//                        let cachedImage1 = (cachePool.getCache(key1)) as? UIImage
//                        //cached image \(i) should equal to image
//                        expect(cachedImage1).notTo(beNil())
//                        
//                        //cache size is less than capacity
//                        expect(cachePool.size).to(beLessThanOrEqualTo(cachePool.capacity))
//                    }
//                }
//                
//            }
//        }
// 
//    }
    

}
