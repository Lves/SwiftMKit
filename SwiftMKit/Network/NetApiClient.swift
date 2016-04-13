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
import SwiftyJSON

public class NetApiClient : NSObject {
    
    func requestJSON(request: NSURLRequest,
                 completionHandler: (Response<AnyObject, NSError> -> Void)?)
        -> Request {
            return Alamofire.request(request).responseJSON { response in
                let transferedResponse = self.transferResponseJSON(response)
                switch transferedResponse.result {
                case .Success:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DDLogVerbose("JSON: \(json)")
                    }
                case .Failure(let error):
                    DDLogError("\(error)")
                }
                if completionHandler != nil {
                    completionHandler!(transferedResponse)
                }
            }
    }
    func requestData(request: NSURLRequest,
                           completionHandler: (Response<NSData, NSError> -> Void)?)
        -> Request {
            return Alamofire.request(request).responseData { response in
                let transferedResponse = self.transferResponseData(response)
                switch transferedResponse.result {
                case .Success:
                    DDLogVerbose("Data: \(response.result.value)")
                case .Failure(let error):
                    DDLogError("\(error)")
                }
                if completionHandler != nil {
                    completionHandler!(transferedResponse)
                }
            }
    }
    func requestString(request: NSURLRequest,
                             completionHandler: (Response<String, NSError> -> Void)?)
        -> Request {
            return Alamofire.request(request).responseString { response in
                let transferedResponse = self.transferResponseString(response)
                switch transferedResponse.result {
                case .Success:
                    DDLogVerbose("String: \(response.result.value)")
                case .Failure(let error):
                    DDLogError("\(error)")
                }
                if completionHandler != nil {
                    completionHandler!(transferedResponse)
                }
            }
    }
    
    
    
    func transferResponseJSON(response: Response<AnyObject, NSError>) -> Response<AnyObject, NSError>{
        return response
    }
    func transferResponseData(response: Response<NSData, NSError>) -> Response<NSData, NSError>{
        return response
    }
    func transferResponseString(response: Response<String, NSError>) -> Response<String, NSError>{
        return response
    }
}