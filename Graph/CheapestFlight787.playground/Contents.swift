import Foundation

public struct Edge {
    let source: Int
    let destination: Int
    let weight: Int
    public init(source: Int, destination: Int, weight: Int) {
        self.source = source
        self.destination = destination
        self.weight = weight
    }
}
extension Edge: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine("\(source)\(destination)\(weight)".hashValue)
    }
    static public func ==(lhs: Edge, rhs: Edge) -> Bool {
        lhs.source == rhs.source && lhs.destination == rhs.destination && lhs.weight == rhs.weight
    }
}

public class AdjacencyList {
    var adjacencyList: [Int: [Edge]] = [:]
    public init() {}
    
    public func build(_ flights: [[Int]]) {
        for flight in flights {
            let source = flight[0]
            let edge = Edge(source: source, destination: flight[1], weight: flight[2])
            var edges = adjacencyList[source] ?? []
            edges.append(edge)
            adjacencyList[source] = edges
        }
    }
    public func getEdgesFor(source: Int) -> [Edge]? {
        adjacencyList[source]
    }
}

public enum VisitedVertexType {
    case source
    case edge(Edge)
}

public class Heap {
    private var data: [Int] = []
    private var priorityFunc: (Int, Int) -> Bool
    
    public init(priorityFunc: @escaping (Int, Int) -> Bool) {
        self.priorityFunc = priorityFunc
    }
    
    private func leftChildIndexFor(parentIndex: Int) -> Int {
        2 * parentIndex + 1
    }
    private func rightChildIndexFor(parentIndex: Int) -> Int {
        2 * parentIndex + 2
    }
    private func parentIndexFor(_ child: Int) -> Int {
        child > 0 ? (child - 1) / 2 : child
    }
    private func swap(_ firstIndex: Int, _ secondIndex: Int) {
        guard firstIndex < data.count, secondIndex < data.count, firstIndex != secondIndex
        else { return }
        let temp = data[firstIndex]
        data[firstIndex] = data[secondIndex]
        data[secondIndex] = temp
    }
    private func isHigherPriorityAt(_ child: Int, than parent: Int) -> Bool? {
        guard child < data.count, parent < data.count, child != parent
        else { return nil}
        let childVertex = data[child]
        let parentVertex = data[parent]
        return priorityFunc(childVertex, parentVertex)
    }
    private func siftUp(_ child: Int) {
        let parentIndex = parentIndexFor(child)
        guard let isHigherPriority = isHigherPriorityAt(child, than: parentIndex),
        isHigherPriority else { return }
        swap(parentIndex, child)
        siftUp(parentIndex)
    }
    public func enqueue(_ element: Int) {
        data.append(element)
        let childIndex = data.count - 1
        siftUp(childIndex)
    }
    private func hightPriorityIndexFor(_ parent: Int) -> Int {
        let leftChild = leftChildIndexFor(parentIndex: parent)
        let rightChild = rightChildIndexFor(parentIndex: parent)
        var result = parent
        if let leftChildPriority = isHigherPriorityAt(leftChild, than: result), leftChildPriority {
            result = leftChild
        }
        if let rightChildPriority =  isHigherPriorityAt(rightChild, than: result), rightChildPriority {
            result = rightChild
        }
        return result
    }
    private func siftDown(_ parent: Int) {
        let higherPriorityIndex = hightPriorityIndexFor(parent)
        if higherPriorityIndex == parent {return}
        swap(parent, higherPriorityIndex)
        siftDown(higherPriorityIndex)
    }
    public func dequeue() -> Int? {
        guard data.count > 1 else { return data.count == 0 ? nil : data.removeLast()}
        swap(0, data.count - 1)
        let lastItem = data.removeLast()
        siftDown(0)
        return lastItem
    }
}

class Solution {
    func getPathFor(destination: Int, visitedVertices: [Int: VisitedVertexType]) -> [Edge] {
        var result: [Edge] = []
        var dest = destination
        while case .edge(let edge) = visitedVertices[dest] {
            result = [edge] + result
            dest = edge.source
        }
        return result
    }
    func getCostFor(destination: Int, visitedVertices: [Int: VisitedVertexType]) -> Int {
        let paths = getPathFor(destination: destination, visitedVertices: visitedVertices)
        return paths.reduce(0){$0 + $1.weight}
    }
    func findCheapestPrice(_ n: Int, _ flights: [[Int]], _ src: Int, _ dst: Int, _ k: Int) -> Int {
        let adjacencyList = AdjacencyList()
        adjacencyList.build(flights)
        var visitedVertices: [Int: VisitedVertexType] = [src: .source]
        let heap = Heap(priorityFunc: {(first, second) in
            let firstCost = self.getCostFor(destination: first, visitedVertices: visitedVertices)
            let secondCost = self.getCostFor(destination: second, visitedVertices: visitedVertices)
            return firstCost < secondCost
        })
        heap.enqueue(src)
        while let vertex = heap.dequeue() {
            print("vertex: \(vertex)")
            if vertex == dst {
                return getCostFor(destination: dst, visitedVertices: visitedVertices)
            }
            if let edges = adjacencyList.getEdgesFor(source: vertex) {
                for edge in edges {
                    if visitedVertices[edge.destination] != nil {
                        let oldCost = getCostFor(destination: edge.destination,
                                                 visitedVertices: visitedVertices)
                        let newCost = getCostFor(destination: vertex,
                                                 visitedVertices: visitedVertices) + edge.weight
                        let newPathStops = getPathFor(destination: vertex,
                                                      visitedVertices: visitedVertices).count
                        if newCost < oldCost && newPathStops <= k {
                            visitedVertices[edge.destination] = .edge(edge)
                        heap.enqueue(edge.destination)
                        }
                    } else {
                        visitedVertices[edge.destination] = .edge(edge)
                        heap.enqueue(edge.destination)
                    }
                }
            }
        }
        return -1
    }
    
}

print(Solution().findCheapestPrice(4, [[0,1,1],[0,2,5],[1,2,1],[2,3,1]], 0, 3, 1))
