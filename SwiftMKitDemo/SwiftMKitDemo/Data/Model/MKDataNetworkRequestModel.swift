//
//  MKDataNetworkRequestModel.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/3/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import UIKit
import MagicalRecord
import MJExtension

class MKDataNetworkRequestPhotoModel: NSObject {
    var photoId: String?
    var name: String?
    var username: String?
    var userpic: String?
    var descriptionString: String?
    var imageurl: String?
    
    override static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["photoId":"id",
                "descriptionString":"description",
                "username":"user.fullname",
                "userpic":"user.userpic_url",
                "imageurl":"image_url"]
    }
}

extension PX500PhotoEntity {
    
    override public static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["photoId":"id",
                "descriptionString":"description",
                "imageUrl":"image_url"]
    }
}
extension PX500UserEntity {
    
    override public static func mj_replacedKeyFromPropertyName() -> [NSObject : AnyObject]! {
        return ["userId":"id",
                "userName":"username",
                "fullName":"fullname",
                "userPicUrl":"userpic_url"]
    }
}