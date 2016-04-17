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

public protocol NetApiProtocol: class {
    var query: [String: AnyObject]? { get }
    var method: Alamofire.Method? { get }
    var url: String? { get }
    var timeout: NSTimeInterval? { get }
    var request: Request? { get set }
    var responseData: AnyObject? { get set }
    var indicator: IndicatorProtocol? { get set }
    var indicatorList: IndicatorListProtocol? { get set }
    
    func fillJSON(json: AnyObject)
    func transferURLRequest(request:NSMutableURLRequest) -> NSMutableURLRequest
    func transferResponseJSON(response: Response<AnyObject, NSError>) -> Response<AnyObject, NSError>
    func transferResponseData(response: Response<NSData, NSError>) -> Response<NSData, NSError>
    func transferResponseString(response: Response<String, NSError>) -> Response<String, NSError>
}
public extension NetApiProtocol {
    
    func signal(format:ApiFormatType = .JSON) -> SignalProducer<Self, NSError> {
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
    
    func setIndicator(indicator: IndicatorProtocol) -> Self {
        return setIndicator(indicator, view: nil)
    }
    func setIndicator(indicator: IndicatorProtocol, view: UIView?) -> Self {
        self.indicator = indicator
        self.indicator?.indicatorView = view
        return self
    }
    func setIndicatorList(indicator: IndicatorListProtocol) -> Self {
        self.indicatorList = indicator
        return self
    }
}