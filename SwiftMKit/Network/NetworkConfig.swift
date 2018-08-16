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
    case local, dev, gray, preProduct, product, custom
}

open class NetworkConfig {
    
    private struct Constant {
        static let Evn = "NetworkEvn"
    }
    
    private init() {
    }
    
    public static let shared = NetworkConfig()
    
    public static var Release: Bool = true
    public static var Evn: Environment {
        get {
            if Release {
                return .product
            }
            let evn = DocumentCache.shared().object(forKey: Constant.Evn) as? Int ?? Environment.product.rawValue
            return Environment(rawValue: evn) ?? Environment.product
        }
        set {
            DocumentCache.shared().setObject(newValue.rawValue as NSCoding, forKey: Constant.Evn)
        }
    }
    
}
