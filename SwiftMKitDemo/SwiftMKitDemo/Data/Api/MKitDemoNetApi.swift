//
//  MKitDemoNetApi.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Alamofire

class PX500NetApi: AlamofireNetApiData {
    static let baseQuery = ["consumer_key": PX500Config.consumerKey]
    fileprivate var _query: [String: Any] = [:]
    override var query: [String: Any] {
        get {
            let result = NetApiData.combineQuery(PX500NetApi.baseQuery, append: _query)
            return result ?? [:]
        }
        set {
            _query = newValue
        }
    }
    static let baseUrl = PX500Config.urlHost + "/v1"
    fileprivate var _url: String = ""
    override var url: String {
        get {
            return _url
        }
        set {
            if newValue.hasPrefix("http") {
                _url = URL(string: newValue)?.absoluteString ?? ""
            }else{
                _url =  URL(string: PX500NetApi.baseUrl)?.appendingPathComponent(newValue).absoluteString ?? ""
            }
        }
    }
}

class BuDeJieNetApi: AlamofireNetApiData {
    static let baseUrl = BuDeJieConfig.urlHost + "/api"
    fileprivate var _url: String = ""
    override var url: String {
        get {
            return _url
        }
        set {
            if newValue.hasPrefix("http") {
                _url = URL(string: newValue)?.absoluteString ?? ""
            }else{
                _url =  URL(string: BuDeJieNetApi.baseUrl)?.appendingPathComponent(newValue).absoluteString ?? ""
            }
        }
    }
}

class PX500PopularPhotosApiData: PX500NetApi {
    var photos: [PX500PopularPhotoModel]?
    fileprivate var page: UInt = 0
    fileprivate var number: UInt = 0
    
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
    override func fillFrom(map: [String : Any]) {
        if let array = map["photos"] as? [Any] {
            self.photos = NSObject.arrayFromJson(array)
        }
    }
}
class PX500PopularPhotosCoreDataApiData: PX500PopularPhotosApiData {
    var photosCoreData: [PX500PhotoEntity]?
    override func fillFrom(map: [String : Any]) {
        if let array = map["photos"] as? [Any] {
            self.photosCoreData =  NSObject.arrayFromJson(array, page: self.page - 1, number: self.number)
        }
    }
}
class PX500PhotoDetailApiData: PX500NetApi {
    var photo: PX500PopularPhotoModel?
    init(photoId: String) {
        super.init()
        self.query = [:]
        self.url = "/photos/" + photoId
        self.method = .GET
    }
    override func fillFrom(map: [String : Any]) {
        self.photo =  NSObject.objectFromJson(map["photo"])
    }
}



class BuDeJieADApiData: BuDeJieNetApi {
    var ads: [BuDeJieADModel]?
    override init() {
        super.init()
        self.query = ["a": "get_top_promotion" as AnyObject,
                      "c": "topic" as AnyObject,
                      "client": "iphone" as AnyObject,
                      "ver": "4.0" as AnyObject]
        self.url = "/api_open.php"
        self.method = .GET
    }
    override func fillFrom(map: [String : Any]) {
        print("\(map)")
        if let array = (map["result"] as? [String : Any])?["list"] as? [Any] {
            ads =  NSObject.arrayFromJson(array)
        }
    }
}
