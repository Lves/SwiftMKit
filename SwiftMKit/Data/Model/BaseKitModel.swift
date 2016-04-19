//
//  BaseKitModel.swift
//  SwiftMKitDemo
//
//  Created by apple on 16/4/18.
//  Copyright © 2016年 cdts. All rights reserved.
//

import UIKit
import ObjectMapper

class BaseKitModel: NSObject, Mappable {
    struct ModelTypeTransfer {
        /// JSON: String -> Obj:Bool
        static let String2Bool = TransformOf<Bool, String>(fromJSON: { ($0!).toBool() }, toJSON: { $0.map { String($0) } })
        /// JSON: String -> Obj:Int
        static let String2Int = TransformOf<Int, String>(fromJSON: { Int($0!) }, toJSON: { $0.map { String($0) } })
        /// JSON: String -> Float
        static let String2Float = TransformOf<Float, String>(fromJSON: { Float($0!) }, toJSON: { $0.map { String($0) } })
        /// JSON: String -> Obj:Double
        static let String2Double = TransformOf<Double, String>(fromJSON: { Double($0!) }, toJSON: { $0.map { String($0) } })
        /// JSON: Int -> Obj:String
        static let Int2String = TransformOf<String, Int>(fromJSON: { String($0!) }, toJSON: { $0.map { Int($0)! } })
    }
    
    override init(){}
    
    required init?(_ map: Map) {
    }
    
    // Mappable
    func mapping(map: Map) {
    }

}

extension Map {
    subscript(trans: TransformOf<Bool, String>) -> (Map, TransformOf<Bool, String>) {
        return (self, trans)
    }
    subscript(trans: TransformOf<Int, String>) -> (Map, TransformOf<Int, String>) {
        return (self, trans)
    }
    subscript(trans: TransformOf<Float, String>) -> (Map, TransformOf<Float, String>) {
        return (self, trans)
    }
    subscript(trans: TransformOf<Double, String>) -> (Map, TransformOf<Double, String>) {
        return (self, trans)
    }
    subscript(trans: TransformOf<String, String>) -> (Map, TransformOf<String, String>) {
        return (self, trans)
    }
    subscript(trans: TransformOf<String, Int>) -> (Map, TransformOf<String, Int>) {
        return (self, trans)
    }
}

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}