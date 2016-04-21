//
//  TmpModel.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit

class TmpModel: BaseModel {

}

class ADModel: BaseModel {
    var ID: Int?
    var image: String?
    var url: String?
    
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["ID":"id"]
    }
}
