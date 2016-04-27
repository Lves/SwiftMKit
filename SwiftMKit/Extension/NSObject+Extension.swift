//
//  NSObject+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/21/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation
import MJExtension
import MagicalRecord

public extension NSObject {
    class public func arrayFromJson<T: NSObject>(json: Array<AnyObject>?, context: NSManagedObjectContext = NSManagedObjectContext.MR_defaultContext()) -> [T]?{
        if let jsonString = json {
            let arr = T.mj_objectArrayWithKeyValuesArray(jsonString, context:context).copy() as? Array<T>
            if arr != nil {
                var index:Int64 = 1
                let time = NSDate().timeIntervalSince1970
                for obj in arr! {
                    if let entity = obj as? BaseEntity {
                        entity.entityUpdateTime = time
                        entity.entityOrder = index
                        index += 1
                    }
                }
            }
            return arr
        }
        return nil
    }
    class public func objectFromJson<T: NSObject>(json: AnyObject?, context: NSManagedObjectContext = NSManagedObjectContext.MR_defaultContext()) -> T?{
        if let jsonString = json {
            let obj = T.mj_objectWithKeyValues(jsonString, context:context)
            if let entity = obj as? BaseEntity {
                entity.entityUpdateTime = NSDate().timeIntervalSince1970
            }
            return obj
        }
        return nil
    }

}