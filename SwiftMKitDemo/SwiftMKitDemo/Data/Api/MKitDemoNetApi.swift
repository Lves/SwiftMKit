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

class PX500NetApi: NetApiProtocol {
    static let baseQuery = [String: AnyObject]()
    private var _query: [String: AnyObject]?
    var query: [String: AnyObject]? {
        get {
            let result = NetApiData.combineQuery(PX500NetApi.baseQuery, append: _query)
            return result
        }
        set {
            _query = newValue
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
    weak var indicator: IndicatorProtocol?
    weak var indicatorList: IndicatorListProtocol?
    
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
    var photos: Array<MKDataNetworkRequestPhotoModel>?
    init(page: UInt, number: UInt) {
        super.init()
        self.query = ["consumer_key": PX500Config.ConsumerKey,
                      "page": "\(page)",
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
                self.photos =  NetApiData.getArrayFromJson(array)
            }
        }
    }
}
class PX500PhotoDetailApiData: PX500NetApi {
    var photo: MKDataNetworkRequestPhotoModel?
    init(photoId: String) {
        super.init()
        self.query = [:]
        self.url = "/photo/" + photoId
        self.method = .GET
    }
    override func fillJSON(json: AnyObject) {
        if let dict = json as? [String: AnyObject] {
            if let array = dict["photo"] as? [AnyObject] {
                self.photo =  NetApiData.getObjectFromJson(array)
            }
        }
    }
}

