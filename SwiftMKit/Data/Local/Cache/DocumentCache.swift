//
//  DocumentCache.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/10/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import PINCache

public class DocumentCache: PINDiskCache {
    init(name: String) {
        super.init(name: name, rootPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!)
    }
    
    static let DocumentCacheSharedName = "PINDiskCacheShared"
    private static let sharedInstance = DocumentCache(name: DocumentCacheSharedName)
    override public class func sharedCache() -> DocumentCache {
        return sharedInstance
    }
}
