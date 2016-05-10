//
//  GlobalConfig.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/4/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import PINCache

struct GlobalConfig {
}

struct PX500Config {
    static let consumerKey = "zWez4W3tU1uXHH0S5zAVYX0xAh6sm0kpIZpyF1K7"
    static var urlHost: String {
        get {
            switch DemoNetworkConfig.Evn {
            case .Dev:
                return "https://api.500px.com"
            default:
                return "https://api.500px.com"
            }
        }
    }
}
struct BuDeJieConfig {
    static var urlHost: String {
        get {
            switch DemoNetworkConfig.Evn {
            case .Dev:
                return "http://api.budejie.com"
            default:
                return "http://api.budejie.com"
            }
        }
    }
}

class DemoNetworkConfig : NetworkConfig {
    
    private struct Constant {
        static let Point = "NetworkPoint"
    }
    
    static var Point: Int {
        get {
            return PINDiskCache.sharedCache().objectForKey(Constant.Point) as? Int ?? 0
        }
        set {
            PINDiskCache.sharedCache().setObject(newValue, forKey: Constant.Point)
        }
    }
}
