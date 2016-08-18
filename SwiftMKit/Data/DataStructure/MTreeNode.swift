//
//  MTreeNode.swift
//  SwiftMKitDemo
//
//  Created by Mao on 8/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public class MTreeNode<T: Comparable> {
    public var value: T
    
    public var parent: MTreeNode?
    public var children = [MTreeNode<T>]()
    
    public init(value: T) {
        self.value = value
    }
    
    public func addChild(node: MTreeNode<T>) {
        children.append(node)
        node.parent = self
    }
    public func search(value: T) -> MTreeNode? {
        if value == self.value {
            return self
        }
        for child in children {
            if let found = child.search(value) {
                return found
            }
        }
        return nil
    }
}

extension MTreeNode: CustomStringConvertible {
    public var description: String {
        var s = "\(value)"
        if !children.isEmpty {
            s += " {" + children.map { $0.description }.joinWithSeparator(",") + "}"
        }
        return s
    }
}
//    /**
//     计算树的最大深度
//     
//     - parameter root:根节点
//     
//     - returns:深度
//     */
//    public func maxDepth(root: MTreeNode?) -> Int {
//        guard let root = root else { return 0 }
//        
//        return max(maxDepth(root.left), maxDepth(root.right)) + 1
//    }
//    
//    /**
//     判断一颗二叉树是否为二叉查找树
//     
//     - parameter root: 根节点
//     
//     - returns: 是否是二叉查找树
//     */
//    public func isValidBST(root: MTreeNode?) -> Bool {
//        return isValidBST(root, nil, nil)
//    }
//    private func isValidBST(node: MTreeNode?, _ min: T?, _ max: T?) -> Bool {
//        guard let node = node else { return true }
//        // 所有右子节点都必须大于根节点
//        if min != nil && node.val <= min {
//            return false
//        }
//        // 所有左子节点都必须小于根节点
//        if max != nil && node.val >= max {
//            return false
//        }
//        return isValidBST(node.left, min, node.val)
//    }
//    
//    /**
//     前序遍历(用栈实现)
//     
//     - parameter root: 根节点
//     
//     - returns: 返回前序遍历结果
//     */
//    public func preorderTraversal(root: MTreeNode?) -> [T] {
//        var res = [T]()
//        var stack = [MTreeNode]()
//        var node = root
//        
//        while !stack.isEmpty || node != nil {
//            if node != nil {
//                res.append(node!.val)
//                stack.append(node!)
//                node = node!.left
//            } else {
//                node = stack.removeLast().right
//            }
//        }
//        return res
//    }
//    
//    /**
//     层级遍历
//     
//     - parameter root: 根节点
//     
//     - returns: 返回层级遍历结果
//     */
//    public func levelOrderTraversal(root: MTreeNode?) -> [[T]] {
//        var res = [[T]]()
//        let queue = MQueue<MTreeNode<T>>()
//        
//        if let root = root {
//            queue.enqueue(root)
//        }
//        while queue.size() > 0 {
//            let size = queue.size()
//            var level = [T]()
//            
//            for _ in 1...size {
//                if let node = queue.dequeue() {
//                    level.append(node.val)
//                    if let left = node.left {
//                        queue.enqueue(left)
//                    }
//                    if let right = node.right {
//                        queue.enqueue(right)
//                    }
//                }
//                res.append(level)
//            }
//        }
//        return res
//    }
//}
