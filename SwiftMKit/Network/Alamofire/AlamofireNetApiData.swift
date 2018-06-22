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
                        wself.response = response.toNetApiResponse()
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
            disposable.observeEnded { [weak self] in
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
                        wself.response = response.toNetApiResponse()
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
            disposable.observeEnded { [weak self] in
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
                        DDLogVerbose("String: \(transferedResponse.result.value ?? "")")
                        wself.response = response.toNetApiResponse()
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
            disposable.observeEnded { [weak self] in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
            }
        }
    }
    
    open override func requestMultipartUpload() -> SignalProducer<MultipartUploadNetApiProtocol, NetError>{
        let urlRequest = NetApiData.getURLRequest(self)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest)
        let timeBegin = Date()
        return SignalProducer { [unowned self] sink,disposable in
            let wself  = self as! MultipartUploadNetApiProtocol
            task.resume()
//            NotificationCenter.default.post(name: Notification.Name.Task.DidResume, object: task)
            NotificationCenter.default.post(
                name: Notification.Name.Task.DidResume,
                object: nil,
                userInfo: [Notification.Key.Task: task]
            )
            self.indicator?.bindTask(task)
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                //参数
                for (key, value) in wself.query {
                    let kk = String(describing: value)
                    let data = kk.data(using: String.Encoding.utf8)!
                    multipartFormData.append(data, withName: key)
                }
                //文件
                if let fileList = wself.fileList{
                    for fileModel in fileList {
                        multipartFormData.append(fileModel.uploadData, withName: fileModel.fileName, fileName: fileModel.fileName, mimeType: fileModel.mimetype)
                    }
                }
            }, with: urlRequest, encodingCompletion: { (encodingResult) in
                task.suspend()
                NotificationCenter.default.post(name: Notification.Name.Task.DidComplete, object: nil,userInfo: [Notification.Key.Task: task])
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON {  [weak self] response in
                        guard let wself = self else { return }
                        NetApiData.removeApi(wself)
                        DDLogWarn("请求耗时: \(NSDate().timeIntervalSince(timeBegin).secondsToHHmmssString())")
                        let transferedResponse = wself.transferResponseJSON(response.toNetApiResponse())
                        switch transferedResponse.result {
                        case .success:
                            DDLogInfo("请求成功: \(wself.url)")
                            if let value = transferedResponse.result.value {
                                DDLogVerbose("JSON: \(value)")
                                wself.response = response.toNetApiResponse()
                                wself.fillJSON(value)
                                task.suspend()
                                NotificationCenter.default.post(name: Notification.Name.Task.DidComplete, object: nil,userInfo: [Notification.Key.Task: task])
                                sink.send(value: wself as! MultipartUploadNetApiProtocol)
                                sink.sendCompleted()
                                return
                            }
                        case .failure(let error):
                            if let statusCode = StatusCode(rawValue:error.code) {
                                switch(statusCode) {
                                case .canceled:
                                    DDLogWarn("请求取消: \(wself.url)")
                                    task.suspend()
                                    NotificationCenter.default.post(name: Notification.Name.Task.DidComplete, object: nil,userInfo: [Notification.Key.Task: task])
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
                            task.suspend()
                            NotificationCenter.default.post(name: Notification.Name.Task.DidComplete, object: nil,userInfo: [Notification.Key.Task: task])
                            sink.send(error: err)
                        }
                    }
                case .failure(let error):
                    DDLogError("请求失败: \(self.url)")
                    DDLogError("\(error)")
                    task.suspend()
                    NotificationCenter.default.post(name: Notification.Name.Task.DidComplete, object: nil,userInfo: [Notification.Key.Task: task])
                    if let err = error as? NetError {
                        sink.send(error: err)
                    } else {
                        sink.send(error: NetError(error: error as NSError))
                    }
                }

                
            })
            disposable.observeEnded { [weak self] in
                task.suspend()
                NotificationCenter.default.post(name: Notification.Name.Task.DidComplete, object: task)
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
            }
        }
        
       
    }
    
    open override func requestUpload() -> SignalProducer<UploadNetApiProtocol, NetError> {
        NetApiData.addApi(self)
        return SignalProducer { [unowned self] sink,disposable in
            let wself  = self as! UploadNetApiProtocol
            let uploadData = NetApiClient.createBody(withParameters: wself.query, filePathKey: wself.uploadDataName, mimetype: wself.uploadDataMimeType ?? "", uploadData: wself.uploadData!)
            let urlRequest = NetApiData.getURLRequest(self)
            let request = Alamofire.upload(uploadData, with: urlRequest)
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
                        wself.response = response.toNetApiResponse()
                        wself.fillJSON(value)
                        sink.send(value: wself as! UploadNetApiProtocol)
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
            disposable.observeEnded { [weak self] in
                guard let wself = self else { return }
                NetApiData.removeApi(wself)
            }
        }
    }

}
