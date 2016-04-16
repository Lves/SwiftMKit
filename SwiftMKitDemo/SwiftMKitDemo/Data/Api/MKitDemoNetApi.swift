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
    class var apiBaseUrl: String {
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

class BaiduApiInfo: NSObject {
    class var apiBaseUrl: String {
        get {
            switch NetworkConfig.Evn {
            case .Dev:
                return NetworkConfig.BaiduHostDev
            case .Product:
                return NetworkConfig.BaiduHostProduct
            }
        }
    }
}

class PX500NetApi: NetApiProtocol {
    static let baseQuery = [String: AnyObject]()
    private var _query: [String: AnyObject]?
    var query: [String: AnyObject]? {
        get {
            return _query
        }
        set {
            _query = NetApiData.combineQuery(PX500NetApi.baseQuery, append: newValue)
        }
    }
    var method: Alamofire.Method?
    static let baseUrl = PX500ApiInfo.apiBaseUrl + "/v1"
    private var _url: String?
    var url: String? {
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
    var timeout: NSTimeInterval?
    var request:Request?
    var responseData:AnyObject?
    var indicator: IndicatorProtocol?
    
    func fillJSON(json: AnyObject) {
        
    }
    func transferURLRequest(request: NSMutableURLRequest) -> NSMutableURLRequest {
        return request
    }
    func transferResponseData(response: Response<NSData, NSError>) -> Response<NSData, NSError> {
        return response
    }
    func transferResponseString(response: Response<String, NSError>) -> Response<String, NSError> {
        return response
    }
    func transferResponseJSON(response: Response<AnyObject, NSError>) -> Response<AnyObject, NSError> {
        return response
    }
}

class PX500PopularPhotosApiData: PX500NetApi {
    init(page: Int) {
        super.init()
        self.query = ["consumer_key": PX500Config.ConsumerKey,
                      "page": "\(page)",
                      "feature": "popular",
                      "rpp": "50",
                      "include_store": "store_download",
                      "include_states": "votes"]
        self.url = "/photos"
        self.method = .GET
    }
}


class BaiduNetApi: NetApiProtocol {
    static let baseQuery = [String: AnyObject]()
    private var _query: [String: AnyObject]?
    var query: [String: AnyObject]? {
        get {
            return _query
        }
        set {
            _query = NetApiData.combineQuery(PX500NetApi.baseQuery, append: newValue)
        }
    }
    var method: Alamofire.Method?
    static let baseUrl = BaiduApiInfo.apiBaseUrl + "/baidunuomi/openapi"
    private var _url: String?
    var url: String? {
        get {
            return _url
        }
        set {
            if newValue != nil && newValue!.hasPrefix("http") {
                _url = NSURL(string: newValue!)?.absoluteString
            }else{
                _url =  NSURL(string: BaiduNetApi.baseUrl)?.URLByAppendingPathComponent(newValue ?? "").absoluteString
            }
        }
    }
    var timeout: NSTimeInterval?
    var request:Request?
    var responseData:AnyObject?
    var indicator: IndicatorProtocol?
    
    func fillJSON(json: AnyObject) {
        
    }
    func transferURLRequest(request: NSMutableURLRequest) -> NSMutableURLRequest {
        request.setValue(BaiduConfig.ApiKey, forHTTPHeaderField: "apikey")
        return request
    }
    func transferResponseData(response: Response<NSData, NSError>) -> Response<NSData, NSError> {
        return response
    }
    func transferResponseString(response: Response<String, NSError>) -> Response<String, NSError> {
        return response
    }
    func transferResponseJSON(response: Response<AnyObject, NSError>) -> Response<AnyObject, NSError> {
        return response
    }
}

class BaiduCitiesApiData: BaiduNetApi {
    var cities: Array<MKDataNetworkRequestCityModel>?
    override init() {
        super.init()
        self.url = "/cities"
        self.method = .GET
    }
    override func fillJSON(json: AnyObject) {
        if let dict = json as? [String: AnyObject] {
            if let array = dict["cities"] as? [AnyObject] {
                self.cities =  NetApiData.getArrayFromJson(array)
            }
        }
    }
}
class BaiduShopsApiData: BaiduNetApi {
    var shops: Array<MKDataNetworkRequestShopModel>?
    init(cityId: String) {
        super.init()
        self.query = ["city_id":cityId]
        self.url = "/searchshops"
        self.method = .GET
    }
    override func fillJSON(json: AnyObject) {
        if let dict = json as? [String: AnyObject] {
            if let array = dict["data"]?["shops"] as? [AnyObject] {
                self.shops =  NetApiData.getArrayFromJson(array)
            }
        }
    }
}