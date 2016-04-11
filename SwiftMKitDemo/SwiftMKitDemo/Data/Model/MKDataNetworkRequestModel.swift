//
//  MKDataNetworkRequestModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKDataNetworkRequestCityModel: BaseModel {
    var cityId: String
    var name: String
    var pinyin: String
    init(cityId:String, name:String, pinyin:String) {
        self.cityId = cityId
        self.name = name
        self.pinyin = pinyin
        super.init()
    }
    
//    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
//        return [
//            "cityId":"city_id",
//            "name":"city_name",
//            "pinyin":"city_pinyin",
//        ]
//    }
}

class MKDataNetworkRequestShopModel: BaseModel {
    var shopId: String
    var name: String
    var longitude: Double?
    var latitude: Double?
    var url: String
    init(shopId:String, name:String, url:String) {
        self.shopId = shopId
        self.name = name
        self.url = url
        super.init()
    }
}
