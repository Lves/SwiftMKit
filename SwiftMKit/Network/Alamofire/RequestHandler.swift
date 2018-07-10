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
public protocol RequestHandler: RequestAdapter, RequestRetrier {
}
public extension RequestHandler {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }

    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        completion(false, 0)
    }
}
