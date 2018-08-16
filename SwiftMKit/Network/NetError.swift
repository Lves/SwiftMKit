//
//  NetError.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/22/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public enum StatusCode: Int {
    case `default` = 0
    case canceled = -999
    case validateFailed = -99999
    case badRequest = 400
    case unAuthorized = 401
    case loginOtherDevice = 403
    
}

open class NetError : NSError {
    open var response: HTTPURLResponse?
    open var statusCode: Int = 0
    @objc open var message: String = ""
    open static var defaultMessage = "网络异常"
    
    public init(statusCode: Int, message: String) {
        self.statusCode = statusCode
        self.message = message
        super.init(domain: "NetError", code: statusCode, userInfo: ["message":message])
        if message.length == 0 {
            self.message = NetError.defaultMessage
        }
        if message.contains("<html") {
            self.message = NetError.defaultMessage
        }
    }
    public convenience init(error: NSError){
        self.init(statusCode: error.code, message: error.description)
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    open override var description: String {
        return "StatusCode: \(statusCode) Message:\(message)"
    }
    
}
