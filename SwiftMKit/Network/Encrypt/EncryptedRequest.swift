//
//  EncryptNetworkApiClient.swift
//  SwiftMKitDemo
//
//  Created by shoron on 9/27/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import Alamofire
import NetworkEncrypt

let kNetworkMessage = "网络错误"

public class EncryptedRequest: NSObject {
    
    // MARK: property
    public var encrypt : Bool
    public var request : NSURLRequest = NSURLRequest(URL: NSURL(string: "test")!)
    public var startTime: NSDate?
    public var endTime: NSDate?
    private var aRequest : Request?
    private var requestId : Int32?
    private var encryptedTask : NSURLSessionDataTask?
    private var encryptedResponse : NSHTTPURLResponse?
    private var encryptedProgress : NSProgress?
    private var totalBytesReceived: Int64 = 0
    var uploadProgress: ((Int64, Int64, Int64) -> Void)!
    static var disableEncrypt = false
    public var progress : NSProgress? {
        get {
            if encrypt {
                return self.encryptedProgress
            } else {
                return self.aRequest!.progress
            }
        }
    }
    public var response : NSHTTPURLResponse? {
        get {
            if encrypt {
                return self.encryptedResponse
            } else {
                return self.aRequest!.response
            }
        }
    }
    public var task: NSURLSessionTask {
        get {
            if encrypt {
               return self.encryptedTask!
            } else {
               return self.aRequest!.task
            }
        }
    }
    
    // MARK:
    // MARK: init
    
    init(encrypt : Bool, URLRequest: NSURLRequest) {
        if EncryptedRequest.disableEncrypt {
            self.encrypt = false
        } else {
            self.encrypt = encrypt
        }
        
        if self.encrypt {
            self.request = URLRequest
            let tempRequest = NSURLRequest(URL: NSURL.init(string: "test")!)
            self.encryptedTask = NSURLSession.sharedSession().dataTaskWithRequest(tempRequest)
            self.encryptedTask?.resume()
        } else {
            self.aRequest = Alamofire.request(URLRequest)
        }
        super.init()
        if self.encrypt {
            observerURLSessionTaskState()
        }
    }
    
    @objc private func cancelRequest(task: NSURLSessionTask) {
        if task.isEqual(self.encryptedTask) {
            EncryptedNetworkManager.sharedEncryptedNetworkManager().cancleReuqestWithTask(self.encryptedTask)
        }
    }
    
    private func observerURLSessionTaskState() {
        if let task = self.encryptedTask {
            task.addObserver(self, forKeyPath: "state", options: .New, context: nil)
        }
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "state" {
            if let tempChange = change {
                let newStateNumber = tempChange["new"] as? NSNumber
                if let newState = newStateNumber {
                    let enumState = NSURLSessionTaskState(rawValue: newState.integerValue)
                    if enumState == .Canceling {
                        EncryptedNetworkManager.sharedEncryptedNetworkManager().cancleReuqestWithTask(self.encryptedTask)
                    }
                }
            }
            print(change)
        }
    }
    
    deinit {
        if self.encrypt {
            self.encryptedTask?.removeObserver(self, forKeyPath: "state")
        }
    }
    
    // MARK:
    // MARK: Handle request
    
    public func responseJSON(
        queue queue: dispatch_queue_t? = nil,
              options: NSJSONReadingOptions = .AllowFragments,
              completionHandler: Response<AnyObject, NSError> -> Void)
        -> Self
    {
        if encrypt {
            EncryptedNetworkManager.sharedEncryptedNetworkManager().handlerRequest(self.request, task: self.encryptedTask, complete: { (data, response, error) in
                self.dealWithSpecialCode(error, data: data)
                self.encryptedResponse = response
                let reslult = self.getJSONResult(data, response: response, error: error, options: options)
                var tempResponse = response;
                if error.code == StatusCodeForceUpgradeApp {
                    tempResponse = NSHTTPURLResponse(URL: self.request.URL!, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: nil)
                }
                let aResponse = Response.init(request: self.request, response: tempResponse, data: data, result:reslult)
                completionHandler(aResponse)
            })
            return self
        } else {
            startMonitorInfo()
            let completionWithTimeHandler: Response<AnyObject, NSError> -> Void = { tempResponse in
                self.endMonitorInfo()
                completionHandler(tempResponse)
            }
            self.aRequest = self.aRequest!.responseJSON(queue: queue, options: options, completionHandler: completionWithTimeHandler)
            return self
        }
    }
    
    public func responseString(
        queue queue: dispatch_queue_t? = nil,
              encoding: NSStringEncoding? = nil,
              completionHandler: Response<String, NSError> -> Void)
        -> Self
    {
        if encrypt {
            EncryptedNetworkManager.sharedEncryptedNetworkManager().handlerRequest(self.request, task: self.encryptedTask, complete: { (data, response, error) in
                self.dealWithSpecialCode(error, data: data)
                self.encryptedResponse = response
                let result = self.getStringResult(data, response: response, error: error, encoding: encoding)
                let aResponse = Response.init(request: self.request, response: response, data: data, result:result)
                completionHandler(aResponse)
            })
            return self
        } else {
            startMonitorInfo()
            let completionWithTimeHandler: Response<String, NSError> -> Void = { tempResponse in
                self.endMonitorInfo()
                completionHandler(tempResponse)
            }
            self.aRequest = self.aRequest?.responseString(queue: queue, encoding: encoding, completionHandler: completionWithTimeHandler)
            return self
        }
    }
    
