//
//  ApiProtocol.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import CocoaLumberjack

public enum ApiFormatType {
    case json, data, string, upload, multipartUpload
}
public enum ApiMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}
public enum ApiTaskStatus {
    case standby, running, stop
}
//public enum NetStatusCode: Int {
//    case `default` = 0
//    case success = 200
//    case businessSuccess = 2000
//    case canceled = -999
//    case validateFailed = -99999
//    case forceUpgrade = -10000
//    case badRequest = 400
//    case unAuthorized = 401
//    case loginOtherDevice = 403
//    case timeOut = 504
//}

public protocol IndicatorProtocol {
    var runningApis: [NetApiProtocol] { get set }
    func bind(api: NetApiProtocol, view: UIView?, text: String?)
    mutating func removeApi(forTask task: URLSessionTask)
}
public extension IndicatorProtocol {
    mutating func removeApi(forTask task: URLSessionTask) {
        guard let index = runningApis.index(where: { $0.task == task }) else { return }
        runningApis.remove(at: index)
    }
}

public enum NetApiResult<Value, NError: Error> {
    case success(Value)
    case failure(NError)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: NError? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}

public struct NetApiResponse<Value, NError: Error> {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    public let result: NetApiResult<Value, NError>
    
    public init(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        result: NetApiResult<Value, NError>)
    {
        self.request = request
        self.response = response
        self.data = data
        self.result = result
    }
}

public protocol NetApiRequestHandler {
    func transfer(request:URLRequest) -> URLRequest
    func requestJson() -> SignalProducer<NetApiProtocol, NetError>
    func requestData() -> SignalProducer<NetApiProtocol, NetError>
    func requestString() -> SignalProducer<NetApiProtocol, NetError>
    func requestUpload() -> SignalProducer<UploadNetApiProtocol, NetError>
    func requestMultipartUpload( ) -> SignalProducer<MultipartUploadNetApiProtocol, NetError>
}
public protocol NetApiResponseHandler {
    func fill(json: Any)
    func fill(map: [String: Any])
    func fill(array: [Any])
    func transferResponse(_ response: NetApiResponse<Any, NSError>) -> NetApiResponse<Any, NSError>
    func transferResponse(_ response: NetApiResponse<Data, NSError>) -> NetApiResponse<Data, NSError>
    func transferResponse(_ response: NetApiResponse<String, NSError>) -> NetApiResponse<String, NSError>
}

public protocol NetApiProtocol: class, NetApiRequestHandler, NetApiResponseHandler {
    var error: NetError? { get set }
    var query: [String: Any] { get }
    var method: ApiMethod { get }
    var url: String { get }
    var timeout: TimeInterval { get set }
    var request: URLRequest? { get set }
    var task: URLSessionTask? { get set }
    var response: NetApiResponse<Any, NSError>? { get set }
}

public protocol UploadNetApiProtocol: NetApiProtocol {
    var uploadData: Data? { get set }
    var uploadDataName: String? { get }
    var uploadDataMimeType: String? { get }
}
public protocol MultipartUploadNetApiProtocol: NetApiProtocol {
    var fileList:[UploadFileModel]? { get } //多文件上传用
}
//图片model
public class UploadFileModel: NSObject {
    var fileName: String
    var mimetype: String
    var uploadData: Data
    init(fileName: String, mimetype: String, uploadData: Data){
        self.fileName = fileName
        self.mimetype = mimetype
        self.uploadData = uploadData
        super.init()
    }
}

public extension NetApiProtocol {
    func createURLRequest() -> URLRequest {
        var mutableURLRequest = URLRequest(url: URL(string: url)!)
        mutableURLRequest.httpMethod = method.rawValue
        mutableURLRequest.timeoutInterval = timeout
        let parameterString = query.stringFromHttpParameters()
        DDLogInfo("请求地址: \(method.rawValue) \(mutableURLRequest.url?.absoluteString ?? "")?\(parameterString)")
        mutableURLRequest = transfer(request: mutableURLRequest)
        request = mutableURLRequest
        return mutableURLRequest
    }
    func combineQuery(_ base: [String: Any]?, append: [String: Any]?) -> [String: Any]? {
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
    func createBody(withParameters parameters: [String: Any]?, filePathKey: String?, mimetype: String, uploadData: Data) -> Data {
        let body = NSMutableData()
        let boundary = generateBoundaryString()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(uploadData)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        return body as Data
    }
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    func generateBoundaryString() -> String {
        return "******"
    }
    
    func signal(format:ApiFormatType = .json) -> SignalProducer<Self, NetError> {
        if let err = error {
            return SignalProducer { sink, _ in
                sink.send(error: err)
            }
        }
        switch format {
        case .json:
            return self.requestJson().map { _ in
                return self
            }
        case .data:
            return self.requestData().map { _ in
                return self
            }
        case .string:
            return self.requestString().map { _ in
                return self
            }
        case .upload:
            return self.requestUpload().map { _ in
                return self
            }
        case .multipartUpload:
            return self.requestMultipartUpload().map{_ in
                return self
            }
        }
        
    }
    
    func setIndicator(_ indicator: IndicatorProtocol?, view: UIView? = nil, text: String? = nil) -> Self {
        indicator?.bind(api: self, view: view, text: text)
        return self
    }
    
    func get(_ success: @escaping (Self) -> Void) -> SignalProducer<Self, NetError> {
        return get(success, error: { error in UIViewController.topController?.showTip(error.message)})
    }
    func get(_ success: @escaping (Self) -> Void, error: @escaping (NetError) -> Void) -> SignalProducer<Self, NetError> {
        return signal().on(
            failed: error,
            value: { data in
                success(data)
        })
    }
}


func + <T: NetApiProtocol> (api: T, indicator: IndicatorProtocol) -> T {
    return api.setIndicator(indicator)
}
