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
import ReactiveSwift

public struct NetApiDataConst {
    static let DefaultTimeoutInterval: TimeInterval = 45
}

open class NetApiData: NSObject, NetApiProtocol {
    
    open var error: NetError?
    open var query: [String: Any] = [:]
    open var method: ApiMethod = .GET
    open var url: String = ""
    open var timeout: TimeInterval = NetApiDataConst.DefaultTimeoutInterval
    open var request: Any?
    open var response: Any?
    open var indicator: NetApiIndicator?
    
    open func fillJSON(_ json: AnyObject) {}
    open func transferURLRequest(_ request:URLRequest) -> URLRequest { return request }
    open func transferResponseJSON(_ response: NetApiResponse<AnyObject, NSError>) -> NetApiResponse<AnyObject, NSError> { return response }
    open func transferResponseData(_ response: NetApiResponse<Data, NSError>) -> NetApiResponse<Data, NSError> { return response }
    open func transferResponseString(_ response: NetApiResponse<String, NSError>) -> NetApiResponse<String, NSError> { return response }
    open func requestJSON() -> SignalProducer<NetApiProtocol, NetError> { return SignalProducer.empty }
    open func requestData() -> SignalProducer<NetApiProtocol, NetError> { return SignalProducer.empty }
    open func requestString() -> SignalProducer<NetApiProtocol, NetError> { return SignalProducer.empty }
    open func requestUpload() -> SignalProducer<UploadNetApiProtocol, NetError> { return SignalProducer.empty }
    
    fileprivate var runningApis = [NetApiData]()
    
    fileprivate static let sharedInstance = NetApiData()
    
    public override init() {
        super.init()
    }
    public convenience init(error: NetError) {
        self.init()
        self.error = error
    }
    
    // MARK: RunningApi
    
    class open func requestingApis() -> [NetApiData] {
        return sharedInstance.runningApis
    }
    class open func addApi(_ api: NetApiData) {
        sharedInstance.runningApis.append(api)
        DDLogDebug("[Api++ \(sharedInstance.runningApis.count)] \(Unmanaged.passUnretained(api).toOpaque())")
    }
    class open func removeApi(_ api: NetApiData) {
        if let index = sharedInstance.runningApis.index(of: api) {
            sharedInstance.runningApis.remove(at: index)
            DDLogDebug("[Api-- \(sharedInstance.runningApis.count)] \(Unmanaged.passUnretained(api).toOpaque())")
        }
    }
    
    class internal func getURLRequest(_ api: NetApiProtocol) -> URLRequest {
        let (method, path, parameters) = (api.method , api.url , api.query )
        let url = URL(string: path)!
        var mutableURLRequest = URLRequest(url: url)
        mutableURLRequest.httpMethod = method.rawValue
        mutableURLRequest.timeoutInterval = api.timeout 
        let parameterString = parameters.stringFromHttpParameters()
        DDLogInfo("请求地址: \(method.rawValue) \(mutableURLRequest.url!.absoluteString)?\(parameterString)")
        mutableURLRequest = api.transferURLRequest(mutableURLRequest)
        return mutableURLRequest
    }
    
    class open func combineQuery(_ base: [String: Any]?, append: [String: Any]?) -> [String: Any]? {
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
