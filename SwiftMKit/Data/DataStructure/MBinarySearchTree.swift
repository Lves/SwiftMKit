//
//  MBinarySearchTree.swift
//  Merak
//
//  Created by Mao on 8/18/16.
//  Copyright © 2016. All rights reserved.
//

import Foundation

open class MBinarySearchTree<T: Comparable> {
    fileprivate(set) open var value: T
    fileprivate(set) open var parent: MBinarySearchTree?
    fileprivate(set) open var left: MBinarySearchTree?
    fileprivate(set) open var right: MBinarySearchTree?
    
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
    
    open var isRoot: Bool {
        return parent == nil
    }
    open var isLeaf: Bool {
        return left == nil && right == nil
    }
    open var isLeftChild: Bool {
        return parent?.left === self
    }
    open var isRightChild: Bool {
        return parent?.right === self
    }
    open var hasLeftChild: Bool {
        return left != nil
    }
    open var hasRightChild: Bool {
        return right != nil
    }
    open var hasAnyChild: Bool {
        return hasLeftChild || hasRightChild
    }
    open var hasBothChildren: Bool {
        return hasLeftChild && hasRightChild
    }
    /* How many nodes are in this subtree. Performance: O(n). */
    open var count: Int {
        return (left?.count ?? 0) + 1 + (right?.count ?? 0)
    }
}

extension MBinarySearchTree {
    /*
     Inserts a new element into the tree. You should only insert elements
     at the root, to make to sure this remains a valid binary tree!
     Performance: runs in O(h) time, where h is the height of the tree.
     */
    public func insert(_ value: T) {
        insert(value, parent: self)
    }
    public func insert(_ value: T, parent: MBinarySearchTree) {
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
    
    /*
     Deletes a node from the tree.
     Returns the node that has replaced this removed one (or nil if this was a
     leaf node). That is primarily useful for when you delete the root node, in
     which case the tree gets a new root.
     Performance: runs in O(h) time, where h is the height of the tree.
     */
    public func remove() -> MBinarySearchTree? {
        let replacement: MBinarySearchTree?
        
        if let left = left {
            if let right = right {
                replacement = removeNodeWithTwoChildren(left, right)
            } else {
                // This node only has a left child. The left child replaces the node.
                replacement = left
            }
        } else if let right = right {
            // This node only has a right child. The right child replaces the node.
            replacement = right
        } else {
            // This node has no children. We just disconnect it from its parent.
            replacement = nil
        }
        
        reconnectParentToNode(replacement)
        
        // The current node is no longer part of the tree, so clean it up.
        parent = nil
        left = nil
        right = nil
        
        return replacement
    }
    
    fileprivate func removeNodeWithTwoChildren(_ left: MBinarySearchTree, _ right: MBinarySearchTree) -> MBinarySearchTree {
        // This node has two children. It must be replaced by the smallest
        // child that is larger than this node's value, which is the leftmost
        // descendent of the right child.
        let successor = right.minimum()
        
        // If this in-order successor has a right child of its own (it cannot
        // have a left child by definition), then that must take its place.
        _ = successor.remove()
        
        // Connect our left child with the new node.
        successor.left = left
        left.parent = successor
        
        // Connect our right child with the new node. If the right child does
        // not have any left children of its own, then the in-order successor
        // *is* the right child.
        if right !== successor {
            successor.right = right
            right.parent = successor
        } else {
            successor.right = nil
        }
        
        // And finally, connect the successor node to our parent.
        return successor
    }
    
    fileprivate func reconnectParentToNode(_ node: MBinarySearchTree?) {
        if let parent = parent {
            if isLeftChild {
                parent.left = node
            } else {
                parent.right = node
            }
        }
        node?.parent = parent
    }
    /*
     Finds the "highest" node with the specified value.
     Performance: runs in O(h) time, where h is the height of the tree.
     */
    public func search(_ value: T) -> MBinarySearchTree? {
        var node: MBinarySearchTree? = self
        while case let n? = node {
            if value < n.value {
                node = n.left
            } else if value > n.value {
                node = n.right
            } else {
                return node
            }
        }
        return nil
    }
    
    /*
     // Recursive version of search
     public func search(value: T) -> BinarySearchTree? {
     if value < self.value {
     return left?.search(value)
     } else if value > self.value {
     return right?.search(value)
     } else {
     return self  // found it!
     }
     }
     */
    
    public func contains(_ value: T) -> Bool {
        return search(value) != nil
    }
    
    /*
     Returns the leftmost descendent. O(h) time.
     */
    public func minimum() -> MBinarySearchTree {
        var node = self
        while case let next? = node.left {
            node = next
        }
        return node
    }
    
    /*
     Returns the rightmost descendent. O(h) time.
     */
    public func maximum() -> MBinarySearchTree {
        var node = self
        while case let next? = node.right {
            node = next
        }
        return node
    }
    
    /*
     Calculates the depth of this node, i.e. the distance to the root.
     Takes O(h) time.
     */
    public func depth() -> Int {
        var node = self
        var edges = 0
        while case let parent? = node.parent {
            node = parent
            edges += 1
        }
        return edges
    }
    
    /*
     Calculates the height of this node, i.e. the distance to the lowest leaf.
     Since this looks at all children of this node, performance is O(n).
     */
    public func height() -> Int {
        if isLeaf {
            return 0
        } else {
            return 1 + max(left?.height() ?? 0, right?.height() ?? 0)
        }
    }
    
    /*
     Finds the node whose value precedes our value in sorted order.
     */
    public func predecessor() -> MBinarySearchTree<T>? {
        if let left = left {
            return left.maximum()
        } else {
            var node = self
            while case let parent? = node.parent {
                if parent.value < value { return parent }
                node = parent
            }
            return nil
        }
    }
    
    /*
     Finds the node whose value succeeds our value in sorted order.
     */
    public func successor() -> MBinarySearchTree<T>? {
        if let right = right {
            return right.minimum()
        } else {
            var node = self
            while case let parent? = node.parent {
                if parent.value > value { return parent }
                node = parent
            }
            return nil
        }
    }
}

// MARK: - Traversal

extension MBinarySearchTree {
    public func traverseInOrder(_ process: (T) -> Void) {
        left?.traverseInOrder(process)
        process(value)
        right?.traverseInOrder(process)
    }
    
