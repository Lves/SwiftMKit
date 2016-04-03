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
}