    public func responseData(
        queue queue: dispatch_queue_t? = nil,
              completionHandler: Response<NSData, NSError> -> Void)
        -> Self
    {
        if encrypt {
            EncryptedNetworkManager.sharedEncryptedNetworkManager().handlerRequest(self.request, task: self.encryptedTask, complete: { (data, response, error) in
                self.dealWithSpecialCode(error, data: data)
                self.encryptedResponse = response
                let result = self.getDataResult(data, response: response, error: error)
                let aResponse = Response.init(request: self.request, response: response, data: data, result:result)
                completionHandler(aResponse)
            })
            return self
        } else {
            startMonitorInfo()
            let completionWithTimeHandler: Response<NSData, NSError> -> Void = { tempResponse in
                self.endMonitorInfo()
                completionHandler(tempResponse)
            }
            self.aRequest = self.aRequest?.responseData(queue: queue, completionHandler: completionWithTimeHandler)
            return self
        }
    }
    
    private func getStringResult(data: NSData?, response: NSHTTPURLResponse?, error: NSError?, encoding: NSStringEncoding?) -> Result<String, NSError> {
        guard error == nil else {
            let statusCode = error?.code ?? 0
            return .Failure(self.error(statusCode, failureReason: kNetworkMessage))
        }
        
        if let response = response where response.statusCode == 204 { return .Success("") }
        
        guard let validData = data else {
            return .Failure(self.error(Error.Code.StringSerializationFailed.rawValue, failureReason: kNetworkMessage))
        }
        
        var convertedEncoding = encoding
        
        if let encodingName = response?.textEncodingName where convertedEncoding == nil {
            convertedEncoding = CFStringConvertEncodingToNSStringEncoding(
                CFStringConvertIANACharSetNameToEncoding(encodingName)
            )
        }
        
        let actualEncoding = convertedEncoding ?? NSISOLatin1StringEncoding
        if let string = String(data: validData, encoding: actualEncoding) {
            return .Success(string)
        } else {
            return .Failure(self.error(Error.Code.StringSerializationFailed.rawValue, failureReason: kNetworkMessage))
        }
    }
    
    private func getJSONResult(data: NSData?, response: NSHTTPURLResponse?, error: NSError?, options: NSJSONReadingOptions = .AllowFragments) -> Result<AnyObject, NSError> {
        guard error == nil else {
            if error?.code == StatusCodeForceUpgradeApp {
                var sussessData = [String: AnyObject]()
                sussessData["statusCode"] = error?.code
                sussessData["errorMessage"] = kNetworkMessage
                var data = [String: AnyObject]()
                data["versionCode"] = error?.userInfo["versionCode"]
                data["downloadUrl"] = error?.userInfo["downloadUrl"]
                data["updateMessage"] = error?.userInfo["updateMessage"]
                data["forceUpgrade"] = error?.userInfo["forceUpgrade"]
                sussessData["data"] = data
                return .Success(sussessData)
            }
            let statusCode = error?.code ?? 0
            return .Failure(self.error(statusCode, failureReason: kNetworkMessage))
        }
        
        if let response = response where response.statusCode == 204 { return .Success(NSNull()) }
        
        guard let validData = data where validData.length > 0 else {
            return .Failure(self.error(Error.Code.JSONSerializationFailed.rawValue, failureReason: kNetworkMessage))
        }
        
        do {
            let JSON = try NSJSONSerialization.JSONObjectWithData(validData, options: options)
            return .Success(JSON)
        } catch {
            return .Failure(self.error(Error.Code.JSONSerializationFailed.rawValue, failureReason: kNetworkMessage))
        }
    }
    
    private func getDataResult(data: NSData?, response: NSHTTPURLResponse?, error: NSError?) -> Result<NSData, NSError> {
        guard error == nil else {
            let statusCode = error?.code ?? 0
            return .Failure(self.error(statusCode, failureReason: kNetworkMessage))
        }
        
        if let response = response where response.statusCode == 204 { return .Success(NSData()) }
        
        guard let validData = data else {
            return .Failure(self.error(Error.Code.DataSerializationFailed.rawValue, failureReason: kNetworkMessage))
        }
        
        return .Success(validData)
    }
    
    private func error(code: Int, failureReason: String) -> NSError {
        return NSError(domain: "EncryptedRequestDomain", code: code , userInfo: [NSLocalizedFailureReasonErrorKey: failureReason])
    }
    
    public func cancel() {
        if encrypt {
            EncryptedNetworkManager.sharedEncryptedNetworkManager().cancleReuqestWithTask(self.encryptedTask)
        } else {
            self.aRequest?.task.cancel()
        }
    }
    
    private func dealWithSpecialCode(error :NSError?, data: NSData?) {
        guard error != nil else {
            return
        }
        
        if error!.code == StatusCodeDisableEncrypt {
            EncryptNetworkManager.shared.disableEncrypt()
        }
    }
    
    // MARK:
    // MARK: progress
    
    public func progress(closure: ((Int64, Int64, Int64) -> Void)? = nil) -> Self {
        if encrypt {
            
        } else {
            self.aRequest?.progress(closure)
        }
        return self
    }
    
    // MARK:
    // MARK: monitor
    
    private func startMonitorInfo() {
        self.requestId = EncryptedNetworkManager.sharedEncryptedNetworkManager().requestId()
        EncryptedNetworkManager.sharedEncryptedNetworkManager().setStartTime(NSDate(), forRequestId: self.requestId!)
    }
    
    private func endMonitorInfo() {
        EncryptedNetworkManager.sharedEncryptedNetworkManager().setEndTime(NSDate(), forRequestId: self.requestId!)
    }
}
