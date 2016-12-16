//
//  MListNode.swift
//  SwiftMKitDemo
//
//  Created by Mao on 8/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

open class MLinkedListNode<T: Comparable>: NSObject {
    var value: T
    var next: MLinkedListNode?
    weak var previous: MLinkedListNode?
    
    init(value: T) {
        self.value = value
    }
}

open class MLinkedList<T: Comparable> {
    public typealias Node = MLinkedListNode<T>
    fileprivate var head: Node?
    
    open var isEmpty: Bool {
        return head == nil
    }
    
    open var first: Node? {
        return head
    }
    open var last: Node? {
        if var node = head {
            while case let next? = node.next {
                node = next
            }
            return node
        } else {
            return nil
        }
    }
    
    open var count: Int {
        if var node = head {
            var c = 1
            while case let next? = node.next {
                node = next
                c += 1
            }
            return c
        } else {
            return 0
        }
    }
    
    open func nodeAtIndex(_ index: Int) -> Node? {
        if index >= 0 {
            var node = head
            var i = index
            while node != nil {
                if i == 0 { return node }
                i -= 1
                node = node!.next
            }
            return node
        }
        return nil
    }
    
    open subscript(index: Int) -> T {
        let node = nodeAtIndex(index)
        assert(node != nil)
        return node!.value
    }
    
    open func append(_ value: T) {
        let newNode = Node(value: value)
        if let lastNode = last {
            newNode.previous = lastNode
            lastNode.next = newNode
        } else {
            head = newNode
        }
    }
    open func insert(_ value: T, atIndex index: Int) {
        let (prev, next) = nodesBeforeAndAfter(index)
        let newNode = Node(value: value)
        newNode.previous = prev
        newNode.next = next
        prev?.next = newNode
        next?.previous = newNode
        
        if prev == nil {
            head = newNode
        }
    }
    
    fileprivate func nodesBeforeAndAfter(_ index: Int) -> (Node?, Node?) {
        assert(index >= 0)
        var i = index
        var next = head
        var prev: Node?
        while next != nil && i > 0 {
            i -= 1
            prev = next
            next = next!.next
        }
        assert(i == 0)
        return (prev, next)
    }
    
    open func removeAll() {
        head = nil
    }
    open func removeNode(_ node: Node) -> T {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev
        
        node.previous = nil
        node.next = nil
        return node.value
    }
    open func removeLast() -> T? {
        if let last = last {
            return removeNode(last)
        }
        return nil
    }
    open func removeAtIndex(_ index: Int) -> T? {
        if let node = nodeAtIndex(index) {
            return removeNode(node)
        }
        return nil
    }
    
    open func reverse() {
        var node = head
        while let currentNode = node {
            node = currentNode.next
            swap(&currentNode.next, &currentNode.previous)
            head = currentNode
        }
    }
    
    open func map<U>(_ transform: (T) -> U) -> MLinkedList<U> {
        let result = MLinkedList<U>()
        var node = head
        while node != nil {
            result.append(transform(node!.value))
            node = node!.next
        }
        return result
    }
    
    open func filter(_ predicate: (T) -> Bool) -> MLinkedList<T> {
        let result = MLinkedList<T>()
        var node = head
        while node != nil {
            if predicate(node!.value) {
                result.append(node!.value)
            }
            node = node!.next
        }
        return result
    }
    /**
     检测一个链表中是否有环
     快行指针法
     
     - parameter head: 起始节点
     
     - returns: 返回是否有环
     */
    open func hasCycle(_ node: Node?) -> Bool {
        var slow = node
        var fast = node
        
        while fast != nil && fast!.next != nil {
            slow = slow!.next
            fast = fast!.next!.next
            
            if slow == fast {
                return true
            }
        }
        return false
    }
}

extension MLinkedList: CustomStringConvertible {
    public var description: String {
        var s = "["
        var node = head
        while node != nil {
            s += "\(node!.value)"
            node = node!.next
            if node != nil { s += "," }
        }
        return s + "]"
    }
}
