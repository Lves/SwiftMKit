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

public class NetApiClient : NSObject {
    
    class private func bindIndicator(api api:NetApiProtocol, task: NSURLSessionTask) {
        if let indicator = api.indicator {
            if let view = indicator.indicatorView {
                indicator.setIndicatorState(task, view: view, text: indicator.indicatorText)
            } else {
                indicator.setIndicatorState(task, text: indicator.indicatorText)
            }
        }
        if let indicator = api.indicatorList {
            indicator.setIndicatorListState(task)
        }
    }
    
    class func requestJSON(request: NSURLRequest, api: NetApiProtocol,
                 completionHandler: (Response<AnyObject, NSError> -> Void)?)
        -> Request {
            let request = Alamofire.request(request)
            api.request = request
            self.bindIndicator(api: api, task: request.task)
            return request.responseJSON { response in
                let transferedResponse = api.transferResponseJSON(response)
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("Request Url Success: \(api.url!)")
                    if let value = response.result.value {
                        DDLogVerbose("JSON: \(value)")
                    }
                case .Failure(let error):
                    if let statusCode =  StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("Request Url Canceled: \(api.url!)")
                            return
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
            return request.responseData { response in
                let transferedResponse = api.transferResponseData(response)
                switch transferedResponse.result {
                case .Success:
                    DDLogInfo("Request Url Success: \(api.url!)")
                    DDLogVerbose("Data: \(response.result.value)")
                case .Failure(let error):
                    if let statusCode =  StatusCode(rawValue:error.code) {
                        switch(statusCode) {
                        case .Canceled:
                            DDLogWarn("Request Url Canceled: \(api.url!)")
                            return
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
            return request.responseString { response in
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