//
//  NetApiData.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/8/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CocoaLumberjack
import MJExtension

public struct NetApiDataConst {
    static let DefaultTimeoutInterval: NSTimeInterval = 45
}

public class NetApiData: NSObject, NetApiProtocol {
    
    public var error: NetError?
    public var query: [String: AnyObject] = [:]
    public var method: ApiMethod = .GET
    public var url: String = ""
    public var timeout: NSTimeInterval = NetApiDataConst.DefaultTimeoutInterval
    public var request: AnyObject?
    public var response: AnyObject?
    public var indicator: NetApiIndicator?
    
    public func fillJSON(json: AnyObject) {}
    public func transferURLRequest(request:NSMutableURLRequest) -> NSMutableURLRequest { return request }
    public func transferResponseJSON(response: NetApiResponse<AnyObject, NSError>) -> NetApiResponse<AnyObject, NSError> { return response }
    public func transferResponseData(response: NetApiResponse<NSData, NSError>) -> NetApiResponse<NSData, NSError> { return response }
    public func transferResponseString(response: NetApiResponse<String, NSError>) -> NetApiResponse<String, NSError> { return response }
    public func requestJSON() -> SignalProducer<NetApiProtocol, NetError> { return SignalProducer.empty }
    public func requestData() -> SignalProducer<NetApiProtocol, NetError> { return SignalProducer.empty }
    public func requestString() -> SignalProducer<NetApiProtocol, NetError> { return SignalProducer.empty }
    public func requestUpload() -> SignalProducer<UploadNetApiProtocol, NetError> { return SignalProducer.empty }
    
    private var runningApis = [NetApiData]()
    
    private static let sharedInstance = NetApiData()
    
    public override init() {
        super.init()
    }
    public convenience init(error: NetError) {
        self.init()
        self.error = error
    }
    
    // MARK: RunningApi
    
    class public func requestingApis() -> [NetApiData] {
        return sharedInstance.runningApis
    }
    class public func addApi(api: NetApiData) {
        sharedInstance.runningApis.append(api)
        DDLogDebug("[Api++ \(sharedInstance.runningApis.count)] \(unsafeAddressOf(api))")
    }
    class public func removeApi(api: NetApiData) {
        if let index = sharedInstance.runningApis.indexOf(api) {
            sharedInstance.runningApis.removeAtIndex(index)
            DDLogDebug("[Api-- \(sharedInstance.runningApis.count)] \(unsafeAddressOf(api))")
        }
    }
        
    class internal func getURLRequest(api: NetApiProtocol) -> NSURLRequest {
        let (method, path, parameters) = (api.method ?? .GET, api.url ?? "", api.query ?? [:])
        let url = NSURL(string: path)!
        var mutableURLRequest = NSMutableURLRequest(URL: url)
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.timeoutInterval = api.timeout ?? NetApiDataConst.DefaultTimeoutInterval
        let parameterString = parameters.stringFromHttpParameters()
        DDLogInfo("请求地址: \(method.rawValue) \(mutableURLRequest.URL!.absoluteString)?\(parameterString)")
        mutableURLRequest = api.transferURLRequest(mutableURLRequest)
        return mutableURLRequest
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
