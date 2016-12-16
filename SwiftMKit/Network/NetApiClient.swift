//
//  NetApiClient.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/5/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack
import ReactiveCocoa
import ReactiveSwift
import ReachabilitySwift

public enum NetworkStatus: CustomStringConvertible {
    
    case unknown, notReachable, reachableViaWiFi, reachableViaWWAN
    
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .reachableViaWWAN:
            return "Cellular"
        case .reachableViaWiFi:
            return "WiFi"
        case .notReachable:
            return "No Connection"
        }
    }
}

public protocol NetApiClientProtocol {
    static func requestJSON(_ request: URLRequest, api: NetApiProtocol,
                           completionHandler: ((NetApiResponse<AnyObject, NSError>) -> Void)?)
        -> AnyObject
    
    static func requestData(_ request: URLRequest, api: NetApiProtocol,
                            completionHandler: ((NetApiResponse<Data, NSError>) -> Void)?)
        -> AnyObject
    
    static func requestString(_ request: URLRequest, api: NetApiProtocol,
                             completionHandler: ((NetApiResponse<String, NSError>) -> Void)?)
        -> AnyObject
    
    static func requestUpload(_ request: URLRequest, api: UploadNetApiProtocol,
                             completionHandler: ((NetApiResponse<AnyObject, NSError>) -> Void)?)
        -> AnyObject
}

open class NetApiClient : NSObject {
    open var networkStatus = MutableProperty<NetworkStatus>(.unknown)
    fileprivate var reachability: Reachability?
    
    fileprivate override init() {
    }
    open static let shared = NetApiClient()
    
    open func startNotifyNetworkStatus() {
        reachability = Reachability.init()
        reachability?.whenReachable = { reachability in
            if reachability.isReachableViaWiFi {
                DDLogInfo("当前网络: WiFi")
                self.networkStatus.value = .reachableViaWiFi
            } else {
                DDLogInfo("当前网络: Cellular")
                self.networkStatus.value = .reachableViaWWAN
            }
        }
        reachability?.whenUnreachable = { reachability in
            DDLogInfo("网络无法连接")
            self.networkStatus.value = .notReachable
        }
        
        do {
            try self.reachability?.startNotifier()
        } catch {
            DDLogError("Unable to start notifier")
        }
    }
    
    class func clearCookie() {
        DDLogInfo("清除Cookie")
        let cookieJar = HTTPCookieStorage.shared
        
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
    }
    
    class func createBodyWithParameters(_ parameters: [String: AnyObject]?, filePathKey: String?, mimetype: String, uploadData: Data) -> Data {
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
    
    class func generateBoundaryString() -> String {
        return "******"
    }
}
