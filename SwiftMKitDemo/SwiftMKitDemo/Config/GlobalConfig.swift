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

struct BaiduConfig {
    static let ApiKey = "a5b86510c31404bead8d3308ef2b7939"
    static let UrlCities = "http://apis.baidu.com/baidunuomi/openapi/cities"
    static let UrlShops = "http://apis.baidu.com/baidunuomi/openapi/searchshops"
    static let UrlHost = "http://apis.baidu.com"
}
struct PX500Config {
    static let ConsumerKey = "zWez4W3tU1uXHH0S5zAVYX0xAh6sm0kpIZpyF1K7"
    static let UrlHost = "https://api.500px.com"
}

enum Environment: Int {
    case Dev,Product
}

struct NetworkConfig {
    static var Evn = Environment.Product
    static let PX500HostDev = PX500Config.UrlHost
    static let PX500HostProduct = PX500Config.UrlHost
    static let BaiduHostDev = BaiduConfig.UrlHost
    static let BaiduHostProduct = BaiduConfig.UrlHost
}