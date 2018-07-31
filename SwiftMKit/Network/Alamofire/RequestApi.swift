//
//  RequestApi.swift
//  SwiftMKitDemo
//
//  Created by wei.mao on 2018/7/10.
//  Copyright © 2018年 cdts. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift
import CocoaLumberjack

public protocol RequestIndicator {
    var indicator: Indicator? { get set }
    func setIndicator(_ indicator: Indicator?, view: UIView?, text: String?) -> Self
}
public struct UploadFileModel {
    var data: Data
    var name: String
    var fileName: String
    var mimeType: String
}
public protocol UploadApiProtocol {
    var files: [UploadFileModel]? { get set }
}
public protocol RequestApi: class, RequestIndicator {
    var url: String { get }
    var method: HTTPMethod { get }
    var params: [String: Any]? { get }
    var headers: HTTPHeaders? { get }
    var requestHandler: RequestHandler? { get }
    
    var sessionIdentifier: String { get }
    var baseHeader: [String: Any]? { get }
    var baseURLString: String { get }
    var timeoutIntervalForRequest: TimeInterval { get }
    var timeoutIntervalForResource: TimeInterval { get }
    var responseData: Data? { get set }
    var error: NetError? { get set }
    func fill(data: Any)
    func fill(map: [String: Any])
    func fill(array: [Any])
    
    func adapt(_ result: Result<Any>) -> Result<Any>
    func adapt(_ result: Result<Data>) -> Result<Data>
    func adapt(_ result: Result<String>) -> Result<String>
    
    var validate: DataRequest.Validation { get }
}
public extension RequestApi {
    
    func toModel<T>(_ type: T.Type, value: Any?) -> T? where T : Decodable {
        guard let value = value else { return nil }
        return toModel(type, value: value)
    }
    func toModel<T>(_ type: T.Type, value: Any) -> T? where T : Decodable {
        guard let data = try? JSONSerialization.data(withJSONObject: value) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    func fill(data: Any) {
        if let map = data as? [String: Any] {
            fill(map: map)
        } else if let array = data as? [Any] {
            fill(array: array)
        }
    }
    
    func adapt(_ result: Result<Any>) -> Result<Any> {
        return result
    }
    func adapt(_ result: Result<Data>) -> Result<Data> {
        return result
    }
    func adapt(_ result: Result<String>) -> Result<String> {
        return result
    }
    
}
public extension RequestApi {
    private func getDataRequest() -> DataRequest {
        let requestUrl = try! self.baseURLString.asURL().appendingPathComponent(self.url)
        DDLogInfo("[Api] 请求发起: [\(method.rawValue)] \(requestUrl.absoluteURL.absoluteString)?\(params?.stringFromHttpParameters() ?? "")")
        let sessionManager = ApiClient.getSessionManager(api: self)
        let request = sessionManager.request(requestUrl, method: self.method, parameters: self.params, headers: self.headers)
        if let task = request.task {
            self.indicator?.register(api: self, task: task)
        }
        request.resume()
        return request.validate(self.validate)
    }
    private func handleError(_ error:Error, request: URLRequest? = nil, response: HTTPURLResponse? = nil) -> (NetError, Bool) {
        let error = error as NSError
        if let statusCode = StatusCode(rawValue:error.code) {
            switch(statusCode) {
            case .canceled:
                DDLogWarn("[Api] 请求取消: \(request?.url?.absoluteString ?? "" )")
                let err = NetError(statusCode: NetStatusCode.canceled.rawValue, message: "请求取消")
                self.error = err
                return (err, true)
            default:
                break
            }
        }
        let err = error is NetError ? error as! NetError : NetError(error: error)
        err.response = response
        self.error = err
        DDLogError("[Api] 请求失败: \(request?.url?.absoluteString ?? "" ), 错误: \(err)")
        return (err, false)
    }
    private func requestJson() -> SignalProducer<Self, NetError> {
        ApiClient.add(api: self)
        return SignalProducer { [unowned self] sink, disposable in
            self.getDataRequest().responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                ApiClient.remove(api: strongSelf)
                DDLogInfo("[Api] 请求完成: \(response.request?.url?.absoluteString ?? "" ), 耗时: \(String(format:"%.2f", response.timeline.requestDuration))")
                strongSelf.responseData = response.data
                
                let str:String = response.result.value == nil ? "" :  "\(response.result.value!)"
                DDLogInfo("[Api] 请求结果：Json: \(str.mkStringByReplaceUnicode() ?? "")")//这里需要在项目Bridging-Header头文件中引入#import "NSString+Unicode.h"
                let result = strongSelf.adapt(response.result)
                switch result {
                case .success:
                    if let value = result.value {
//                        DDLogInfo("[Api] 请求成功：Json: \(value)")
                        strongSelf.fill(data: value)
                    } else {
//                        DDLogInfo("[Api] 请求成功")
                    }
                    sink.send(value: strongSelf)
                    sink.sendCompleted()
                    return
                case .failure(let error):
                    let (error, canceled) = strongSelf.handleError(error, request: response.request, response: response.response)
                    if canceled {
                        sink.sendInterrupted()
                    } else {
                        sink.send(error: error)
                    }
                }
            }
            disposable.observeEnded {[weak self] in
                guard let strongSelf = self else { return }
                ApiClient.remove(api: strongSelf)
                
            }
        }
    }
    private func requestData() -> SignalProducer<Self, NetError> {
        ApiClient.add(api: self)
        return SignalProducer { [unowned self] sink,disposable in
            self.getDataRequest().responseData { [weak self] response in
                guard let strongSelf = self else { return }
                ApiClient.remove(api: strongSelf)
                DDLogInfo("[Api] 请求完成: \(response.request?.url?.absoluteString ?? "" ), 耗时: \(String(format:"%.2f", response.timeline.requestDuration))")
                strongSelf.responseData = response.data
                DDLogInfo("[Api] 请求结果：Data: \(response.result.value?.count ?? 0) bytes")
                let result = strongSelf.adapt(response.result)
                switch result {
                case .success:
                    if let value = result.value {
//                        DDLogVerbose("[Api] 请求成功：Data: \(value.count) bytes")
                        strongSelf.fill(data: value)
                    } else {
//                        DDLogVerbose("[Api] 请求成功")
                    }
                    sink.send(value: strongSelf)
                    sink.sendCompleted()
                    return
                case .failure(let error):
                    let (error, canceled) = strongSelf.handleError(error, request: response.request, response: response.response)
                    if canceled {
                        sink.sendInterrupted()
                    } else {
                        sink.send(error: error)
                    }
                }
            }
            disposable.observeEnded { [weak self] in
                guard let strongSelf = self else { return }
                ApiClient.remove(api: strongSelf)
            }
        }
    }
    private func requestString() -> SignalProducer<Self, NetError> {
        ApiClient.add(api: self)
        return SignalProducer { [unowned self] sink,disposable in
            self.getDataRequest().responseString { [weak self] response in
                guard let strongSelf = self else { return }
                ApiClient.remove(api: strongSelf)
                DDLogInfo("[Api] 请求完成: \(response.request?.url?.absoluteString ?? "" ), 耗时: \(String(format:"%.2f", response.timeline.requestDuration))")
                strongSelf.responseData = response.data
                DDLogInfo("[Api] 请求结果：String: \(String(describing: response.result.value))")
                let result = strongSelf.adapt(response.result)
                switch result {
                case .success:
                    if let value = result.value {
//                        DDLogVerbose("[Api] 请求成功：String: \(value)")
                        strongSelf.fill(data: value)
                    } else {
//                        DDLogVerbose("[Api] 请求成功")
                    }
                    sink.send(value: strongSelf)
                    sink.sendCompleted()
                    return
                case .failure(let error):
                    let (error, canceled) = strongSelf.handleError(error, request: response.request, response: response.response)
                    if canceled {
                        sink.sendInterrupted()
                    } else {
                        sink.send(error: error)
                    }
                }
            }
            disposable.observeEnded { [weak self] in
                guard let strongSelf = self else { return }
                ApiClient.remove(api: strongSelf)
            }
        }
    }
    func signal(format:RequestType = .json) -> SignalProducer<Self, NetError> {
        if let err = error {
            return SignalProducer { sink, _ in
                sink.send(error: err)
            }
        }
        switch format {
        case .json:
            return self.requestJson()
        case .data:
            return self.requestData()
        case .string:
            return self.requestString()
        case .upload:
            return self.requestUpload()
        case .uploadMultipart:
            return self.requestUploadMultipart()
        }
        
    }
    
