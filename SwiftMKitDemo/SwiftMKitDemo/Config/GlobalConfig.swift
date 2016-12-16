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
    static let AppId = "0"
    
}

struct PX500Config {
    static let consumerKey = "zWez4W3tU1uXHH0S5zAVYX0xAh6sm0kpIZpyF1K7"
    static var urlHost: String {
        get {
            switch DemoNetworkConfig.Evn {
            case .dev:
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
            case .dev:
                return "http://api.budejie.com"
            default:
                return "http://api.budejie.com"
            }
        }
    }
}

class DemoNetworkConfig : NetworkConfig {
    
    fileprivate struct Constant {
        static let Station = "NetworkStation"
    }
    
    static var Station: Int {
        get {
            return PINDiskCache.shared().object(forKey: Constant.Station) as? Int ?? 0
        }
        set {
            PINDiskCache.shared().setObject(newValue as NSCoding, forKey: Constant.Station)
        }
    }
}
