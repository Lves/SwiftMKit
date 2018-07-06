//
//  RequestHandler.swift
//  SwiftMKitDemo
//
//  Created by wei.mao on 2018/7/4.
//  Copyright © 2018年 cdts. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift
import CocoaLumberjack

public enum RequestType {
    case json, data, string, upload, multipartUpload
}

public enum NetStatusCode: Int {
    case `default` = 0
    case success = 200
    case businessSuccess = 2000
    case canceled = -999
    case validateFailed = -99999
    case forceUpgrade = -10000
    case badRequest = 400
    case unAuthorized = 401
    case loginOtherDevice = 403
    case timeOut = 504
}
protocol RequestHandler: RequestAdapter, RequestRetrier {
}
extension RequestHandler {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }

    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        completion(false, 0)
    }
}

protocol RequestApi: class{
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
    func fill(data: Any)
    func fill(map: [String: Any])
    func fill(array: [Any])
    
    func adapt(_ result: Result<Any>) -> Result<Any>
    
    var validate: DataRequest.Validation { get }
}
extension RequestApi {
    
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
}
extension RequestApi {
    
    private func requestJson() -> SignalProducer<Self, NetError> {
        ApiClient.add(api: self)
        return SignalProducer { [unowned self] sink, disposable in
            let requestUrl = try! self.baseURLString.asURL().appendingPathComponent(self.url)
            let sessionManager = ApiClient.getSessionManager(api: self)
            let request = sessionManager.request(requestUrl, method: self.method, parameters: self.params, headers: self.headers)
            request.task?.resume()
            request.validate(self.validate).responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                ApiClient.remove(api: strongSelf)
                DDLogInfo("[Api] 请求完成: \(response.request?.url?.absoluteString ?? "" ), 耗时: \(String(format:"%.2f", response.timeline.requestDuration))")
                let result = strongSelf.adapt(response.result)
                switch result {
                case .success:
                    if let value = result.value {
                        DDLogVerbose("[Api] 请求成功：JSON: \(value)")
                        strongSelf.fill(data: value)
                        sink.send(value: strongSelf)
                        sink.sendCompleted()
                        return
                    }
                case .failure(let error):
                    let error = error as NSError
                    if let statusCode = StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .canceled:
                            DDLogWarn("[Api] 请求取消: \(response.request?.url?.absoluteString ?? "" )")
                            sink.sendInterrupted()
                            return
                        default:
                            break
                        }
                    }
                    let err = error is NetError ? error as! NetError : NetError(error: error)
                    err.response = response.response
                    DDLogError("[Api] 请求失败: \(response.request?.url?.absoluteString ?? "" ), 错误: \(err)")
                    sink.send(error: err)
                }
            }
        }
    }
    func signal(format:RequestType = .json) -> SignalProducer<Self, NetError> {
        switch format {
        case .json:
            return self.requestJson()
        default:
            return SignalProducer { [unowned self] sink, _ in sink.send(value: self) }
        }
        
    }
}