    func get(format:RequestType = .json, _ success: @escaping (Self) -> Void) -> SignalProducer<Self, NetError> {
        return get(format: format, success, error: { error in UIViewController.topController?.showTip(error.message)})
    }
    func get(format:RequestType = .json, _ success: @escaping (Self) -> Void, error: @escaping (NetError) -> Void) -> SignalProducer<Self, NetError> {
        return signal(format: format).on(
            failed: error,
            value: { data in
                success(data)
        })
    }
}


public extension RequestApi {
    
    fileprivate func requestUpload() -> SignalProducer<Self, NetError> {
        ApiClient.add(api: self)
        return SignalProducer { [unowned self] sink,disposable in
            let data = self.createBody(upload: self as! UploadApiProtocol, params: self.params)
            let requestUrl = try! self.baseURLString.asURL().appendingPathComponent(self.url)
            DDLogInfo("[Api] 请求发起: [\(self.method.rawValue)]\(requestUrl.absoluteURL.absoluteString)?\(self.params?.stringFromHttpParameters() ?? "")")
            let sessionManager = ApiClient.getSessionManager(api: self)
            let request = sessionManager.upload(data, to: requestUrl, method: self.method, headers: self.headers)
            if let task = request.task {
                self.indicator?.register(api: self, task: task)
            }
            request.resume()
            request.validate(self.validate).responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                ApiClient.remove(api: strongSelf)
                DDLogInfo("[Api] 请求完成: \(response.request?.url?.absoluteString ?? "" ), 耗时: \(String(format:"%.2f", response.timeline.requestDuration))")
                strongSelf.responseData = response.data
                DDLogInfo("[Api] 请求结果：Json: \(String(describing: response.result.value))")
                let result = strongSelf.adapt(response.result)
                switch result {
                case .success:
                    if let value = result.value {
//                        DDLogVerbose("[Api] 请求成功：Json: \(value)")
                        strongSelf.fill(data: value)
                    } else {
//                        DDLogVerbose("[Api] 请求成功")
                    }
                    sink.send(value: strongSelf)
                    sink.sendCompleted()
                    return
                case .failure(let error):
                    let (error, canceled) = strongSelf.handleError(error, request: response.request, response: response.response)
                    if canceled {
                        sink.sendInterrupted()
                    } else {
                        sink.send(error: error)
                    }
                }
            }
            disposable.observeEnded { [weak self] in
                guard let strongSelf = self else { return }
                ApiClient.remove(api: strongSelf)
            }
        }
    }
    fileprivate func requestUploadMultipart() -> SignalProducer<Self, NetError> {
        ApiClient.add(api: self)
        return SignalProducer { [unowned self] sink,disposable in
            let sessionManager = ApiClient.getSessionManager(api: self)
            sessionManager.startRequestsImmediately = true
            let request = self.getMultipartyUploadRequest()
            let fakeTask = URLSessionTask()
            self.indicator?.register(api: self, task: fakeTask)
            NotificationCenter.default.post(name: Notification.Name.Task.DidResume, object: nil, userInfo: [Notification.Key.Task: fakeTask])
            sessionManager.upload(multipartFormData: { [unowned self] formData in
                self.fillMultipartData(upload:self as! UploadApiProtocol, params: self.params, multipart: formData)
            }, with: request, encodingCompletion: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let uploadRequest, _, _):
                    uploadRequest.validate(strongSelf.validate).responseJSON { [weak self] response in
                        guard let strongSelf = self else { return }
                        ApiClient.remove(api: strongSelf)
                        DDLogInfo("[Api] 请求完成: \(response.request?.url?.absoluteString ?? "" ), 耗时: \(String(format:"%.2f", response.timeline.requestDuration))")
                        strongSelf.responseData = response.data
                        DDLogInfo("[Api] 请求结果：Json: \(String(describing: response.result.value))")
                        let result = strongSelf.adapt(response.result)
                        switch result {
                        case .success:
                            NotificationCenter.default.post(name: Notification.Name.Task.DidComplete, object: nil, userInfo: [Notification.Key.Task: fakeTask])
                            if let value = result.value {
//                                DDLogVerbose("[Api] 请求成功：Json: \(value)")
                                strongSelf.fill(data: value)
                            } else {
//                                DDLogVerbose("[Api] 请求成功")
                            }
                            sink.send(value: strongSelf)
                            sink.sendCompleted()
                            return
                        case .failure(let error):
                            let (error, canceled) = strongSelf.handleError(error, request: response.request, response: response.response)
                            if canceled {
                                NotificationCenter.default.post(name: Notification.Name.Task.DidCancel, object: nil, userInfo: [Notification.Key.Task: fakeTask])
                                sink.sendInterrupted()
                            } else {
                                NotificationCenter.default.post(name: Notification.Name.Task.DidSuspend, object: nil, userInfo: [Notification.Key.Task: fakeTask])
                                sink.send(error: error)
                            }
                        }
                    }
                case .failure(let error):
                    let (error, canceled) = strongSelf.handleError(error, request: request, response: nil)
                    if canceled {
                        NotificationCenter.default.post(name: Notification.Name.Task.DidCancel, object: nil, userInfo: [Notification.Key.Task: fakeTask])
                        sink.sendInterrupted()
                    } else {
                        NotificationCenter.default.post(name: Notification.Name.Task.DidSuspend, object: nil, userInfo: [Notification.Key.Task: fakeTask])
                        sink.send(error: error)
                    }
                }
            })
            disposable.observeEnded { [weak self] in
                NotificationCenter.default.post(name: Notification.Name.Task.DidComplete, object: nil, userInfo: [Notification.Key.Task: fakeTask])
                guard let strongSelf = self else { return }
                ApiClient.remove(api: strongSelf)
            }
        }
    }
    private func getMultipartyUploadRequest() -> URLRequest {
        let requestUrl = try! self.baseURLString.asURL().appendingPathComponent(self.url)
        DDLogInfo("[Api] 请求发起: [\(method.rawValue)]\(requestUrl.absoluteURL.absoluteString)?\(params?.stringFromHttpParameters() ?? "")")
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }
    func createBody(upload: UploadApiProtocol, params: [String: Any]?) -> Data {
        let multipart = MultipartFormData()
        fillMultipartData(upload: upload, params: params, multipart: multipart)
        return try! multipart.encode()
    }
    func fillMultipartData(upload: UploadApiProtocol, params: [String: Any]?, multipart: MultipartFormData) {
        if let params = params {
            for (key, value) in params {
                multipart.append("\(value)".data(using: .utf8, allowLossyConversion: false)!, withName: key)
            }
        }
        if let files = upload.files {
            for file in files {
                multipart.append(file.data, withName: file.name, fileName: file.fileName, mimeType: file.mimeType)
            }
        }
    }
}
