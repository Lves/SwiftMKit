//
//  NetApiData.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/8/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Alamofire
import CocoaLumberjack
import SwiftyJSON

public class NetApiData: NSObject {
    
    static let sharedInstance = NetApiData()
    private override init() {
        self.apiClient = NetApiClient()
        super.init()
    }
    
    struct NetApiDataConst {
        static let DefaultTimeoutInterval: NSTimeInterval = 45
    }
    
    public var apiClient:NetApiClient
    public var apiQuery = [String:AnyObject]()
    public var apiMethod: Alamofire.Method = .GET
    public var apiUrl = ""
    public var apiTimeout = NetApiDataConst.DefaultTimeoutInterval
    public var request:Request?
    public var responseJSONData:JSON?
    
    lazy private var runningApis = [NetApiData]()
    
    public init(client: NetApiClient, url: String, query: [String:AnyObject] = [String:AnyObject](), method: Alamofire.Method = .GET) {
        self.apiClient = client
        self.apiUrl = url
        self.apiQuery = query
        self.apiMethod = method;
        super.init()
    }
    
    public func fill(json:JSON) {
        //Need to complete
    }
    
    public func baseUrl() -> String {
        return ""
    }
    public func baseQuery() -> [String:AnyObject] {
        return [String:AnyObject]()
    }
    
    // MARK: RunningApi
    
    class public func requestingApis() -> Array<NetApiData> {
        return sharedInstance.runningApis
    }
    class public func addApi(api: NetApiData) {
        sharedInstance.runningApis.append(api)
        DDLogInfo("[Api++ \(api)]:Running api count is \(sharedInstance.runningApis.count)")
    }
    class public func removeApi(api: NetApiData) {
        sharedInstance.runningApis.append(api)
        DDLogInfo("[Api-- \(api)]:Running api count is \(sharedInstance.runningApis.count)")
    }
    
    // MARK: JSON
    
    class public func getArrayFromJson<T: NSObject>(json: AnyObject) -> Array<T>{
        let arr = T.mj_objectArrayWithKeyValuesArray(json)
        return arr as NSArray as! [T]
    }
    class public func getObjectFromJson<T: NSObject>(json: AnyObject) -> T{
        let obj = T.mj_objectWithKeyValues(json)
        return obj as NSObject as! T
    }
    
    // MARK: Request
    
    public func requestJSON() -> SignalProducer<NetApiData, NSError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = self.getURLRequest()
            let request = self.apiClient.requestJSON(urlRequest) { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DDLogVerbose("JSON: \(json)")
                        self.responseJSONData = json
                        self.fill(json)
                        sink.sendNext(self)
                        sink.sendCompleted()
                    }
                case .Failure(let error):
                    DDLogError("\(error)")
                    sink.sendFailed(error)
                }
                NetApiData.removeApi(self)
            }
            self.request = request
        }
    }
    
    public func transferURLRequest(request:NSMutableURLRequest) -> NSMutableURLRequest{
        return request
    }
    
    private func getURLRequest() -> NSURLRequest {
        let (method, path, parameters) = (self.apiMethod, self.apiUrl, self.getQuery())
        let URL = NSURL(string: self.baseUrl())!
        var mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest = transferURLRequest(mutableURLRequest)
        DDLogInfo("Request Url: \(mutableURLRequest.URL?.absoluteString)")
        let encoding = Alamofire.ParameterEncoding.URL
        return encoding.encode(mutableURLRequest, parameters: parameters).0
    }
    private func getQuery() -> [String: AnyObject] {
        var query = self.baseQuery()
        for (key, value) in self.apiQuery {
            query[key] = value
        }
        return query
    }
}
