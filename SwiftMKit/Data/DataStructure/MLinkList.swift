//
//  MListNode.swift
//  SwiftMKitDemo
//
//  Created by Mao on 8/16/16.
//  Copyright © 2016 cdts. All rights reserved.
//

import Foundation

public class MLinkedListNode<T: Comparable>: NSObject {
    var val: T
    var next: MLinkedListNode?
    var prev: MLinkedListNode?
    private var linkedList: MLinkedList<T>?
    
    init(_ val: T, linkedList: MLinkedList<T>? = nil) {
        self.val = val
        self.linkedList = linkedList
        super.init()
    }
    
    public func insertAfter(node: MLinkedListNode) {
        node.prev = self
        if let next = self.next {
            node.next = next
        } else {
            self.linkedList?.tail = node
        }
        self.next = node
        self.linkedList?.count += 1
        self.linkedList?.didAppend(self)
    }
    public func insertBefore(node: MLinkedListNode) {
        node.next = self
        node.prev = self.prev
        self.prev = node
        self.linkedList?.count += 1
        self.linkedList?.didAppend(self)
    }
    public func remove() {
        if self.next == nil {
            self.linkedList?.tail = self.prev
        }
        if self.prev == nil {
            self.linkedList?.head = self.next
        }
        self.linkedList?.count -= 1
        self.prev?.next = self.next
        self.linkedList?.didRemove(self)
    }
}

public class MLinkedList<T: Comparable>: ArrayLiteralConvertible {
    public typealias Element = T
    public typealias Index = MLinkedListNode<T>
    public var count: UInt = 0
    var head: MLinkedListNode<T>?
    var tail: MLinkedListNode<T>?
    
    private func didAppend(node: MLinkedListNode<T>) {}
    private func didRemove(node: MLinkedListNode<T>) {}
    
    public subscript(index: UInt) -> T? {
        return self.node(forIndex: index)?.val
    }
    
    public required convenience init(arrayLiteral elements: Element...) {
        self.init()
        
        for item in elements {
            self.appendToTail(item)
        }
    }
    
    public func node(forIndex index: UInt) -> MLinkedListNode<T>? {
        if index == self.count-1 {
            return self.tail
        } else if index < self.count/2 {
            var idx: UInt = 0
            var node = self.head
            while let n = node?.next {
                node = n
                if idx == index {
                    return n
                } else {
                    idx += 1
                }
            }
        } else {
            var idx: UInt = self.count-1
            var node = self.tail
            while let n = node?.prev {
                node = n
                if idx == index {
                    return n
                } else {
                    idx -= 1
                }
            }
        }
        return nil
    }
    
    /**
     尾插法
     
     - parameter val:插入节点
     */
    public func appendToTail(val: T) {
        let node = MLinkedListNode(val)
        if tail == nil {
            tail = node
            head = node
            self.didAppend(node)
        } else {
            tail!.insertAfter(node)
        }
    }
    
    /**
     头插法
     
     - parameter val:插入节点
     */
    public func appendToHead(val: T) {
        let node = MLinkedListNode(val)
        if head == nil {
            head = node
            tail = node
            self.didAppend(node)
        } else {
            head!.insertBefore(node)
        }
    }
    
    public func remove(atIndex index: UInt) {
        self.node(forIndex: index)?.remove()
    }
    public func removeFirst() -> T? {
        let node = self.head
        node?.remove()
        return node?.val
    }
    
    public func removeLast() -> T? {
        let node = self.tail
        node?.remove()
        return node?.val
    }
    public func removeAll() {
        self.head = nil
        self.tail = nil
        self.count = 0
    }
    
    /**
     检测一个链表中是否有环
     快行指针法
     
     - parameter head: 起始节点
     
     - returns: 返回是否有环
     */
    public func hasCycle(head: MLinkedListNode<T>?) -> Bool {
        var slow = head
        var fast = head
        
        while fast != nil && fast!.next != nil {
            slow = slow!.next
            fast = fast!.next!.next
            
            if slow == fast {
                return true
            }
        }
        return false
    }
    
    /**
     删除链表中倒数第n个节点
     例：1->2->3->4->5，n = 2。返回1->2->3->5
     - parameter head: 链表头节点
     - parameter n:    删除位置
     - defaultValue n: 默认值
     
     - returns: 返回链表
     */
    public func removeNthFromEnd(head: MLinkedListNode<T>?, _ n: Int, _ defaultValue: T) -> MLinkedListNode<T>? {
        guard let head = head else { return nil }
        
        let dummy = MLinkedListNode<T>(defaultValue)
        dummy.next = head
        var prev: MLinkedListNode? = dummy
        var post: MLinkedListNode? = dummy
        
        // 设置后一个节点初始位置
        for _ in 0..<n {
            if post == nil {
                break
            }
            post = post!.next
        }
        // 同时移动前后节点
        while post != nil && post!.next != nil {
            prev = prev!.next
            post = post!.next
        }
        // 删除节点
        prev!.next = prev!.next!.next
        return dummy.next
    }
}