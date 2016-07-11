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
    class public func arrayFromJson<T: NSObject>(json: Array<AnyObject>?, page:UInt = 0, number:UInt = 20, context: NSManagedObjectContext = NSManagedObjectContext.MR_defaultContext()) -> [T]?{
        if let jsonString = json {
            let arr = T.mj_objectArrayWithKeyValuesArray(jsonString, context:context).copy() as? Array<T>
            //如果是第一页，删除旧数据
            if page == 0 {
                if let entityType = T.self as? BaseKitEntity.Type {
                    let oldData = entityType.MR_findAllWithPredicate(BaseEntityProperty.predicateUpdateTimeNotNil())?.filter { (object) -> Bool in
                        if arr == nil {
                            return true
                        }
                        if let tobject = object as? T {
                            return !arr!.contains(tobject)
                        } else {
                            return true
                        }
                    }
                    let _ = oldData?.map { (object) -> Void in
                        object.MR_deleteEntity()
                    }
                    DDLogDebug("[\(NSStringFromClass(entityType))] Delete old data: \(oldData?.count)")
                }
            }
            if arr != nil {
                var index:Int64 = 1
                let time = NSDate().timeIntervalSince1970
                for obj in arr! {
                    if let entity = obj as? BaseKitEntity {
                        entity.entityUpdateTime = time
                        entity.entityOrder = index + Int(page * number)
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
            if let entity = obj as? BaseKitEntity {
                entity.entityUpdateTime = NSDate().timeIntervalSince1970
            }
            return obj
        }
        return nil
    }
    
    class func fromClassName(className : String) -> NSObject? {
        let className = (NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String ?? "") + "." + className
        let aClass = NSClassFromString(className) as? NSObject.Type
        return aClass?.init()
    }
    
    ///  获取完整的类名
    class func fullClassName(className : String) -> NSObject.Type? {
        let className = (NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String ?? "") + "." + className
        let fullName = NSClassFromString(className) as? NSObject.Type
        return fullName
    }


}

public protocol Then {}

extension Then {
    func then(closure: Self -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: Then {}