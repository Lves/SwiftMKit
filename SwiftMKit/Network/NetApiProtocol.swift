//
//  ApiProtocol.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Alamofire

public enum ApiFormatType {
    case JSON, Data, String, Upload, MultipartUpload
}
public enum ApiMethod: String {
    case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

public protocol NetApiIndicatorProtocol {
    var indicator: IndicatorProtocol? { get set }
    var view: UIView? { get set }
    var text: String? { get set }
}
public class NetApiIndicator : NetApiIndicatorProtocol {
    public weak var indicator: IndicatorProtocol?
    public weak var view: UIView?
    public var text: String?
    init(indicator: IndicatorProtocol, view: UIView?, text: String? = nil) {
        self.indicator = indicator
        self.view = view
        self.text = text
    }
    func bindTask(task: NSURLSessionTask) {
        indicator?.bindTask(task, view: view, text: text)
    }
}

public enum NetApiResult<Value, Error: ErrorType> {
    case Success(Value)
    case Failure(Error)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .Success:
            return true
        case .Failure:
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
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: Error? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error):
            return error
        }
    }
}

public struct NetApiResponse<Value, Error: ErrorType> {
    public let request: NSURLRequest?
    public let response: NSHTTPURLResponse?
    public let data: NSData?
    public let result: NetApiResult<Value, Error>
    
    public init(
        request: NSURLRequest?,
        response: NSHTTPURLResponse?,
        data: NSData?,
        result: NetApiResult<Value, Error>)
    {
        self.request = request
        self.response = response
        self.data = data
        self.result = result
    }
}

public protocol NetApiProtocol: class {
    var error: NetError? { get }
    var query: [String: AnyObject] { get }
    var method: ApiMethod { get }
    var url: String { get }
    var timeout: NSTimeInterval { get set }
    var request: AnyObject? { get set }
    var response: AnyObject? { get set }
    var indicator: NetApiIndicator? { get set }
    
    
    func fillJSON(json: AnyObject)
    func transferURLRequest(request:NSMutableURLRequest) -> NSMutableURLRequest
    func transferResponseJSON(response: NetApiResponse<AnyObject, NSError>) -> NetApiResponse<AnyObject, NSError>
    func transferResponseData(response: NetApiResponse<NSData, NSError>) -> NetApiResponse<NSData, NSError>
    func transferResponseString(response: NetApiResponse<String, NSError>) -> NetApiResponse<String, NSError>
    func requestJSON() -> SignalProducer<NetApiProtocol, NetError>
    func requestData() -> SignalProducer<NetApiProtocol, NetError>
    func requestString() -> SignalProducer<NetApiProtocol, NetError>
    func requestUpload() -> SignalProducer<UploadNetApiProtocol, NetError>
    func requestMultipartUpload( ) -> SignalProducer<MultipartUploadNetApiProtocol, NetError>
}


public protocol UploadNetApiProtocol: NetApiProtocol {
    var uploadData: NSData? { get set }
    var uploadDataName: String? { get }
    var uploadDataMimeType: String? { get }
}
public protocol MultipartUploadNetApiProtocol: NetApiProtocol {
    var fileList:[UploadFileModel]? { get } //多文件上传用
}
//图片model
public class UploadFileModel: NSObject {
    var fileName:String?
    var mimetype:String?
    var uploadData:NSData?
    override init() {
        super.init()
    }
    init(fileName:String,mimetype:String,uploadData:NSData){
        super.init()
        self.fileName = fileName
        self.mimetype = mimetype
        self.uploadData = uploadData
    }
}


public extension NetApiProtocol {
    
    func signal(format:ApiFormatType = .JSON) -> SignalProducer<Self, NetError> {
        if let err = error {
            return SignalProducer { sink, _ in
                sink.sendFailed(err)
            }
        }
        switch format {
        case .JSON:
            return self.requestJSON().map { _ in
                return self
            }
        case .Data:
            return self.requestData().map { _ in
                return self
            }
        case .String:
            return self.requestString().map { _ in
                return self
            }
        case .Upload:
            return self.requestUpload().map { _ in
                return self
            }
        case .MultipartUpload:
            return self.requestMultipartUpload().map{_ in
                return self
            }
        }
        
    }
    
    func setIndicator(indicator: IndicatorProtocol?, view: UIView? = nil, text: String? = nil) -> Self {
        if let indicator = indicator {
            self.indicator = NetApiIndicator(indicator: indicator, view: view, text: text)
        }
        return self
    }
}
