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
    class public func arrayFromJson<T: NSObject>(_ json: Array<Any>?, page:UInt = 0, number:UInt = 20, context: NSManagedObjectContext = NSManagedObjectContext.mr_default()) -> [T]? {
        if let jsonString = json {
            let arr = T.mj_objectArray(withKeyValuesArray: jsonString, context:context).copy() as? Array<T>
            //如果是第一页，删除旧数据
            if page == 0 {
                if let entityType = T.self as? BaseKitEntity.Type {
                    let oldData = entityType.mr_findAll(with: BaseEntityProperty.predicateUpdateTimeNotNil())?.filter { (object) -> Bool in
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
                        object.mr_deleteEntity()
                    }
                    DDLogDebug("[\(NSStringFromClass(entityType))] Delete old data: \(oldData?.count ?? 0)")
                }
            }
            if arr != nil {
                var index:Int64 = 1
                let time = Date().timeIntervalSince1970
                for obj in arr! {
                    if let entity = obj as? BaseKitEntity {
                        entity.entityUpdateTime = time
                        entity.entityOrder = index + Int64(page * number)
                        index += 1
                    }
                }
            }
            return arr
        }
        return nil
    }
    class public func objectFromJson<T: NSObject>(_ json: Any?, context: NSManagedObjectContext = NSManagedObjectContext.mr_default()) -> T?{
        if let jsonString = json {
            let obj = T.mj_object(withKeyValues: jsonString, context:context)
            if let entity = obj as? BaseKitEntity {
                entity.entityUpdateTime = Date().timeIntervalSince1970
            }
            return obj
        }
        return nil
    }
    
    class func fromClassName(_ className : String) -> NSObject? {
        let className = (Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "") + "." + className
        let aClass = NSClassFromString(className) as? NSObject.Type
        return aClass?.init()
    }
    
    ///  获取完整的类名
    class func fullClassName(_ className : String) -> NSObject.Type? {
        let className = (Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "") + "." + className
        let fullName = NSClassFromString(className) as? NSObject.Type
        return fullName
    }

    class func dictToJson(_ object:[String: Any]?) -> NSString{
        
        var jsonStr : NSString = ""
        
        if  (object != nil){
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: object ?? [:], options: .prettyPrinted)
                jsonStr = NSString(data: jsonData, encoding:String.Encoding.utf8.rawValue)!
            }
            catch{
                
            }
        }
        
        return jsonStr
    }

}

public protocol Then {}

extension Then {
    func then(_ closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension NSObject: Then {}
