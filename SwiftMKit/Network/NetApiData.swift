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
import ObjectMapper


public class NetApiData: NSObject {
    
    public struct NetApiDataConst {
        static let DefaultTimeoutInterval: NSTimeInterval = 45
    }
    
    public var api: NetApiProtocol?
    
    lazy private var runningApis = [NetApiData]()
    
    private static let sharedInstance = NetApiData()
    private override init() {
        super.init()
    }
    
    public init(api: NetApiProtocol) {
        self.api = api
        super.init()
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
        if let index = sharedInstance.runningApis.indexOf(api) {
            sharedInstance.runningApis.removeAtIndex(index)
        }
        DDLogInfo("[Api-- \(api)]:Running api count is \(sharedInstance.runningApis.count)")
    }
    
    // MARK: JSON
    
    class public func getArrayFromJson<T: Mappable>(json: Array<AnyObject>?) -> Array<T>?{
        if let jsonString = json {
            var arr = [T]()
            for item in jsonString {
                let obj = Mapper<T>().map(item)
                if let model = obj {
                    arr.append(model)
                }
            }
            return arr
        }
        return nil
    }
    class public func getObjectFromJson<T: Mappable>(json: AnyObject?) -> T?{
        if let jsonString = json {
            let obj = Mapper<T>().map(jsonString)
            return obj
        }
        return nil
    }
    
    // MARK: Request
    
    public func requestJSON() -> SignalProducer<NetApiProtocol, NSError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = self.getURLRequest()
            let request = NetApiClient.requestJSON(urlRequest, api:self.api!) { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        self.api!.responseJSONData = value
                        self.api!.fillJSON(value)
                        sink.sendNext(self.api!)
                        sink.sendCompleted()
                    }
                case .Failure(let error):
                    DDLogError("\(error)")
                    sink.sendFailed(error)
                }
                NetApiData.removeApi(self)
            }
            self.api!.request = request
        }
    }
    
    private func getURLRequest() -> NSURLRequest {
        let (method, path, parameters) = (self.api!.method ?? .GET, self.api!.url ?? "", self.api!.query ?? [:])
        let url = NSURL(string: path)!
        var mutableURLRequest = NSMutableURLRequest(URL: url)
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.timeoutInterval = self.api!.timeout ?? NetApiDataConst.DefaultTimeoutInterval
        mutableURLRequest = self.api!.transferURLRequest(mutableURLRequest)
        DDLogInfo("Request Url: \(mutableURLRequest.URL?.absoluteString)")
        let encoding = Alamofire.ParameterEncoding.URL
        return encoding.encode(mutableURLRequest, parameters: parameters).0
    }
    
    class public func combineQuery(base: [String: AnyObject]?, append: [String: AnyObject]?) -> [String: AnyObject]? {
        if var queryBase = base {
            if let queryAppend = append {
                for (key, value) in queryAppend {
                    queryBase[key] = value
                }
            }
            return queryBase
        }
        return base
    }
}
