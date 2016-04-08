//
//  MKitApiRouter.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/8/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Alamofire
import CocoaLumberjack

public enum PX500ApiRouter: URLRequestConvertible {
    
    static let baseURLString = PX500ApiInfo.apiBaseUrl + "/v1"
    
    case PopularPhotos(Int)
    
    func getRequestProperties () -> (Alamofire.Method, String, Dictionary<String, AnyObject>) {
        switch self {
        case .PopularPhotos (let page):
            let params = ["consumer_key": PX500Config.ConsumerKey,
                          "page": "\(page)",
                          "feature": "popular",
                          "rpp": "50",
                          "include_store": "store_download",
                          "include_states": "votes"]
            
            return (.GET, "/photos", params)
        }
    }
    
    public var URLRequest: NSMutableURLRequest {
        let (method, path, parameters) =  getRequestProperties()
        let URL = NSURL(string: PX500ApiRouter.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        let encoding = Alamofire.ParameterEncoding.URL
        return encoding.encode(mutableURLRequest, parameters: parameters).0
    }
    
}

public enum BaiduApiRouter: URLRequestConvertible {
    
    static let baseURLString = BaiduApiInfo.apiBaseUrl + "/baidunuomi/openapi"
    
    case Cities()
    
    func getRequestProperties () -> (Alamofire.Method, String, Dictionary<String, AnyObject>) {
        switch self {
        case .Cities():
            return (.GET, "/cities", [:])
        }
    }
    
    public var URLRequest: NSMutableURLRequest {
        let (method, path, parameters) =  getRequestProperties()
        let URL = NSURL(string: BaiduApiRouter.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.setValue(BaiduConfig.ApiKey, forHTTPHeaderField: "apikey")
        let encoding = Alamofire.ParameterEncoding.URL
        return encoding.encode(mutableURLRequest, parameters: parameters).0
    }
    
}