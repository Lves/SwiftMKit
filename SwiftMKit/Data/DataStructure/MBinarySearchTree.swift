//
//  MBinarySearchTree.swift
//  Merak
//
//  Created by Mao on 8/18/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation

public class MBinarySearchTree<T: Comparable> {
    private(set) public var value: T
    private(set) public var parent: MBinarySearchTree?
    private(set) public var left: MBinarySearchTree?
    private(set) public var right: MBinarySearchTree?
    
    public init(value: T) {
        self.value = value
    }
    
    public convenience init(array: [T]) {
        precondition(array.count > 0)
        self.init(value: array.first!)
        for v in array.dropFirst() {
            insert(v, parent: self)
        }
    }
    
    public var isRoot: Bool {
        return parent == nil
    }
    public var isLeaf: Bool {
        return left == nil && right == nil
    }
    public var isLeftChild: Bool {
        return parent?.left === self
    }
    public var isRightChild: Bool {
        return parent?.right === self
    }
    public var hasLeftChild: Bool {
        return left != nil
    }
    public var hasRightChild: Bool {
        return right != nil
    }
    public var hasAnyChild: Bool {
        return hasLeftChild || hasRightChild
    }
    public var hasBothChildren: Bool {
        return hasLeftChild && hasRightChild
    }
}

extension MBinarySearchTree {
    
    public func insert(value: T, parent: MBinarySearchTree) {
        if value < self.value {
            if let left = left {
                left.insert(value, parent: left)
            } else {
                left = MBinarySearchTree(value: value)
                left?.parent = parent
            }
        } else {
            if let right = right {
                right.insert(value, parent: right)
            } else {
                right = MBinarySearchTree(value: value)
                right?.parent = parent
            }
        }
    }
}