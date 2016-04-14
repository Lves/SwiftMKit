//
//  BaseModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ObjectMapper

class BaseModel: NSObject, Mappable {
    required init?(_ map: Map) {
    }
    override init(){}
    
    // Mappable
    func mapping(map: Map) {
    }
}
