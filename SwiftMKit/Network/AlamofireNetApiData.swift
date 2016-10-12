//
//  AlamofireNetApiData.swift
//  SwiftMKitDemo
//
//  Created by Mao on 12/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import ReactiveCocoa
import CocoaLumberjack
import Alamofire

extension Response {
    func toNetApiResponse<T, U: ErrorType>() -> NetApiResponse<T, U> {
        var apiResult: NetApiResult<T, U>?
        switch result {
        case .Success(let value):
            apiResult = NetApiResult.Success(value as! T)
        case .Failure(let error):
            apiResult = NetApiResult.Failure(error as! U)
        }
        return NetApiResponse<T, U>(request: request, response: response, data: data, result: apiResult!)
    }
}

public class AlamofireNetApiData: NetApiData {
    
    public func transferParameterEncoding() -> ParameterEncoding { return Alamofire.ParameterEncoding.URL }
    public override func transferURLRequest(request:NSMutableURLRequest) -> NSMutableURLRequest {
        let encoding = transferParameterEncoding()
        let mutableURLRequest = encoding.encode(request, parameters: query).0
        return mutableURLRequest
    }
    
    // MARK: Request
    public override func requestJSON() -> SignalProducer<NetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = NetApiData.getURLRequest(self)
            let request = Alamofire.request(urlRequest)
            self.request = request
            self.indicator?.bindTask(request.task)
            let timeBegin = NSDate()
            request.responseJSON { [weak self] response in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
                DDLogWarn("请求耗时: \(NSDate().timeIntervalSinceDate(timeBegin).secondsToHHmmssString())")
                let transferedResponse = wself.transferResponseJSON(response.toNetApiResponse())
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("请求成功: \(wself.url)")
                    if let value = transferedResponse.result.value {
                        DDLogVerbose("JSON: \(value)")
                        wself.response = value
                        wself.fillJSON(value)
                        sink.sendNext(wself)
                        sink.sendCompleted()
                        return
                    }
                case .Failure(let error):
                    if let statusCode = StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("请求取消: \(wself.url)")
                            sink.sendInterrupted()
                            return
                        default:
                            break
                        }
                    }
                    DDLogError("请求失败: \(wself.url)")
                    DDLogError("\(error)")
                    
                    let err = error is NetError ? error as! NetError : NetError(error: error)
                    sink.sendFailed(err)
                }
            }
            disposable.addDisposable { [weak self] in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
            }
        }
    }
    public override func requestData() -> SignalProducer<NetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = NetApiData.getURLRequest(self)
            let request = Alamofire.request(urlRequest)
            self.request = request
            self.indicator?.bindTask(request.task)
            let timeBegin = NSDate()
            request.responseData { [weak self] response in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
                DDLogWarn("请求耗时: \(NSDate().timeIntervalSinceDate(timeBegin).secondsToHHmmssString())")
                let transferedResponse = wself.transferResponseData(response.toNetApiResponse())
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("请求成功: \(wself.url)")
                    if let value = transferedResponse.result.value {
                        DDLogVerbose("Data: \(value.length) bytes")
                        wself.response = value
                        wself.fillJSON(value)
                        sink.sendNext(wself)
                        sink.sendCompleted()
                        return
                    }
                case .Failure(let error):
                    if let statusCode = StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("请求取消: \(wself.url)")
                            sink.sendInterrupted()
                            return
                        default:
                            break
                        }
                    }
                    DDLogError("请求失败: \(wself.url)")
                    DDLogError("\(error)")
                    
                    let err = error is NetError ? error as! NetError : NetError(error: error)
                    sink.sendFailed(err)
                }
            }
            disposable.addDisposable { [weak self] in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
            }
        }
    }
    
    
    public override func requestString() -> SignalProducer<NetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = NetApiData.getURLRequest(self)
            let request = Alamofire.request(urlRequest)
            self.request = request
            self.indicator?.bindTask(request.task)
            let timeBegin = NSDate()
            request.responseString { [weak self] response in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
                DDLogWarn("请求耗时: \(NSDate().timeIntervalSinceDate(timeBegin).secondsToHHmmssString())")
                let transferedResponse = wself.transferResponseString(response.toNetApiResponse())
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("请求成功: \(wself.url)")
                    if let value = transferedResponse.result.value {
                        DDLogVerbose("String: \(transferedResponse.result.value)")
                        wself.response = value
                        wself.fillJSON(value)
                        sink.sendNext(wself)
                        sink.sendCompleted()
                        return
                    }
                case .Failure(let error):
                    if let statusCode = StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("请求取消: \(wself.url)")
                            sink.sendInterrupted()
                            return
                        default:
                            break
                        }
                    }
                    DDLogError("请求失败: \(wself.url)")
                    DDLogError("\(error)")
                    
                    let err = error is NetError ? error as! NetError : NetError(error: error)
                    sink.sendFailed(err)
                }
            }
            disposable.addDisposable { [weak self] in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
            }
        }
    }
    
    public override func requestUpload() -> SignalProducer<UploadNetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = NetApiData.getURLRequest(self)
            let request = Alamofire.request(urlRequest)
            self.request = request
            self.indicator?.bindTask(request.task)
            let timeBegin = NSDate()
            request.responseJSON { [weak self] response in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
                DDLogWarn("请求耗时: \(NSDate().timeIntervalSinceDate(timeBegin).secondsToHHmmssString())")
                let transferedResponse = wself.transferResponseJSON(response.toNetApiResponse())
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("请求成功: \(wself.url)")
                    if let value = transferedResponse.result.value {
                        DDLogVerbose("JSON: \(value)")
                        wself.response = value
                        wself.fillJSON(value)
                        sink.sendNext(wself as! UploadNetApiProtocol)
                        sink.sendCompleted()
                        return
                    }
                case .Failure(let error):
                    if let statusCode = StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("请求取消: \(wself.url)")
                            sink.sendInterrupted()
                            return
                        default:
                            break
                        }
                    }
                    DDLogError("请求失败: \(wself.url)")
                    DDLogError("\(error)")
                    
                    let err = error is NetError ? error as! NetError : NetError(error: error)
                    sink.sendFailed(err)
                }
            }
            disposable.addDisposable { [weak self] in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
            }
        }
    }

}