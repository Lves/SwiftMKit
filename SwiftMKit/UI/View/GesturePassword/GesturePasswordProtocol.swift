//
//  GesturePasswordProtocol.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public protocol GesturePasswordProtocol {
    static var passwordKey: String { get set }
    static func verify(_ password: String) -> Bool
    static func change(_ password: String) -> Bool
    static func exist() -> Bool
    static func clear() -> Bool
}
