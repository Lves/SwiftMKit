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
    
    var cache = PINCache.shared()
    
    let userNameKey = "username"
    
    var userName: String? {
        get {
            return cache.object(forKey: userNameKey) as? String
        }
        set {
            if let value = newValue {
                cache.setObject(value as NSCoding, forKey: userNameKey)
            }else {
                cache.removeObject(forKey: userNameKey)
            }
        }
    }
    let userAgeKey = "userage"
    var userAge: Int? {
        get {
            return cache.object(forKey: userAgeKey) as? Int
        }
        set {
            if let value = newValue {
                cache.setObject(value as NSCoding, forKey: userAgeKey)
            }else {
                cache.removeObject(forKey: userAgeKey)
            }
        }
    }
    let userInfoKey = "userinfo"
    var userInfo: Dictionary<String,String>? {
        get {
            return cache.object(forKey: userInfoKey) as? Dictionary<String,String>
        }
        set {
            if let value = newValue {
                cache.setObject(value as NSCoding, forKey: userInfoKey)
            }else {
                cache.removeObject(forKey: userInfoKey)
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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
