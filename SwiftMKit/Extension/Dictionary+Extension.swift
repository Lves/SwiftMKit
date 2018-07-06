//
//  Dictionary+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/17/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

func + <K, V>(left: [K: V], right: [K: V])
    -> [K: V]
{
    var map = [K: V]()
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
                }else if let boolValue = value as? Bool {
                    v = boolValue ? "true" : "false"
                }else {
                    v = "\(value)"
                }
            }
            let percentEscapedValue = (v ?? "").stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }

    
    func toModel<T>(_ type: T.Type) -> T? where T : Decodable {
        guard let data = try? JSONSerialization.data(withJSONObject: self) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
