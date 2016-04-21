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
            return arr
        }
        return nil
    }
    class public func objectFromJson<T: NSObject>(json: AnyObject?, context: NSManagedObjectContext = NSManagedObjectContext.MR_defaultContext()) -> T?{
        if let jsonString = json {
            let obj = T.mj_objectWithKeyValues(jsonString, context:context)
            return obj
        }
        return nil
    }

}