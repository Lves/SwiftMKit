//
//  DocumentCache.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/10/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import PINCache

open class DocumentCache: PINDiskCache {
    init(name: String) {
        super.init(name: name, rootPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .UserDomainMask, true).first!)
    }
    
    static let DocumentCacheSharedName = "PINDiskCacheShared"
    fileprivate static let sharedInstance = DocumentCache(name: DocumentCacheSharedName)
    override open class func shared() -> DocumentCache {
        return sharedInstance
    }
}
