//
//  MKDataListModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit

class MKDataListModel: BaseModel {
    var title: String?
    var detail: String?
    var route: String?
    var routeSB: String?
    init(title:String, detail:String) {
        self.title = title
        self.detail = detail
        super.init()
    }
    init(title:String, detail:String, route: String, routeSB: String? = nil) {
        self.title = title
        self.detail = detail
        self.route = route
        self.routeSB = routeSB
        super.init()
    }
}