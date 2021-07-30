//
//  Queue.swift
//  GraphBFS
//
//  Created by Anita Agrawal on 21/07/21.
//

import Foundation

fileprivate class QueueLinkList<T> {
    var val: T?
    var next: QueueLinkList<T>?
    fileprivate init(_ val: T, next: QueueLinkList? = nil) {
        self.val = val
        self.next = next
    }
}

public class Queue<T> {
    fileprivate var head: QueueLinkList<T>?
    fileprivate var last: QueueLinkList<T>?
    public var size: Int = 0
    public init() {}
    
    public func push(_ element: T) {
        if head == nil {
            head = QueueLinkList(element)
            last = head
        } else {
            last?.next = QueueLinkList(element)
            last = last?.next
        }
        size += 1
    }
    
    public func pop() -> T? {
        let headPop = head
        head = head?.next
        size -= 1
        return headPop?.val
    }
}

