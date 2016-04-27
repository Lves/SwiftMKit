//
//  NetError.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/22/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public enum StatusCode: Int {
    case Default = 0
    case Canceled = -999
}

public class NetError : NSError {
    public var statusCode: Int = 0
    public var message: String = ""
    init(statusCode: Int, message: String) {
        self.statusCode = statusCode
        self.message = message
        super.init(domain: "NetError", code: statusCode, userInfo: ["message":message])
    }
    convenience init(error: NSError){
        self.init(statusCode: error.code, message: error.description)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}