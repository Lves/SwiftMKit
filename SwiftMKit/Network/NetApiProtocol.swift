//
//  ApiProtocol.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import Alamofire
import ReactiveCocoa

public enum ApiFormatType {
    case JSON, Data, String
}

public protocol NetApiIndicatorProtocol : class {
    var indicator: IndicatorProtocol? { get set }
    var indicatorInView: UIView! { get set }
    var indicatorText: String? { get set }
    var indicatorList: IndicatorListProtocol? { get set }
}

public protocol NetApiProtocol: NetApiIndicatorProtocol {
    var error: NetError? { get }
    var query: [String: AnyObject]? { get }
    var method: Alamofire.Method? { get }
    var url: String? { get }
    var timeout: NSTimeInterval? { get set }
    var request: Request? { get set }
    var responseData: AnyObject? { get set }
    
    func getNetApiData() -> NetApiData
    
    func fillJSON(json: AnyObject)
    func transferURLRequest(request:NSMutableURLRequest) -> NSMutableURLRequest
    func transferResponseJSON(response: Response<AnyObject, NSError>) -> Response<AnyObject, NSError>
    func transferResponseData(response: Response<NSData, NSError>) -> Response<NSData, NSError>
    func transferResponseString(response: Response<String, NSError>) -> Response<String, NSError>
    func transferParameterEncoding() -> ParameterEncoding
}

public class NetApiAbstract: NetApiProtocol{
    public var error: NetError?
    public var query: [String: AnyObject]?
    public var method: Alamofire.Method?
    public var url: String?
    public var timeout: NSTimeInterval?
    public var request: Request?
    public var responseData: AnyObject?
    
    public var indicator: IndicatorProtocol?
    public var indicatorInView: UIView!
    public var indicatorText: String?
    public var indicatorList: IndicatorListProtocol?
    
    public convenience init(error: NetError) {
        self.init()
        self.error = error
    }
    public init() {
    }
    public func getNetApiData() -> NetApiData {
        return NetApiData(api: self)
    }
    public func fillJSON(json: AnyObject) {}
    public func transferURLRequest(request:NSMutableURLRequest) -> NSMutableURLRequest { return request }
    public func transferResponseJSON(response: Response<AnyObject, NSError>) -> Response<AnyObject, NSError> { return response }
    public func transferResponseData(response: Response<NSData, NSError>) -> Response<NSData, NSError> { return response }
    public func transferResponseString(response: Response<String, NSError>) -> Response<String, NSError> { return response }
    public func transferParameterEncoding() -> ParameterEncoding { return Alamofire.ParameterEncoding.URL }
    
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
            return getNetApiData().requestJSON().map { _ in
                return self
            }
        case .Data:
            return getNetApiData().requestData().map { _ in
                return self
            }
        case .String:
            return getNetApiData().requestString().map { _ in
                return self
            }
        }
    }
    
    func setIndicator(indicator: IndicatorProtocol, view: UIView, text: String? = nil) -> Self {
        self.indicator = indicator
        self.indicatorInView = view
        self.indicatorText = text
        return self
    }
    func setIndicatorList(indicator: IndicatorListProtocol) -> Self {
        self.indicatorList = indicator
        return self
    }
}