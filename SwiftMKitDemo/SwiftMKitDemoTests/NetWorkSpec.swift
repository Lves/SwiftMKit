//
//  NetWorkSpec.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/10/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import XCTest
import Quick
import Nimble
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
    
    private struct Constant {
        static let Point = "TestNetworkPoint"
    }
    
    static var Point: Int {
        get {
            return PINDiskCache.sharedCache().objectForKey(Constant.Point) as? Int ?? 0
        }
        set {
            PINDiskCache.sharedCache().setObject(newValue, forKey: Constant.Point)
        }
    }
}

class TestPX500NetApi: NetApiAbstract {
    static let baseQuery = ["consumer_key": TestPX500Config.consumerKey]
    private var _query: [String: AnyObject]?
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
    private var _url: String?
    override var url: String? {
        get {
            return _url
        }
        set {
            if newValue != nil && newValue!.hasPrefix("http") {
                _url = NSURL(string: newValue!)?.absoluteString
            }else{
                _url =  NSURL(string: PX500NetApi.baseUrl)?.URLByAppendingPathComponent(newValue ?? "").absoluteString
            }
        }
    }
}


class TestPX500PhotosApiData: TestPX500NetApi {
    var photos: [TestPhotoModel]?
    private var page: UInt = 0
    private var number: UInt = 0
    
    init(page: UInt, number: UInt) {
        super.init()
        self.page = page
        self.number = number
        self.query = ["page": "\(page)",
                      "feature": "popular",
                      "rpp": "\(number)",
                      "include_store": "store_download",
                      "include_states": "votes"]
        self.url = "/photos"
        self.method = .GET
    }
    override func fillJSON(json: AnyObject) {
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
    
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["photoId":"id",
                "descriptionString":"description",
                "username":"user.fullname",
                "userpic":"user.userpic_url",
                "imageurl":"image_url"]
    }
}

class NetWorkSpec: QuickSpec {
    
    override func spec() {
        describe("") {
            context("api return successfully") {
                it("should get json") {
                    waitUntil(timeout: 100) { done in
                        let signal = TestPX500PhotosApiData(page:1, number:5).signal().on(
                            next: { data in
                                if let photos = data.photos {
                                    expect(photos.count).to(beGreaterThan(0))
                                    expect(photos.first?.photoId?.length).to(beGreaterThan(0))
                                }
                                done()
                            },
                            failed: { error in
                                expect(error).notTo(beNil())
                                done()
                            })
                        signal.start()
                    }
                }
                
            }
            
            context("get api timeout") {
                it("should get nothing") {
                    
                    let api = TestPX500PhotosApiData(page:1, number:5)
                    api.timeout = 0.01
                    waitUntil(timeout: 100) { done in
                        let signal = api.signal().on(
                            next: { data in
                                if let photos = data.photos {
                                    expect(photos.first).to(beNil())
                                }
                                done()
                            },
                            failed: { error in
                                expect(error.message.contains("timed out")).to(beTrue())
                                expect(error.code).to(equal(NSURLErrorTimedOut))
                                done()
                            })
                        signal.start()
                    }
                }
                
            }
        }
    }
}
