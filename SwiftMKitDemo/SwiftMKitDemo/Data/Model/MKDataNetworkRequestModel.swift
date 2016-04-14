//
//  MKDataNetworkRequestModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ObjectMapper

class MKDataNetworkRequestCityModel: BaseModel {
    var cityId: String?
    var name: String?
    var pinyin: String?
    
    required init?(_ map: Map) {
        super.init(map)
    }

    // Mappable
    override func mapping(map: Map) {
        super.mapping(map)
        cityId      <- (map["city_id"],transfromFromIntToString())
        name        <- map["city_name"]
        pinyin      <- map["city_pinyin"]
    }
    func transfromFromIntToString() -> TransformOf<String , Int>{
        return TransformOf<String , Int>.init(fromJSON: { (number) -> String? in
                if let result = number{
                    return String(result)
                }
                return nil
            }, toJSON: { (str) -> Int? in
                if let result = str{
                    return Int(result)
                }
                return nil
        })
    }

}

class MKDataNetworkRequestShopModel: BaseModel {
    var shopId: String?
    var name: String?
    var longitude: Double?
    var latitude: Double?
    var url: String?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    // Mappable
    override func mapping(map: Map) {
        super.mapping(map)
        shopId      <- map["shopId"]
        name        <- map["name"]
        longitude   <- map["longitude"]
        latitude    <- map["latitude"]
        url         <- map["url"]
    }
}
