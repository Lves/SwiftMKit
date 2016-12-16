//
//  AlamofireNetApiData.swift
//  SwiftMKitDemo
//
//  Created by Mao on 12/10/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import CocoaLumberjack
import Alamofire

extension DataResponse {
    func toNetApiResponse<T, U: Error>() -> NetApiResponse<T, U> {
        var apiResult: NetApiResult<T, U>?
        switch result {
        case .success(let value):
            apiResult = NetApiResult.success(value as! T)
        case .failure(let error):
            apiResult = NetApiResult.failure(error as! U)
        }
        return NetApiResponse<T, U>(request: request, response: response, data: data, result: apiResult!)
    }
}

open class AlamofireNetApiData: NetApiData {
    
    open func transferParameterEncoding() -> ParameterEncoding { return URLEncoding.default }
    open override func transferURLRequest(_ request:URLRequest) -> URLRequest {
        let encoding = transferParameterEncoding()
        let mutableURLRequest = try! encoding.encode(request, with: query)
        return mutableURLRequest
    }
    
    // MARK: Request
    open override func requestJSON() -> SignalProducer<NetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = NetApiData.getURLRequest(self)
            let request = Alamofire.request(urlRequest)
            self.request = request
            self.indicator?.bindTask(request.task!)
            let timeBegin = Date()
            request.responseJSON { [weak self] response in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
                DDLogWarn("请求耗时: \(NSDate().timeIntervalSince(timeBegin).secondsToHHmmssString())")
                let transferedResponse = wself.transferResponseJSON(response.toNetApiResponse())
                switch transferedResponse.result {
                case .success:
                    DDLogInfo("请求成功: \(wself.url)")
                    if let value = transferedResponse.result.value {
                        DDLogVerbose("JSON: \(value)")
                        wself.response = value
                        wself.fillJSON(value)
                        sink.send(value: wself)
                        sink.sendCompleted()
                        return
                    }
                case .failure(let error):
                    if let statusCode = StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .canceled:
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
                    err.response = transferedResponse.response
                    sink.send(error: err)
                }
            }
            disposable.add { [weak self] in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
            }
        }
    }
    open override func requestData() -> SignalProducer<NetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = NetApiData.getURLRequest(self)
            let request = Alamofire.request(urlRequest)
            self.request = request
            self.indicator?.bindTask(request.task!)
            let timeBegin = Date()
            request.responseData { [weak self] response in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
                DDLogWarn("请求耗时: \(NSDate().timeIntervalSince(timeBegin).secondsToHHmmssString())")
                let transferedResponse = wself.transferResponseData(response.toNetApiResponse())
                switch transferedResponse.result {
                case .success:
                    DDLogInfo("请求成功: \(wself.url)")
                    if let value = transferedResponse.result.value {
                        DDLogVerbose("Data: \(value.count) bytes")
                        wself.response = value as AnyObject?
                        wself.fillJSON(value as AnyObject)
                        sink.send(value: wself)
                        sink.sendCompleted()
                        return
                    }
                case .failure(let error):
                    if let statusCode = StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .canceled:
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
                    err.response = transferedResponse.response
                    sink.send(error: err)
                }
            }
            disposable.add { [weak self] in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
            }
        }
    }
    
    
    open override func requestString() -> SignalProducer<NetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let urlRequest = NetApiData.getURLRequest(self)
            let request = Alamofire.request(urlRequest)
            self.request = request
            self.indicator?.bindTask(request.task!)
            let timeBegin = Date()
            request.responseString { [weak self] response in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
                DDLogWarn("请求耗时: \(NSDate().timeIntervalSince(timeBegin).secondsToHHmmssString())")
                let transferedResponse = wself.transferResponseString(response.toNetApiResponse())
                switch transferedResponse.result {
                case .success:
                    DDLogInfo("请求成功: \(wself.url)")
                    if let value = transferedResponse.result.value {
                        DDLogVerbose("String: \(transferedResponse.result.value)")
                        wself.response = value as AnyObject?
                        wself.fillJSON(value as AnyObject)
                        sink.send(value: wself)
                        sink.sendCompleted()
                        return
                    }
                case .failure(let error):
                    if let statusCode = StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .canceled:
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
                    err.response = transferedResponse.response
                    sink.send(error: err)
                }
            }
            disposable.add { [weak self] in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
            }
        }
    }
    
    open override func requestUpload() -> SignalProducer<UploadNetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let wself  = self as! UploadNetApiProtocol
            let uploadData = NetApiClient.createBodyWithParameters(wself.query, filePathKey: wself.uploadDataName, mimetype: wself.uploadDataMimeType ?? "", uploadData: wself.uploadData!)
            let urlRequest = NetApiData.getURLRequest(self)
            let request = Alamofire.upload(data: uploadData, with: urlRequest)
            self.request = request
            self.indicator?.bindTask(request.task)
            let timeBegin = Date()
            request.responseJSON { [weak self] response in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
                DDLogWarn("请求耗时: \(NSDate().timeIntervalSinceDate(timeBegin).secondsToHHmmssString())")
                let transferedResponse = wself.transferResponseJSON(response.toNetApiResponse())
                switch transferedResponse.result {
                case .success:
                    DDLogInfo("请求成功: \(wself.url)")
                    if let value = transferedResponse.result.value {
                        DDLogVerbose("JSON: \(value)")
                        wself.response = value
                        wself.fillJSON(value)
                        sink.sendNext(wself as! UploadNetApiProtocol)
                        sink.sendCompleted()
                        return
                    }
                case .failure(let error):
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
                    err.response = transferedResponse.response
                    sink.sendFailed(err)
                }
            }
            disposable.add { [weak self] in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
            }
        }
    }

}
