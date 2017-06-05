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

public enum ApiFormatType {
    case json, data, string, upload, multipartUpload
}
public enum ApiMethod: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

public protocol NetApiIndicatorProtocol {
    weak var indicator: IndicatorProtocol? { get set }
    weak var view: UIView? { get set }
    var text: String? { get set }
}
open class NetApiIndicator : NetApiIndicatorProtocol {
    open weak var indicator: IndicatorProtocol?
    open weak var view: UIView?
    open var text: String?
    init(indicator: IndicatorProtocol, view: UIView?, text: String? = nil) {
        self.indicator = indicator
        self.view = view
        self.text = text
    }
    func bindTask(_ task: URLSessionTask) {
        indicator?.bindTask(task, view: view, text: text)
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

public protocol NetApiProtocol: class {
    var error: NetError? { get }
    var query: [String: Any] { get }
    var method: ApiMethod { get }
    var url: String { get }
    var timeout: TimeInterval { get set }
    var request: AnyObject? { get set }
    var response: NetApiResponse<AnyObject, NSError>? { get set }
    var indicator: NetApiIndicator? { get set }
    
    func fillJSON(_ json: AnyObject)
    func transferURLRequest(_ request:URLRequest) -> URLRequest
    func transferResponseJSON(_ response: NetApiResponse<AnyObject, NSError>) -> NetApiResponse<AnyObject, NSError>
    func transferResponseData(_ response: NetApiResponse<Data, NSError>) -> NetApiResponse<Data, NSError>
    func transferResponseString(_ response: NetApiResponse<String, NSError>) -> NetApiResponse<String, NSError>
    func requestJSON() -> SignalProducer<NetApiProtocol, NetError>
    func requestData() -> SignalProducer<NetApiProtocol, NetError>
    func requestString() -> SignalProducer<NetApiProtocol, NetError>
    func requestUpload() -> SignalProducer<UploadNetApiProtocol, NetError>
    func requestMultipartUpload( ) -> SignalProducer<MultipartUploadNetApiProtocol, NetError>
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
    
    func signal(format:ApiFormatType = .json) -> SignalProducer<Self, NetError> {
        if let err = error {
            return SignalProducer { sink, _ in
                sink.send(error: err)
            }
        }
        switch format {
        case .json:
            return self.requestJSON().map { _ in
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
        if let indicator = indicator {
            self.indicator = NetApiIndicator(indicator: indicator, view: view, text: text)
        }
        return self
    }
}
