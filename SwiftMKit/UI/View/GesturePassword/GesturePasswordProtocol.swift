//
//  GesturePasswordProtocol.swift
//  SwiftMKitDemo
//
//  Created by Mao on 5/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public protocol GesturePasswordProtocol {
    var passwordKey: String { get set }
    func verify(password: String) -> Bool
    func change(password: String) -> Bool
    func exist() -> Bool
    func clear() -> Bool
}