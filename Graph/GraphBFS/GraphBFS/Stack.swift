//
//  Stack.swift
//  GraphBFS
//
//  Created by Anita Agrawal on 21/07/21.
//

import Foundation

public struct Stack<T: Hashable> {
    public var value: [T] = []
    public var peek: T? {
        value.last
    }
    public var array: [T] {
        value.reversed()
    }
    public init () {}
    public mutating func push(_ val: T) {
        value.append(val)
    }
    public mutating func pop() -> T? {
        value.count > 0 ? value.removeLast() : nil
    }
}

