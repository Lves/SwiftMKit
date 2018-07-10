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

public struct NetworkDemo {
    func test() {
        LoginApi(mobile: "18600586544", password: "123123")
            .signal().on(failed: { (error) in
                
        }) { api in
//            LoginService.accessKey = api.accessKey!
//            LoginService.token = api.token!
//            LoginService.username = api.username!
//            LoanUserInfo().signal().on(failed: { (error) in
//            }) { api in
//
//                }.start()
            
        }.start()
//        AdApi(type: .Home).signal().on(failed: { (error) in
//            let e = error
//            print(error)
//        }) { api in
//            let a = api.ads
//            print(a)
//        }.start()
    }
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
            urlRequest.addValue(accessKey, forHTTPHeaderField: "jm-authorization")
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
//    var baseURLString: String { return "http://localhost:8093" }
    var baseURLString: String { return "http://miracle-web-app.qa-01.idumiao.com" }
    var baseHeader: [String : Any]? { return ["x-device-info" : "Xiaomi/19/android/8022000/6"] }
    var timeoutIntervalForRequest: TimeInterval { return 15 }
    var timeoutIntervalForResource: TimeInterval { return 45 }
    var url: String { return "" }
    var method: HTTPMethod { return .get }
    var params: [String: Any]? { return nil }
    var headers: HTTPHeaders? { return nil }
    var error: NetError?
    var requestHandler: RequestHandler? {
        return DMRequestHandler()
    }
    weak var indicator: Indicator?
    
    func setIndicator(indicator: Indicator?, view: UIView? = UIViewController.topController?.view, text: String? = nil) -> Self {
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
class MiracleRequestApi: DMRequestApi {
    override var sessionIdentifier: String { return "MiracleRequestApi" }
    override var baseURLString: String { return super.baseURLString + "/miracle" }
    
    override func adapt(_ result: Result<Any>) -> Result<Any> {
        let result = super.adapt(result)
        if result.isSuccess, let map = result.value as? [String: Any] {
            if let data = map["data"] {
                return Result.success(data)
            } else if
                let statusCode = (map["statusCode"] as? String)?.toInt(),
                let message = map["errorMessage"] as? String,
                statusCode != NetStatusCode.success.rawValue {
                let error = NetError(statusCode: statusCode, message: message)
                return Result.failure(error)
            }
        }
        return result
    }
    override init() {
        super.init()
    }
}
class LoanRequestApi: DMRequestApi {
    override var sessionIdentifier: String { return "LoanRequestApi" }
    override var baseURLString: String { return super.baseURLString + "/loan" }
    
    override func adapt(_ result: Result<Any>) -> Result<Any> {
        let result = super.adapt(result)
        if result.isSuccess, let map = result.value as? [String: Any] {
            if let data = map["data"] {
                return Result.success(data)
            } else if
                let statusCode = (map["statusCode"] as? String)?.toInt(),
                let message = map["errorMessage"] as? String,
                statusCode != NetStatusCode.success.rawValue {
                let error = NetError(statusCode: statusCode, message: message)
                return Result.failure(error)
            }
        }
        return result
    }
    override init() {
        super.init()
    }
}
enum AdType: Int {
    case home = 201
}
class TimeoutApi: DMRequestApi {
    override var url: String { return "timeout" }
}
class LoginApi: DMRequestApi {
    var mobile: String
    var password: String
    var result: [String: Any]?
    var accessKey: String? {
        return result?["access_key"] as? String
    }
    var token: String? {
        return result?["token"] as? String
    }
    var username: String? {
        return result?["userName"] as? String
    }
    override var url: String { return "login" }
    override var method: HTTPMethod { return .post }
    override var params: [String : Any]? {
        return ["username": mobile, "password": password]
    }
    
    init(mobile: String, password: String) {
        self.mobile = mobile
        self.password = password
    }
    override func fill(map: [String : Any]) {
        result = map
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
class LoanUserInfo: LoanRequestApi {
    var userInfo: [String: Any]?
    override var url: String {
        return "/app/user/v5/user/info"
    }
    override func fill(map: [String : Any]) {
        userInfo = map
    }
}
class AdApi: MiracleRequestApi {
    var type: AdType = .home
    var ads: [AdModel]?
    override var url: String {
        return "/api/v1/discoveries/list/\(type.rawValue)"
    }
    override init() {
        super.init()
    }
    init(type: AdType) {
        super.init()
        self.type = type
    }
    override func fill(array: [Any]) {
        self.ads = toModel([AdModel].self, value: array)
    }
}
struct AdModel: Codable {
    var id: Int
    var fileID: String
    var address: String
    var name: String
    var weight: Int
}
