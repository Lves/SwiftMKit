//
//  MQueue.swift
//  SwiftMKitDemo
//
//  Created by Mao on 8/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public class MQueue<T> {
    var queue: [T]
    
    public init() {
        queue = [T]()
    }
    
    public func enqueue(object: T) {
        queue.append(object)
    }
    
    public func dequeue() -> T? {
        if !isEmpty() {
            return queue.removeFirst()
        } else {
            return nil
        }
    }
    
    public func isEmpty() -> Bool {
        return queue.isEmpty
    }
    
    public func peek() -> T? {
        return queue.first
    }
    
    func size() -> Int {
        return queue.count
    }
}