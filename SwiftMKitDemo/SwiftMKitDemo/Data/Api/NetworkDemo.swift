//
//  NetworkDemo.swift
//  SwiftMKitDemo
//
//  Created by wei.mao on 2018/7/3.
//  Copyright © 2018年 cdts. All rights reserved.
//

import Foundation
import Alamofire
import CocoaLumberjack
import ReactiveSwift
import SwiftMKit

public struct NetworkDemo {
}
public struct LoginService {
    static var accessKey: String?
    static var token: String?
    static var username: String?
    
    static func refreshAccessKey(completion: @escaping (Bool) -> Void) -> SignalProducer<LoginTokenApi, NetError> {
        return LoginTokenApi(username: username ?? "", token: token ?? "").signal().on(failed: { (error) in
            print(error)
            completion(false)
        }) { api in
            accessKey = api.accessKey
            completion(true)
        }
    }
}
class DMRequestHandler: RequestHandler {
    
    private let lock = NSLock()
    private var requestsToRetry: [RequestRetryCompletion] = []
    private var isRefreshingAccessKey = false
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let accessKey = LoginService.accessKey {
            var urlRequest = urlRequest
            urlRequest.addValue(accessKey, forHTTPHeaderField: "xxxxxx")
            return urlRequest
        }
        return urlRequest
    }
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let error = error as? NetError, error.statusCode == NetStatusCode.unAuthorized.rawValue {
            requestsToRetry.append(completion)
            
            DDLogInfo("[Api] Token过期")
            if !isRefreshingAccessKey {
                isRefreshingAccessKey = true
                DDLogInfo("[Api] Token续期")
                LoginService.refreshAccessKey { [weak self] succeeded in
                    guard let strongSelf = self else { return }
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    strongSelf.isRefreshingAccessKey = false
                    DDLogInfo("[Api] 开始重试")
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }.start()
            }
        } else {
            completion(false, 0.0)
        }
    }
}

class DMRequestApi: NSObject, RequestApi {
    
    
    var sessionIdentifier: String { return "DMRequestApi" }
    var baseURLString: String { return "http://xxxxxx" }
    var baseHeader: [String : Any]?
    var timeoutIntervalForRequest: TimeInterval { return 15 }
    var timeoutIntervalForResource: TimeInterval { return 45 }
    var url: String { return "" }
    var method: HTTPMethod { return .get }
    var params: [String: Any]? { return nil }
    var headers: HTTPHeaders? { return nil }
    var responseData: Data?
    var error: NetError?
    var requestHandler: RequestHandler? {
        return DMRequestHandler()
    }
    weak var indicator: Indicator?
    
    func setIndicator(_ indicator: Indicator?, view: UIView? = UIViewController.topController?.view, text: String? = nil) -> Self {
        self.indicator = indicator
        self.indicator?.add(api: self, view: view, text: text)
        return self
    }
    var validate: DataRequest.Validation {
        return { request, response, data in
            if let data = data,
                let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let map = dict {
                if let statusCode = (map["statusCode"] as? String)?.toInt(),
                    let message = map["errorMessage"] as? String,
                    statusCode != NetStatusCode.success.rawValue {
                    let error = NetError(statusCode: statusCode, message: message)
                    return DataRequest.ValidationResult.failure(error)
                }
            }
            return DataRequest.ValidationResult.success
        }
    }
    func adapt(_ result: Result<Any>) -> Result<Any> {
        if result.isSuccess,
            let map = result.value as? [String: Any],
            let statusCode = (map["statusCode"] as? String)?.toInt(),
            let message = map["errorMessage"] as? String {
            if statusCode == NetStatusCode.success.rawValue {
                if let value =  (map["data"] as? [String: Any]) {
                    return Result.success(value)
                }
                let value = (map["data"] as? String)?.toDictionary() ?? [:]
                return Result.success(value)
            } else {
                let error = NetError(statusCode: statusCode, message: message)
                return Result.failure(error)
            }
        }
        return result
    }
    
    func fill(map: [String: Any]) {}
    func fill(array: [Any]) {}
    
    public override init() {
        super.init()
    }
    public convenience init(error: NetError) {
        self.init()
        self.error = error
    }
    
    deinit {
        DDLogError("Deinit: \(NSStringFromClass(type(of: self)))")
    }
}
class LoginTokenApi: DMRequestApi {
    var username: String
    var token: String
    var result: [String: Any]?
    var accessKey: String? {
        return result?["access_key"] as? String
    }
    override var url: String { return "login/token" }
    override var method: HTTPMethod { return .post }
    override var params: [String : Any]? {
        return ["username": username, "token": token]
    }
    init(username: String, token: String) {
        self.username = username
        self.token = token
    }
    override func fill(map: [String : Any]) {
        result = map
    }
}
