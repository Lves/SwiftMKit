//
//  TmpModel.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import ObjectMapper

class TmpModel: BaseModel {

}

class ADModel: BaseModel {
    var ID: Int?
    var image: String?
    var url: String?
    
    override func mapping(map: Map) {
        super.mapping(map)
        ID             <- map["id"]
        image          <- map["image"]
        url            <- map["url"]
    }
}
