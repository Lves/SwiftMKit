//
//  Array+Extension.swift
//  SwiftMKitDemo
//
//  Created by wei.mao on 2018/7/5.
//  Copyright © 2018年 cdts. All rights reserved.
//

import Foundation

extension Array {
    func toModel<T>(_ type: T.Type) -> T? where T : Decodable {
        guard let data = try? JSONSerialization.data(withJSONObject: self) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
