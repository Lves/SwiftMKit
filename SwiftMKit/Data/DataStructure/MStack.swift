//
//  MStack.swift
//  SwiftMKitDemo
//
//  Created by Mao on 8/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public struct MStack<T> {
    private var array = [T]()
    
    public mutating func push(element: T) {
        array.append(element)
    }
    
    public mutating func pop() -> T? {
        return array.popLast()
    }
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public func peek() -> T? {
        return array.last
    }
}

extension MStack: SequenceType {
    public func generate() -> AnyGenerator<T> {
        var curr = self
        return AnyGenerator {
            _ -> T? in
            return curr.pop()
        }
    }
}