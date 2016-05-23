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
                    DDLogInfo("Network Status Change: Reachable via WiFi")
                    self.networkStatus.value = .ReachableViaWiFi
                } else {
                    DDLogInfo("Network Status Change: Reachable via Cellular")
                    self.networkStatus.value = .ReachableViaWWAN
                }
            }
        }
        reachability?.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                DDLogInfo("Network Status Change: Not reachable")
                self.networkStatus.value = .NotReachable
            }
        }
        
        do {
            try self.reachability?.startNotifier()
        } catch {
            DDLogError("Unable to start notifier")
        }
    }
    
    class private func bindIndicator(api api:NetApiProtocol, task: NSURLSessionTask) {
        if let indicator = api.indicator {
            indicator.bindTask(task, view: api.indicatorInView, text: api.indicatorText)
        }
        if let indicator = api.indicatorList {
            indicator.bindTaskForList(task)
        }
    }
    
    class func requestJSON(request: NSURLRequest, api: NetApiProtocol,
                 completionHandler: (Response<AnyObject, NSError> -> Void)?)
        -> Request {
            let request = Alamofire.request(request)
            api.request = request
            self.bindIndicator(api: api, task: request.task)
            let timeBegin = NSDate()
            return request.responseJSON { response in
                DDLogWarn("Expend Time: \(NSDate().timeIntervalSinceDate(timeBegin).secondsToHHmmssString())")
                let transferedResponse = api.transferResponseJSON(response)
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("Request Url Success: \(api.url!)")
                    if let value = response.result.value {
                        DDLogVerbose("JSON: \(value)")
                    }
                case .Failure(let error):
                    if let statusCode = StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("Request Url Canceled: \(api.url!)")
                            return
                        default:
                            break
                        }
                    }
                    DDLogError("Request Url Failed: \(api.url!)")
                    DDLogError("\(error)")
                }
                if completionHandler != nil {
                    completionHandler!(transferedResponse)
                }
            }
    }
    class func requestData(request: NSURLRequest, api: NetApiProtocol,
                           completionHandler: (Response<NSData, NSError> -> Void)?)
        -> Request {
            let request = Alamofire.request(request)
            api.request = request
            self.bindIndicator(api: api, task: request.task)
            let timeBegin = NSDate()
            return request.responseData { response in
                DDLogWarn("Expend Time: \(NSDate().timeIntervalSinceDate(timeBegin).secondsToHHmmssString())")
                let transferedResponse = api.transferResponseData(response)
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("Request Url Success: \(api.url!)")
                    DDLogVerbose("Data: \(response.result.value?.length) bytes")
                case .Failure(let error):
                    if let statusCode =  StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("Request Url Canceled: \(api.url!)")
                            return
                        default:
                            break
                        }
                    }
                    DDLogError("Request Url Failed: \(api.url!)")
                    DDLogError("\(error)")
                }
                if completionHandler != nil {
                    completionHandler!(transferedResponse)
                }
            }
    }
    class func requestString(request: NSURLRequest, api: NetApiProtocol,
                             completionHandler: (Response<String, NSError> -> Void)?)
        -> Request {
            let request = Alamofire.request(request)
            api.request = request
            self.bindIndicator(api: api, task: request.task)
            let timeBegin = NSDate()
            return request.responseString { response in
                DDLogWarn("Expend Time: \(NSDate().timeIntervalSinceDate(timeBegin).secondsToHHmmssString())")
                let transferedResponse = api.transferResponseString(response)
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("Request Url Success: \(api.url!)")
                    DDLogVerbose("String: \(response.result.value)")
                case .Failure(let error):
                    if let statusCode =  StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("Request Url Canceled: \(api.url!)")
                            return
                        default:
                            break
                        }
                    }
                    DDLogError("Request Url Failed: \(api.url!)")
                    DDLogError("\(error)")
                }
                if completionHandler != nil {
                    completionHandler!(transferedResponse)
                }
            }
    }
}