//
//  PINCacheTests.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/29/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import PINCache

class PINCacheTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    var cache = PINCache.sharedCache()
    
    let userNameKey = "username"
    
    var userName: String? {
        get {
            return cache.objectForKey(userNameKey) as? String
        }
        set {
            if let value = newValue {
                cache.setObject(value, forKey: userNameKey)
            }else {
                cache.removeObjectForKey(userNameKey)
            }
        }
    }
    let userAgeKey = "userage"
    var userAge: Int? {
        get {
            return cache.objectForKey(userAgeKey) as? Int
        }
        set {
            if let value = newValue {
                cache.setObject(value, forKey: userAgeKey)
            }else {
                cache.removeObjectForKey(userAgeKey)
            }
        }
    }
    let userInfoKey = "userinfo"
    var userInfo: Dictionary<String,String>? {
        get {
            return cache.objectForKey(userInfoKey) as? Dictionary<String,String>
        }
        set {
            if let value = newValue {
                cache.setObject(value, forKey: userInfoKey)
            }else {
                cache.removeObjectForKey(userInfoKey)
            }
        }
    }

    func testPINCache() {
        userName = nil
        userAge = nil
        userInfo = nil
        XCTAssertEqual(nil, userName)
        userName = "abc"
        XCTAssertEqual("abc", userName)
        userName = nil
        XCTAssertEqual(nil, userName)
        
        XCTAssertEqual(nil, userAge)
        userAge = 1
        XCTAssertEqual(1, userAge)
        userAge = nil
        XCTAssertEqual(nil, userAge)
        
        XCTAssertNil(userInfo)
        userInfo = ["x":"a"]
        XCTAssertEqual("a", userInfo?["x"])
        userInfo = nil
        XCTAssertNil(userAge)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
