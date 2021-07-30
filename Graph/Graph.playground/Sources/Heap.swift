import Foundation

public struct Heap<Element> {
    private var elements: [Element]
    private let priorityFunction: (Element, Element) -> Bool
    public init(elements: [Element], priorityFunction: @escaping (Element, Element) -> Bool) {
        self.elements = elements
        self.priorityFunction = priorityFunction
        self.buildHeap()
    }
    private mutating func buildHeap() {
        guard count > 1 else { return }
        for i in stride(from: (count / 2) - 1, through: 0, by: -1) {
            siftDown(parent: i)
        }
    }
    public var count: Int {
        elements.count
    }
    public var isEmpty: Bool {
        elements.isEmpty
    }
    public var peek: Element? {
        elements.first
    }
    private func isRoot(index: Int) -> Bool {
        index == 0
    }
    private func leftChildIndex(ofParent index: Int) -> Int {
        index * 2 + 1
    }
    private func rightChildIndex(ofParent index: Int) -> Int {
        index * 2 + 2
    }
    private func parentIndex(ofChild index: Int) -> Int {
        (index - 1) / 2
    }
    
    private func isHigherPriority(at firstIndex: Int, than secondIndex: Int) -> Bool {
        return priorityFunction(elements[firstIndex], elements[secondIndex])
    }
    ///This function assumes that a parent node has a valid index in the array,
    ///checks if the child node has a valid index in the array, and
    ///then compares the priorities of the nodes at those indices,
    ///and returns a valid index for whichever node has the highest priority.
    private func highestPriorityIndex(between parentIndex: Int, and childIndex: Int) -> Int {
        guard childIndex < count, isHigherPriority(at: childIndex, than: parentIndex) else {
            return parentIndex
        }
        return childIndex
    }
    ///This function assumes that the parent node index is valid,
    ///and compares the index to both of its left and right children – if they exist.
    /// Whichever of the three has the highest priority is the index returned.
    private func highestPriorityIndex(for parent: Int) -> Int {
        let highestPriorityBetweenParentAndLeftChild = highestPriorityIndex(
            between: parent, and: leftChildIndex(ofParent: parent))
        return highestPriorityIndex(between: highestPriorityBetweenParentAndLeftChild,
                                    and: rightChildIndex(ofParent: parent))
    }
    private mutating func swapElements(firstIndex: Int, secondIndex: Int) {
        guard firstIndex != secondIndex, firstIndex < count,
              secondIndex < count else { return }
        elements.swapAt(firstIndex, secondIndex)
    }
    public mutating func enqueue(_ element: Element) {
        elements.append(element)
        if count > 1 {
            var child = count - 1
            var parent = parentIndex(ofChild: child)
            while isHigherPriority(at: child, than: parent) {
                swapElements(firstIndex: parent, secondIndex: child)
                child = parent
                parent = parentIndex(ofChild: child)
            }
        }
    }
    public mutating func dequeueHighestPriorityElement() -> Element? {
        guard !isEmpty else {return nil}
        swapElements(firstIndex: 0, secondIndex: count - 1)
        let lastItem = elements.removeLast()
        siftDown(parent: 0)
        return lastItem
    }
    private mutating func siftDown(parent: Int) {
        let highestPriorityIndex = highestPriorityIndex(for: parent)
        if highestPriorityIndex != parent {
            swapElements(firstIndex: parent, secondIndex: highestPriorityIndex)
            siftDown(parent: highestPriorityIndex)
        }
    }
}

