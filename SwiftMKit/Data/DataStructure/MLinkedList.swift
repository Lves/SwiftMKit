//
//  MListNode.swift
//  SwiftMKitDemo
//
//  Created by Mao on 8/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public class MLinkedListNode<T: Comparable>: NSObject {
    var value: T
    var next: MLinkedListNode?
    weak var previous: MLinkedListNode?
    
    init(value: T) {
        self.value = value
    }
}

public class MLinkedList<T: Comparable> {
    public typealias Node = MLinkedListNode<T>
    private var head: Node?
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public var first: Node? {
        return head
    }
    public var last: Node? {
        if var node = head {
            while case let next? = node.next {
                node = next
            }
            return node
        } else {
            return nil
        }
    }
    
    public var count: Int {
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
    
    public func nodeAtIndex(index: Int) -> Node? {
        if index >= 0 {
            var node = head
            var i = index
            while node != nil {
                if i == 0 { return node }
                i -= 1
                node = node.next
            }
        }
    }
    
    public subscript(index: Int) -> T {
        let node = nodeAtIndex(index)
        assert(node != nil)
        return node!.value
    }
    
    public func append(value: T) {
        let newNode = Node(value: value)
        if let lastNode = last {
            newNode.previous = lastNode
            lastNode.next = newNode
        } else {
            head = newNode
        }
    }
    public func insert(value: T, atIndex index: Int) {
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
    
    private func nodesBeforeAndAfter(index: Int) -> (Node?, Node?) {
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
    
    public func removeAll() {
        head = nil
    }
    public func removeNode(node: Node) -> T {
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
    public func removeLast() -> T? {
        if let last = last {
            return removeNode(last)
        }
        return nil
    }
    public func removeAtIndex(index: Int) -> T? {
        if let node = nodeAtIndex(index) {
            return removeNode(node)
        }
        return nil
    }
    
    public func reverse() {
        var node = head
        while let currentNode = node {
            node = currentNode.next
            swap(&&currentNode.next, &currentNode.previous)
            head = currentNode
        }
    }
    
    public func map<U>(transform: T -> U) -> MLinkedList<U> {
        let result = MLinkedList<U>()
        var node = head
        while node != nil {
            result.append(transform(node!.value))
            node = node!.next
        }
        return result
    }
    
    public func filter(predicate: T -> Bool) -> MLinkedList<T> {
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
    public func hasCycle(node: Node?) -> Bool {
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

public extension MLinkedList: CustomStringConvertible {
    public var description: String {
        var s = "["
        var node = head
        while node != nil {
            s += "\(node!.value)"
            node = node!.next
            if node != nil { s+= "," }
        }
        return s + "]"
    }
}