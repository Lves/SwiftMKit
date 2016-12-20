//
//  MemoryCache.swift
//  SwiftMKitDemo
//
//  Created by Mao on 20/12/2016.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import PINCache

open class MemoryCache: PINMemoryCache {
    
    fileprivate static let sharedInstance = MemoryCache()
    override open class func shared() -> MemoryCache {
        return sharedInstance
    }
    
    open func getObject(forKey key: String) -> Any? {
        let optionalKey: String? = key
        if let value = object(forKey: optionalKey) {
            return value
        }
        return nil
    }
}
