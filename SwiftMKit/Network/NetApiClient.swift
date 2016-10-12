//
//  NetApiClient.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/5/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CocoaLumberjack
import ReactiveCocoa
import ReachabilitySwift

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
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    DDLogInfo("当前网络: WiFi")
                    self.networkStatus.value = .ReachableViaWiFi
                } else {
                    DDLogInfo("当前网络: Cellular")
                    self.networkStatus.value = .ReachableViaWWAN
                }
            }
        }
        reachability?.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                DDLogInfo("网络无法连接")
                self.networkStatus.value = .NotReachable
            }
        }
        
        do {
            try self.reachability?.startNotifier()
        } catch {
            DDLogError("Unable to start notifier")
        }
    }
    
    class func bindIndicator(api api:NetApiProtocol, task: NSURLSessionTask) {
        if let indicator = api.indicator {
            indicator.bindTask(task, view: api.indicatorInView, text: api.indicatorText)
        }
        if let indicator = api.indicatorList {
            indicator.bindTaskForList(task)
        }
    }
    
    class func clearCookie() {
        DDLogInfo("清除Cookie")
        let cookieJar = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
    }
    
    class func requestJSON(request: NSURLRequest, api: NetApiProtocol,
                 completionHandler: (Response<AnyObject, NSError> -> Void)?)
        -> RequestProtocol {
            let request = Alamofire.request(request)
            api.request = request
            self.bindIndicator(api: api, task: request.task)
            let timeBegin = NSDate()
            return request.responseJSON { response in
                DDLogWarn("请求耗时: \(NSDate().timeIntervalSinceDate(timeBegin).secondsToHHmmssString())")
                let transferedResponse = api.transferResponseJSON(response)
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("请求成功: \(api.url!)")
                    if let value = transferedResponse.result.value {
                        DDLogVerbose("JSON: \(value)")
                    }
                case .Failure(let error):
                    if let statusCode = StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("请求取消: \(api.url!)")
                            return
                        default:
                            break
                        }
                    }
                    DDLogError("请求失败: \(api.url!)")
                    DDLogError("\(error)")
                }
                if completionHandler != nil {
                    completionHandler!(transferedResponse)
                }
            }
    }
    class func requestData(request: NSURLRequest, api: NetApiProtocol,
                           completionHandler: (Response<NSData, NSError> -> Void)?)
        -> RequestProtocol {
            let request = Alamofire.request(request)
            api.request = request
            self.bindIndicator(api: api, task: request.task)
            let timeBegin = NSDate()
            return request.responseData { response in
                DDLogWarn("请求耗时: \(NSDate().timeIntervalSinceDate(timeBegin).secondsToHHmmssString())")
                let transferedResponse = api.transferResponseData(response)
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("请求成功: \(api.url!)")
                    DDLogVerbose("Data: \(transferedResponse.result.value?.length) bytes")
                case .Failure(let error):
                    if let statusCode =  StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("请求取消: \(api.url!)")
                            return
                        default:
                            break
                        }
                    }
                    DDLogError("请求失败: \(api.url!)")
                    DDLogError("\(error)")
                }
                if completionHandler != nil {
                    completionHandler!(transferedResponse)
                }
            }
    }
    class func requestString(request: NSURLRequest, api: NetApiProtocol,
                             completionHandler: (Response<String, NSError> -> Void)?)
        -> RequestProtocol {
            let request = Alamofire.request(request)
            api.request = request
            self.bindIndicator(api: api, task: request.task)
            let timeBegin = NSDate()
            return request.responseString { response in
                DDLogWarn("请求耗时: \(NSDate().timeIntervalSinceDate(timeBegin).secondsToHHmmssString())")
                let transferedResponse = api.transferResponseString(response)
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("请求成功: \(api.url!)")
                    DDLogVerbose("String: \(transferedResponse.result.value)")
                case .Failure(let error):
                    if let statusCode =  StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("请求取消: \(api.url!)")
                            return
                        default:
                            break
                        }
                    }
                    DDLogError("请求失败: \(api.url!)")
                    DDLogError("\(error)")
                }
                if completionHandler != nil {
                    completionHandler!(transferedResponse)
                }
            }
    }
    class func requestUpload(request: NSURLRequest, api: UploadNetApiProtocol,
                           completionHandler: (Response<AnyObject, NSError> -> Void)?)
        -> RequestProtocol {
            let uploadData = NetApiClient.createBodyWithParameters(api.query, filePathKey: api.uploadDataName, mimetype: api.uploadDataMimeType ?? "", uploadData: api.uploadData!)
            let request = Alamofire.upload(request, data: uploadData)
            api.request = request
            self.bindIndicator(api: api, task: request.task)
            let timeBegin = NSDate()
            return request.responseJSON { response in
                DDLogWarn("请求耗时: \(NSDate().timeIntervalSinceDate(timeBegin).secondsToHHmmssString())")
                let transferedResponse = api.transferResponseJSON(response)
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("请求成功: \(api.url!)")
                    if let value = transferedResponse.result.value {
                        DDLogVerbose("JSON: \(value)")
                    }
                case .Failure(let error):
                    if let statusCode = StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("请求取消: \(api.url!)")
                            return
                        default:
                            break
                        }
                    }
                    DDLogError("请求失败: \(api.url!)")
                    DDLogError("\(error)")
                }
                if completionHandler != nil {
                    completionHandler!(transferedResponse)
                }
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