//
//  NetApiData.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/8/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import CocoaLumberjack
import MJExtension
import ReactiveSwift
import Alamofire

open class NetApiData: NSObject, NetApiProtocol {
    
    private struct Const {
        static let defaultTimeout: TimeInterval = 45
    }
    
    open var error: NetError?
    open var query: [String: Any] = [:]
    open var method: ApiMethod = .get
    open var url: String = ""
    open var timeout: TimeInterval = Const.defaultTimeout
    open var task: URLSessionTask?
    open var request: URLRequest?
    open var response: NetApiResponse<Any, NSError>?
    
    open func fill(json: Any) {
        if let map = json as? [String: Any] {
            fill(map: map)
        } else if let array = json as? [Any] {
            fill(array: array)
        }
    }
    open func transfer(request:URLRequest) -> URLRequest { return request }
    open func requestJson() -> SignalProducer<NetApiProtocol, NetError> { return SignalProducer.empty }
    open func requestData() -> SignalProducer<NetApiProtocol, NetError> { return SignalProducer.empty }
    open func requestString() -> SignalProducer<NetApiProtocol, NetError> { return SignalProducer.empty }
    open func requestUpload() -> SignalProducer<UploadNetApiProtocol, NetError> { return SignalProducer.empty }
    open func requestMultipartUpload() -> SignalProducer<MultipartUploadNetApiProtocol, NetError> { return SignalProducer.empty }
    
    open func fill(map: [String: Any]) {}
    open func fill(array: [Any]) {}
    open func transferResponse(_ response: NetApiResponse<Any, NSError>) -> NetApiResponse<Any, NSError> { return response }
    open func transferResponse(_ response: NetApiResponse<Data, NSError>) -> NetApiResponse<Data, NSError> { return response }
    open func transferResponse(_ response: NetApiResponse<String, NSError>) -> NetApiResponse<String, NSError> { return response }
    
    public override init() {
        super.init()
    }
    public convenience init(error: NetError) {
        self.init()
        self.error = error
    }
    
    static func clearCookie() {
        DDLogInfo("清除Cookie")
        let cookieJar = HTTPCookieStorage.shared
        
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
    }
    
}
