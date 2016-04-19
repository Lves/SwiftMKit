//
//  MKDataNetworkRequestModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ObjectMapper

class MKDataNetworkRequestPhotoModel: BaseModel {
//    var shopId: String?
    var name: String?
    var username: String?
    var userpic: String?
    var descriptionString: String?
    var imageurl: String?
//    var longitude: Double?
//    var latitude: Double?
//    var url: String?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    // Mappable
    override func mapping(map: Map) {
        super.mapping(map)
//        shopId      <- map["shopId"]
        name                <- map["name"]
        descriptionString   <- map["description"]
        username            <- map["user.fullname"]
        userpic             <- map["user.userpic_url"]
        imageurl            <- map["image_url"]
//        longitude   <- map["longitude"]
//        latitude    <- map["latitude"]
//        url         <- map["url"]
    }
}
