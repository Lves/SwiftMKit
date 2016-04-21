//
//  GlobalConfig.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/4/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

struct GlobalConfig {
}

struct PX500Config {
    static let ConsumerKey = "zWez4W3tU1uXHH0S5zAVYX0xAh6sm0kpIZpyF1K7"
    static let UrlHost = "https://api.500px.com"
}
struct BuDeJieConfig {
    static let UrlHost = "http://api.budejie.com"
}
enum Environment: Int {
    case Dev,Product
}

struct NetworkConfig {
    static var Evn = Environment.Product
    static let PX500HostDev = PX500Config.UrlHost
    static let PX500HostProduct = PX500Config.UrlHost
    static let BuDeJieHost = BuDeJieConfig.UrlHost
}