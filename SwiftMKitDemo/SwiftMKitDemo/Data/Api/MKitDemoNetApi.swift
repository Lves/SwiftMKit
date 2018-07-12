//
//  MKitDemoNetApi.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import CocoaLumberjack

class PX500NetApi: AlamofireNetApiData {
    static let baseQuery = ["consumer_key": PX500Config.consumerKey]
    fileprivate var _query: [String: Any] = [:]
    override var query: [String: Any] {
        get {
            let result = combineQuery(PX500NetApi.baseQuery, append: _query)
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
        self.method = .get
    }
    override func fill(map: [String : Any]) {
        if let array = map["photos"] as? [Any] {
            self.photos = NSObject.arrayFromJson(array)
        }
    }
}
class PX500PopularPhotosCoreDataApiData: PX500PopularPhotosApiData {
    var photosCoreData: [PX500PhotoEntity]?
    override func fill(map: [String : Any]) {
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
        self.method = .get
    }
    override func fill(map: [String : Any]) {
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
        self.method = .get
    }
    override func fill(map: [String : Any]) {
        print("\(map)")
        if let array = (map["result"] as? [String : Any])?["list"] as? [Any] {
            ads =  NSObject.arrayFromJson(array)
        }
    }
}


class ToutiaoApi: NSObject, RequestApi {
    
    var sessionIdentifier: String { return "ToutiaoRequestHandler" }
    var baseURLString: String { return "https://m.toutiao.com" }
    var baseHeader: [String : Any]? { return nil }
    var timeoutIntervalForRequest: TimeInterval { return 15 }
    var timeoutIntervalForResource: TimeInterval { return 45 }
    var url: String { return "" }
    var method: HTTPMethod { return .get }
    var params: [String: Any]? { return nil }
    var headers: HTTPHeaders? { return nil }
    var error: NetError?
    var requestHandler: RequestHandler? {
        return DMRequestHandler()
    }
    weak var indicator: Indicator?
    
    func setIndicator(_ indicator: Indicator?, view: UIView? = UIViewController.topController?.view, text: String? = nil) -> Self {
        self.indicator = indicator
        self.indicator?.add(api: self, view: view, text: text)
        return self
    }
    var validate: DataRequest.Validation {
        return { request, response, data in
            return DataRequest.ValidationResult.success
        }
    }
    
    func fill(map: [String: Any]) {}
    func fill(array: [Any]) {}
    
    public override init() {
        super.init()
    }
    public convenience init(error: NetError) {
        self.init()
        self.error = error
    }
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(type(of: self)))")
    }
}


struct NewsModel: Codable {
    var title: String
    var abstract: String
    var datetime: String
    var tag: String
    var url: String
    var image_url: String?
    var behot_time: Int
}


class ToutiaoNewsListApi: ToutiaoApi {
    var news: [NewsModel]?
    var start: Int
    var count: Int
    override var url: String {
        
        return "list/?tag=__all__&ac=wap&count=\(count)&format=json_raw&as=A1556B94F4A6B7C&cp=5B4426DB871C2E1&max_behot_time=1531210439&_signature=n-sGNgAAxLognffQdwWJBJ.rBi&i=\(start)"
    }
    init(start: Int, count: Int) {
        self.start = start
        self.count = count
        super.init()
    }
    override func fill(map: [String : Any]) {
        self.news = toModel([NewsModel].self, value: map["data"])
    }
}
