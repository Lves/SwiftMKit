//
//  MBinaryTree.swift
//  Merak
//
//  Created by Mao on 8/18/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

public indirect enum MBinaryTree<T> {
    case node(MBinaryTree<T>, T, MBinaryTree<T>)
    case empty
    
    public var count: Int {
        switch self {
        case let .node(left, _, right):
            return left.count + 1 + right.count
        case .empty:
            return 0
        }
    }
}

extension MBinaryTree: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .node(left, value, right):
            return "value: \(value), left = [" + left.description + "], right = [" + right.description + "]"
        case .empty:
            return ""
        }
    }
}

extension MBinaryTree {
    public func traverseInOrder(_ process: (T) -> Void) {
        if case let .node(left, value, right) = self {
            left.traverseInOrder(process)
            process(value)
            right.traverseInOrder(process)
        }
    }
    public func traversePreOrder(_ process: (T) -> Void) {
        if case let .node(left, value, right) = self {
            process(value)
            left.traversePreOrder(process)
            right.traversePreOrder(process)
        }
    }
    public func traversePostOrder(_ process: (T) -> Void) {
        if case let .node(left, value, right) = self {
            left.traversePostOrder(process)
            right.traversePostOrder(process)
            process(value)
        }
    }
}

extension MBinaryTree {
    public func invert() -> MBinaryTree {
        if case let .node(left, value, right) = self {
            return .node(right.invert(), value, left.invert())
        } else {
            return .empty
        }
    }
}
