//
//  NetworkConfig.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/10/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import PINCache

public enum Environment: Int {
    case local,dev,gray,preProduct,product,custom,loanDev
}

open class NetworkConfig {
    
    fileprivate struct Constant {
        static let Evn = "NetworkEvn"
    }
    
    fileprivate init() {
    }
    
    open static let shared = NetworkConfig()
    
    open static var Release: Bool = true
    open static var Evn: Environment {
        get {
            if Release {
                return .product
            }
            let evn = PINDiskCache.shared().object(forKey: Constant.Evn) as? Int ?? Environment.product.rawValue
            return Environment(rawValue: evn) ?? Environment.product
        }
        set {
            PINDiskCache.shared().setObject(newValue.rawValue as NSCoding, forKey: Constant.Evn)
        }
    }
    
}
