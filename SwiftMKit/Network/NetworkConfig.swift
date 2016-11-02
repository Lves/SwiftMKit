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
    case Local,Dev,Gray,PreProduct,Product,Custom
}

public class NetworkConfig {
    
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
                return .Product
            }
            let evn = PINDiskCache.sharedCache().objectForKey(Constant.Evn) as? Int ?? Environment.Product.rawValue
            return Environment(rawValue: evn) ?? Environment.Product
        }
        set {
            PINDiskCache.sharedCache().setObject(newValue.rawValue, forKey: Constant.Evn)
        }
    }
    
}