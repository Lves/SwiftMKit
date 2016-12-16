//
//  Dictionary+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

func + <K, V>(left: Dictionary<K, V>, right: Dictionary<K, V>)
    -> Dictionary<K, V>
{
    var map = Dictionary<K, V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}

extension Dictionary {
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            var v = value as? String
            if v == nil {
                if let intValue = value as? Int {
                    v = intValue.toString
                } else if let doubleValue = value as? Double {
                    v = doubleValue.toString
                }
            }
            let percentEscapedValue = (v ?? "").stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }

}
