//
//  MBinaryTree.swift
//  Merak
//
//  Created by Mao on 8/18/16.
//  Copyright © 2016 jimubox. All rights reserved.
//

import Foundation

public indirect enum MBinaryTree<T> {
    case Node(MBinaryTree<T>, T, MBinaryTree<T>)
    case Empty
    
    public var count: Int {
        switch self {
        case let .Node(left, _, right):
            return left.count + 1 + right.count
        case .Empty:
            return 0
        }
    }
}

extension MBinaryTree: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .Node(left, value, right):
            return "value: \(value), left = [" + left.description + "], right = [" + right.description + "]"
        case .Empty:
            return ""
        }
    }
}

extension MBinaryTree {
    public func traverseInOrder(@noescape process: T -> Void) {
        if case let .Node(left, value, right) = self {
            left.traverseInOrder(process)
            process(value)
            right.traverseInOrder(process)
        }
    }
    public func traversePreOrder(@noescape process: T -> Void) {
        if case let .Node(left, value, right) = self {
            process(value)
            left.traversePreOrder(process)
            right.traversePreOrder(process)
        }
    }
    public func traversePostOrder(@noescape process: T -> Void) {
        if case let .Node(left, value, right) = self {
            left.traversePostOrder(process)
            right.traversePostOrder(process)
            process(value)
        }
    }
}

extension MBinaryTree {
    public func invert() -> MBinaryTree {
        if case let .Node(left, value, right) = self {
            return .Node(right.invert(), value, left.invert())
        } else {
            return .Empty
        }
    }
}