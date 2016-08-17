//
//  MStack.swift
//  SwiftMKitDemo
//
//  Created by Mao on 8/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public class MStack<T> {
    var stack: [T]
    
    public init() {
        stack = [T]()
    }
    
    public func push(object: T) {
        stack.append(object)
    }
    
    public func pop() -> T? {
        if !isEmpty() {
            return stack.removeLast()
        } else {
            return nil
        }
    }
    
    public func isEmpty() -> Bool {
        return stack.isEmpty
    }
    
    public func peek() -> T? {
        return stack.last
    }
    
    public func size() -> Int {
        return stack.count
    }
}