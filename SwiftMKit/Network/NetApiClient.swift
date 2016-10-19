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
import ReachabilitySwift
import NetworkEncrypt

public enum NetworkStatus: CustomStringConvertible {
    
    case Unknown, NotReachable, ReachableViaWiFi, ReachableViaWWAN
    
    public var description: String {
        switch self {
        case .Unknown:
            return "Unknown"
        case .ReachableViaWWAN:
            return "Cellular"
        case .ReachableViaWiFi:
            return "WiFi"
        case .NotReachable:
            return "No Connection"
        }
    }
}

public protocol NetApiClientProtocol {
    static func requestJSON(request: NSURLRequest, api: NetApiProtocol,
                           completionHandler: (NetApiResponse<AnyObject, NSError> -> Void)?)
        -> AnyObject
    
    static func requestData(request: NSURLRequest, api: NetApiProtocol,
                            completionHandler: (NetApiResponse<NSData, NSError> -> Void)?)
        -> AnyObject
    
    static func requestString(request: NSURLRequest, api: NetApiProtocol,
                             completionHandler: (NetApiResponse<String, NSError> -> Void)?)
        -> AnyObject
    
    static func requestUpload(request: NSURLRequest, api: UploadNetApiProtocol,
                             completionHandler: (NetApiResponse<AnyObject, NSError> -> Void)?)
        -> AnyObject
}

public class NetApiClient : NSObject {
    public var networkStatus = MutableProperty<NetworkStatus>(.Unknown)
    private var reachability: Reachability?
    
    private override init() {
    }
    public static let shared = NetApiClient()
    
    public func startNotifyNetworkStatus() {
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            DDLogError("Unable to create Reachability")
            return
        }
        reachability?.whenReachable = { reachability in
            if reachability.isReachableViaWiFi() {
                DDLogInfo("当前网络: WiFi")
                self.networkStatus.value = .ReachableViaWiFi
            } else {
                DDLogInfo("当前网络: Cellular")
                self.networkStatus.value = .ReachableViaWWAN
            }
        }
        reachability?.whenUnreachable = { reachability in
            DDLogInfo("网络无法连接")
            self.networkStatus.value = .NotReachable
        }
        
        do {
            try self.reachability?.startNotifier()
        } catch {
            DDLogError("Unable to start notifier")
        }
    }
    
    class func clearCookie() {
        DDLogInfo("清除Cookie")
        let cookieJar = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
    }
    
    class func createBodyWithParameters(parameters: [String: AnyObject]?, filePathKey: String?, mimetype: String, uploadData: NSData) -> NSData {
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
        body.appendData(uploadData)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    class func generateBoundaryString() -> String {
        return "******"
    }
}