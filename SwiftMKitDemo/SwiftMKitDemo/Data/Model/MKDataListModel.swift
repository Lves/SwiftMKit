//
//  MKDataListModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import ObjectMapper

class MKDataListModel: BaseModel {
    var title: String?
    var detail: String?
    init(title:String, detail:String) {
        self.title = title
        self.detail = detail
        super.init()
    }
    
    required init?(_ map: Map) {
        super.init(map)
    }
}
