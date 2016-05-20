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
    var query: [String: AnyObject]? { get }
    var method: Alamofire.Method? { get }
    var url: String? { get }
    var timeout: NSTimeInterval? { get set }
    var request: Request? { get set }
    var responseData: AnyObject? { get set }
    
    func fillJSON(json: AnyObject)
    func transferURLRequest(request:NSMutableURLRequest) -> NSMutableURLRequest
    func transferResponseJSON(response: Response<AnyObject, NSError>) -> Response<AnyObject, NSError>
    func transferResponseData(response: Response<NSData, NSError>) -> Response<NSData, NSError>
    func transferResponseString(response: Response<String, NSError>) -> Response<String, NSError>
}

public class NetApiAbstract: NetApiProtocol{
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
    
    public func fillJSON(json: AnyObject) {}
    public func transferURLRequest(request:NSMutableURLRequest) -> NSMutableURLRequest { return request }
    public func transferResponseJSON(response: Response<AnyObject, NSError>) -> Response<AnyObject, NSError> { return response }
    public func transferResponseData(response: Response<NSData, NSError>) -> Response<NSData, NSError> { return response }
    public func transferResponseString(response: Response<String, NSError>) -> Response<String, NSError> { return response }

}

public extension NetApiProtocol {
    
    func signal(format:ApiFormatType = .JSON) -> SignalProducer<Self, NetError> {
        switch format {
        case .JSON:
            return NetApiData(api: self).requestJSON().map { _ in
                return self
            }
        case .Data:
            return NetApiData(api: self).requestData().map { _ in
                return self
            }
        case .String:
            return NetApiData(api: self).requestString().map { _ in
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