    public func traversePreOrder(_ process: (T) -> Void) {
        process(value)
        left?.traversePreOrder(process)
        right?.traversePreOrder(process)
    }
    
    public func traversePostOrder(_ process: (T) -> Void) {
        left?.traversePostOrder(process)
        right?.traversePostOrder(process)
        process(value)
    }
    
    /*
     Performs an in-order traversal and collects the results in an array.
     */
    public func map(_ formula: (T) -> T) -> [T] {
        var a = [T]()
        if let left = left { a += left.map(formula) }
        a.append(formula(value))
        if let right = right { a += right.map(formula) }
        return a
    }
}

/*
 Is this binary tree a valid binary search tree?
 */
extension MBinarySearchTree {
    public func isBST(minValue: T, maxValue: T) -> Bool {
        if value < minValue || value > maxValue { return false }
        let leftBST = left?.isBST(minValue: minValue, maxValue: value) ?? true
        let rightBST = right?.isBST(minValue: value, maxValue: maxValue) ?? true
        return leftBST && rightBST
    }
}

// MARK: - Debugging

extension MBinarySearchTree: CustomStringConvertible {
    public var description: String {
        var s = ""
        if let left = left {
            s += "(\(left.description)) <- "
        }
        s += "\(value)"
        if let right = right {
            s += " -> (\(right.description))"
        }
        return s
    }
}

extension MBinarySearchTree: CustomDebugStringConvertible {
    public var debugDescription: String {
        var s = "value: \(value)"
        if let parent = parent {
            s += ", parent: \(parent.value)"
        }
        if let left = left {
            s += ", left = [" + left.debugDescription + "]"
        }
        if let right = right {
            s += ", right = [" + right.debugDescription + "]"
        }
        return s
    }
    
    public func toArray() -> [T] {
        return map { $0 }
    }
}
