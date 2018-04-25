//
//  BaseKitModel.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/4/18.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import PINCache

class BaseKitModel: NSObject {
    override init() {
        super.init()
        
        BaseKitModelService.id = "\(type(of: self))"
    }
    override var description: String {
        // 获取属性列表
        let propertyList: [[String : Any]]?
        if let cacheList = BaseKitModelService.propertyList, cacheList.count > 0 {
            // 从缓存中取
            propertyList = cacheList
        } else {
            // 动态获取
            propertyList = SwiftReflectionTool.propertyList(obj: self)
            BaseKitModelService.propertyList = propertyList
        }
        if let propertyList = propertyList {
            var result = "[\(BaseKitModelService.id ?? "")] ==> "
            for dict in propertyList {
                let (key, _) = SwiftReflectionTool.convert(dict: dict)
                let value = self.value(forKeyPath: key) ?? ""
                let subStr = "\(key)=\(value); "
                result += subStr
            }
            return result
        }
        return ""
    }
    
    deinit {
//        print("Deinit: \(NSStringFromClass(type(of: self)))")
        BaseKitModelService.cache.removeAllObjects()
    }
}


open class BaseKitModelService {
    static let sharedInstance = BaseKitModelService()
    private init() {}
    
    static let cache = PINMemoryCache.shared()
    static var id: String? {
        didSet {
            KEY = "BaseKitModelServiceKey4\(id ?? "")"
        }
    }
    
    private static var KEY = "BaseKitModelServiceKey4"
    
    static var propertyList: [[String : Any]]? {
        get {
            let key: String? = KEY  // 多此一举！ 目的：为了不默认调用另一个无返回值的重载方法！
            if let list = cache.object(forKey: key) as? [[String: Any]] {
                return list
            }
            return nil
        }
        set {
            if let value = newValue {
                cache.setObject(value as NSCoding, forKey: KEY)
            } else {
                cache.removeObject(forKey: KEY)
            }
        }
    }
}
