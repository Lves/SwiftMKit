//
//  MKitDemoApiInfo.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/6/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class PX500ApiInfo: NSObject {
    class var apiBaseUrl: String {
        get {
            switch NetworkConfig.Evn {
            case .Dev:
                return NetworkConfig.PX500HostDev
            case .Product:
                return NetworkConfig.PX500HostProduct
            }
        }
    }
}

class BaiduApiInfo: NSObject {
    class var apiBaseUrl: String {
        get {
            switch NetworkConfig.Evn {
            case .Dev:
                return NetworkConfig.BaiduHostDev
            case .Product:
                return NetworkConfig.BaiduHostProduct
            }
        }
    }
}