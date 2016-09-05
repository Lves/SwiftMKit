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
import MJExtension

public struct NetApiDataConst {
    static let DefaultTimeoutInterval: NSTimeInterval = 45
}

public class NetApiData: NSObject {
    
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
    
    
    // MARK: RunningApi
    
    class public func requestingApis() -> [NetApiData] {
        return sharedInstance.runningApis
    }
    class public func addApi(api: NetApiData) {
        sharedInstance.runningApis.append(api)
        DDLogDebug("[NetApi] [Api++ \(api)]:Running api count is \(sharedInstance.runningApis.count)")
    }
    class public func removeApi(api: NetApiData) {
        if let index = sharedInstance.runningApis.indexOf(api) {
            sharedInstance.runningApis.removeAtIndex(index)
        }
        DDLogDebug("[NetApi] [Api-- \(api)]:Running api count is \(sharedInstance.runningApis.count)")
    }
    
    // MARK: Request
    
    public func requestJSON() -> SignalProducer<NetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = NetApiData.getURLRequest(self.api!)
            NetApiClient.requestJSON(urlRequest, api:self.api!) { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        self.api!.responseData = value
                        self.api!.fillJSON(value)
                        sink.sendNext(self.api!)
                        sink.sendCompleted()
                    }
                case .Failure(let error):
                    let err = error is NetError ? error as! NetError : NetError(error: error)
                    if let statusCode =  StatusCode(rawValue:err.statusCode) {
                        switch(statusCode) {
                        case .Canceled:
                            sink.sendInterrupted()
                            return
                        default:
                            break
                        }
                    }
                    sink.sendFailed(err)
                }
                NetApiData.removeApi(self)
            }
            disposable.addDisposable { [weak self] in
                self?.api?.request?.task.cancel()
            }
        }
    }
    public func requestData() -> SignalProducer<NetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = NetApiData.getURLRequest(self.api!)
            NetApiClient.requestData(urlRequest, api:self.api!) { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        self.api!.responseData = value
                        sink.sendNext(self.api!)
                        sink.sendCompleted()
                    }
                case .Failure(let error):
                    let err = error is NetError ? error as! NetError : NetError(error: error)
                    DDLogError("\(error)")
                    sink.sendFailed(err)
                }
                NetApiData.removeApi(self)
            }
            disposable.addDisposable { [weak self] in
                self?.api?.request?.task.cancel()
            }
        }
    }
    public func requestString() -> SignalProducer<NetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = NetApiData.getURLRequest(self.api!)
            NetApiClient.requestString(urlRequest, api:self.api!) { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        self.api!.responseData = value
                        sink.sendNext(self.api!)
                        sink.sendCompleted()
                    }
                case .Failure(let error):
                    let err = error is NetError ? error as! NetError : NetError(error: error)
                    DDLogError("\(error)")
                    sink.sendFailed(err)
                }
                NetApiData.removeApi(self)
            }
            disposable.addDisposable { [weak self] in
                self?.api?.request?.task.cancel()
            }
        }
    }
    public func requestUpload() -> SignalProducer<UploadNetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = NetApiData.getURLRequest(self.api!)
            NetApiClient.requestUpload(urlRequest, api:(self.api as! UploadNetApiProtocol)) { response in
                switch response.result {
                case .Success:
                    if let value = response.result.value {
                        self.api!.responseData = value
                        self.api!.fillJSON(value)
                        sink.sendNext((self.api as! UploadNetApiProtocol))
                        sink.sendCompleted()
                    }
                case .Failure(let error):
                    let err = error is NetError ? error as! NetError : NetError(error: error)
                    if let statusCode =  StatusCode(rawValue:err.statusCode) {
                        switch(statusCode) {
                        case .Canceled:
                            sink.sendInterrupted()
                            return
                        default:
                            break
                        }
                    }
                    sink.sendFailed(err)
                }
                NetApiData.removeApi(self)
            }
            disposable.addDisposable { [weak self] in
                self?.api?.request?.task.cancel()
            }
        }
    }
    
    class private func getURLRequest(api: NetApiProtocol) -> NSURLRequest {
        let (method, path, parameters) = (api.method ?? .GET, api.url ?? "", api.query ?? [:])
        let url = NSURL(string: path)!
        var mutableURLRequest = NSMutableURLRequest(URL: url)
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.timeoutInterval = api.timeout ?? NetApiDataConst.DefaultTimeoutInterval
        let parameterString = parameters.stringFromHttpParameters()
        DDLogInfo("[NetApi] Request Url: \(method.rawValue) \(mutableURLRequest.URL!.absoluteString)?\(parameterString)")
        let encoding = api.transferParameterEncoding()
        mutableURLRequest = encoding.encode(mutableURLRequest, parameters: parameters).0
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
