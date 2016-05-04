//
//  CacheProtocol.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/4/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import UIKit

public protocol CacheProtocol {
    func addObject(name: String, data: NSData) -> String
    func addObject(name: String, image: UIImage) -> String
    func addObject(name: String, filePath: String) -> String
    
    func objectForName(name: String) -> NSData?
    func imageForName(name: String) -> UIImage?
    func clear()
}