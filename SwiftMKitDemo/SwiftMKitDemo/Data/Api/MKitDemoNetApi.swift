//
//  MKitDemoNetApi.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Alamofire

class PX500ApiInfo: NSObject {
    static var apiBaseUrl: String {
        get {
            switch NetworkConfig.Evn {
            case .Dev:
                return NetworkConfig.PX500HostDev
            case .Product:
                return NetworkConfig.PX500HostProduct
            }
        }
    }
}
class BuDeJieApiInfo: NSObject {
    static var apiBaseUrl: String = NetworkConfig.BuDeJieHost
}

class PX500NetApi: NetApiAbstract {
    static let baseQuery = ["consumer_key": PX500Config.ConsumerKey]
    private var _query: [String: AnyObject]?
    override var query: [String: AnyObject]? {
        get {
            let result = NetApiData.combineQuery(PX500NetApi.baseQuery, append: _query)
            return result
        }
        set {
            _query = newValue
        }
    }
    static let baseUrl = PX500ApiInfo.apiBaseUrl + "/v1"
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

class BuDeJieNetApi: NetApiAbstract {
    static let baseUrl = BuDeJieApiInfo.apiBaseUrl + "/api"
    private var _url: String?
    override var url: String? {
        get {
            return _url
        }
        set {
            if newValue != nil && newValue!.hasPrefix("http") {
                _url = NSURL(string: newValue!)?.absoluteString
            }else{
                _url =  NSURL(string: BuDeJieNetApi.baseUrl)?.URLByAppendingPathComponent(newValue ?? "").absoluteString
            }
        }
    }
}

class PX500PopularPhotosApiData: PX500NetApi {
    var photos: [MKDataNetworkRequestPhotoModel]?
    private var page: UInt = 0
    private var number: UInt = 0
    
    init(page: UInt, number: UInt) {
        super.init()
        self.page = page
        self.number = number
        NetworkConfig.Evn = .Product
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
class PX500PopularPhotosCoreDataApiData: PX500PopularPhotosApiData {
    var photosCoreData: [PX500PhotoEntity]?
    override func fillJSON(json: AnyObject) {
        if let dict = json as? [String: AnyObject] {
            if let array = dict["photos"] as? [AnyObject] {
                self.photosCoreData =  NSObject.arrayFromJson(array, page: self.page - 1, number: self.number)
            }
        }
    }
}
class PX500PhotoDetailApiData: PX500NetApi {
    var photo: MKDataNetworkRequestPhotoModel?
    init(photoId: String) {
        super.init()
        NetworkConfig.Evn = .Product
        self.query = [:]
        self.url = "/photos/" + photoId
        self.method = .GET
    }
    override func fillJSON(json: AnyObject) {
        if let dict = json as? [String: AnyObject] {
            self.photo =  NSObject.objectFromJson(dict["photo"])
        }
    }
}


class BuDeJieADApiData: BuDeJieNetApi {
    var ads: [BuDeJieADModel]?
    override init() {
        super.init()
        self.query = ["a": "get_top_promotion",
                      "c": "topic",
                      "client": "iphone",
                      "ver": "4.0"]
        self.url = "/api_open.php"
        self.method = .GET
    }
    override func fillJSON(json: AnyObject) {
        if let dict = json as? [String: AnyObject] {
            print("\(dict)")
            if let array = dict["result"]!["list"] as? [AnyObject] {
                ads =  NSObject.arrayFromJson(array)
            }
        }
    }
}