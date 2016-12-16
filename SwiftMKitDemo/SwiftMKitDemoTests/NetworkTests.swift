//
//  NetworkTests.swift
//  SwiftMKitDemo
//
//  Created by Mao on 6/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import PINCache
import EZSwiftExtensions
@testable import SwiftMKitDemo


struct TestPX500Config {
    static let consumerKey = "zWez4W3tU1uXHH0S5zAVYX0xAh6sm0kpIZpyF1K7"
    static var urlHost: String {
        get {
            switch NetworkConfig.Evn {
            default:
                return "https://api.500px.com"
            }
        }
    }
}

class TestNetworkConfig : NetworkConfig {
    
    fileprivate struct Constant {
        static let Point = "TestNetworkPoint"
    }
    
    static var Point: Int {
        get {
            return PINDiskCache.shared().object(forKey: Constant.Point) as? Int ?? 0
        }
        set {
            PINDiskCache.shared().setObject(newValue as NSCoding, forKey: Constant.Point)
        }
    }
}

class TestPX500NetApi: NetApiAbstract {
    static let baseQuery = ["consumer_key": TestPX500Config.consumerKey]
    fileprivate var _query: [String: AnyObject]?
    override var query: [String: AnyObject]? {
        get {
            let result = NetApiData.combineQuery(TestPX500NetApi.baseQuery, append: _query)
            return result
        }
        set {
            _query = newValue
        }
    }
    static let baseUrl = TestPX500Config.urlHost + "/v1"
    fileprivate var _url: String?
    override var url: String? {
        get {
            return _url
        }
        set {
            if newValue != nil && newValue!.hasPrefix("http") {
                _url = URL(string: newValue!)?.absoluteString
            }else{
                _url =  URL(string: PX500NetApi.baseUrl)?.URLByAppendingPathComponent(newValue ?? "").absoluteString
            }
        }
    }
}


class TestPX500PhotosApiData: TestPX500NetApi {
    var photos: [TestPhotoModel]?
    fileprivate var page: UInt = 0
    fileprivate var number: UInt = 0
    
    init(page: UInt, number: UInt) {
        super.init()
        self.page = page
        self.number = number
        self.query = ["page": "\(page)" as AnyObject,
                      "feature": "popular" as AnyObject,
                      "rpp": "\(number)" as AnyObject,
                      "include_store": "store_download" as AnyObject,
                      "include_states": "votes" as AnyObject]
        self.url = "/photos"
        self.method = .GET
    }
    override func fillJSON(_ json: AnyObject) {
        if let dict = json as? [String: AnyObject] {
            if let array = dict["photos"] as? [AnyObject] {
                self.photos = NSObject.arrayFromJson(array)
            }
        }
    }
}

class TestPhotoModel: NSObject {
    var photoId: String?
    var name: String?
    var username: String?
    var userpic: String?
    var descriptionString: String?
    var imageurl: String?
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable: Any]! {
        return ["photoId":"id",
                "descriptionString":"description",
                "username":"user.fullname",
                "userpic":"user.userpic_url",
                "imageurl":"image_url"]
    }
}

class NetworkTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testApiSuccessfully() {
//        let expectation = self.expectationWithDescription("should get json")
//        
//        let signal = TestPX500PhotosApiData(page:1, number:5).signal().on(
//            next: { data in
//                if let photos = data.photos {
//                    XCTAssertGreaterThan(photos.count, 0)
//                    XCTAssertGreaterThan(photos.first?.photoId?.length ?? 0, 0)
//                }
//                expectation.fulfill()
//            },
//            failed: { error in
//                XCTAssertNotNil(error)
//                expectation.fulfill()
//        })
//        signal.start()
//        self.waitForExpectationsWithTimeout(100, handler: nil)
    }
    
    func testApiTimout() {
        let expectation = self.expectation(description: "should get nothing")
        
        let api = TestPX500PhotosApiData(page:1, number:5)
        api.timeout = 0.01
        let signal = api.signal().on(
            next: { data in
                XCTAssertNil(data.photos?.first)
                expectation.fulfill()
            },
            failed: { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error.message.contains("timed out"))
                XCTAssertEqual(error.statusCode, NSURLErrorTimedOut)
                expectation.fulfill()
        })
        signal.start()
        self.waitForExpectations(timeout: 100, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
