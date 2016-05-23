//
//  Int+Extension.swift
//  SwiftMKitDemo
//
//  Created by Mao on 4/27/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}