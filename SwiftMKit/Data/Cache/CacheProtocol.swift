//
//  CacheProtocol.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/4/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit


public protocol CacheModelProtocol {
    var key: String { get }
    var name: String { get set }
    var filePath: NSURL { get }
    var size: Double { get }
    var mimeType : String { get set }
    var createTime: NSTimeInterval { get }
    var lastVisitTime: NSTimeInterval { get set }
    var expireTime: NSTimeInterval { get set }
    
}
public protocol CachePoolProtocol {
    var capacity: Double { get }
    var size: Double { get set }
    var basePath: NSURL { get set }
    var name: String { get set }
    
    func addData(data: NSData, name: String?) -> String
    func addImage(image: UIImage, name: String?) -> String
    func addFile(filePath: NSURL, name: String?) -> String
    
    func getData(key: String) -> NSData?
    func getImage(key: String) -> UIImage?
    
    func removeData(key: String) -> Bool
    func removeImage(key: String) -> Bool
    
    func all() -> [CacheModelProtocol]?
    
    func clear() -> Bool
}