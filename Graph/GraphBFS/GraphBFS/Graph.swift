//
//  Graph.swift
//  GraphBFS
//
//  Created by Anita Agrawal on 21/07/21.
//

import Foundation

struct Vertex<T: Hashable> {
    var data: T
}
extension Vertex: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine("\(data)".hashValue)
    }
    static public func ==(lhs: Vertex, rhs: Vertex) -> Bool {
        lhs.data == rhs.data
    }
}
extension Vertex: CustomStringConvertible {
    var description: String {
        "\(data)"
    }
}
public enum EdgeType {
    case directed, undirected
}
public struct Edge<T: Hashable> {
    var sourceVertex: Vertex<T>
    var destinationVertex: Vertex<T>
    var weight: Double?
    
    var reverse: Edge<T> {
        Edge(sourceVertex: destinationVertex, destinationVertex: sourceVertex, weight: weight)
    }
}
extension Edge: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine("\(sourceVertex)\(destinationVertex)\(weight ?? 0)".hashValue)
    }
    static public func ==(lhs: Edge, rhs: Edge) -> Bool {
        lhs.sourceVertex == rhs.sourceVertex &&
            lhs.destinationVertex == rhs.destinationVertex &&
            lhs.weight == rhs.weight
    }
}

protocol Graphable {
    associatedtype Element: Hashable
    var description: CustomStringConvertible { get }
    
    func createVertex(data: Element) -> Vertex<Element>
    func addEdge(edgeType: EdgeType, edge: Edge<Element>)
    func getWeight(source: Vertex<Element>, destination: Vertex<Element>) -> Double?
    func getEdges(source: Vertex<Element>) -> [Edge<Element>]?
}

class AdjacencyList<T: Hashable> {
    var adjacencyDict: [Vertex<T>: [Edge<T>]] = [:]
    
    init() {}
}

extension AdjacencyList: Graphable {
    var description: CustomStringConvertible {
        var result = ""
        for (vertex, edges) in adjacencyDict {
            let edgeResult = edges.reduce("") { result, edge in
                result + "\(edge.destinationVertex), "
            }
            result += "\(vertex) ---> [ \(edgeResult) ] \n"
        }
        return result
    }
    
    func createVertex(data: T) -> Vertex<T> {
        let vertex = Vertex(data: data)
        if adjacencyDict[vertex] == nil {
            adjacencyDict[vertex] = []
        }
        return vertex
    }
    
    func addEdge(edgeType: EdgeType, edge: Edge<T>) {
        adjacencyDict[edge.sourceVertex]?.append(edge)
        if edgeType == .undirected {
            let reverseEdge = edge.reverse
            adjacencyDict[reverseEdge.sourceVertex]?.append(reverseEdge)
        }
    }
    
    func getWeight(source: Vertex<T>, destination: Vertex<T>) -> Double? {
        guard let edges = adjacencyDict[source] else {return nil}
        return edges.first(where: {$0.destinationVertex == destination})?.weight
    }
    
    func getEdges(source: Vertex<T>) -> [Edge<T>]? {
        adjacencyDict[source]
    }
    
    typealias Element = T
}

enum VisitedVertexType<T: Hashable> {
    case source
    case edge(Edge<T>)
}

extension Graphable {
    func breadthFirstSearch(source: Vertex<Element>,
                            destination: Vertex<Element>) -> [Edge<Element>]? {
        let queue: Queue<Vertex<Element>> = Queue()
        queue.push(source)
        var visitedVertices: [Vertex<Element>: VisitedVertexType<Element>] = [source: .source]
        var stack = Stack<Edge<Element>>()
        
        while var visitedVertex = queue.pop() {
            if visitedVertex == destination {
                while let visitedEdge = visitedVertices[visitedVertex] {
                    if case let .edge(edge) = visitedEdge {
                        stack.push(edge)
                        visitedVertex = edge.sourceVertex
                    } else {
                        return stack.value.reversed()
                    }
                }
                return []
            }
            if let edges = getEdges(source: visitedVertex) {
                edges.forEach { edge in
                    if visitedVertices[edge.destinationVertex] == nil {
                        visitedVertices[edge.destinationVertex] = .edge(edge)
                        queue.push(edge.destinationVertex)
                    }
                }
            }
        }
        return nil
    }
    
    func getPathFor(destination: Vertex<Element>,
                    visitedVertices: [Vertex<Element>: VisitedVertexType<Element>]) -> [Edge<Element>]? {
        var visitedVertex = destination
        var stack = Stack<Edge<Element>>()
        while let visitedEdge = visitedVertices[visitedVertex],
              case let .edge(edge) = visitedEdge {
            stack.push(edge)
            visitedVertex = edge.sourceVertex
        }
        return stack.array
    }
    
    func costOfThePath(destination: Vertex<Element>,
                       visitedVertices: [Vertex<Element>: VisitedVertexType<Element>]) -> Double {
        guard let path = getPathFor(destination: destination, visitedVertices: visitedVertices)
        else { return 0}
        let cost = path.reduce(0.0) { $0 + ($1.weight ?? 0) }
        print("cost of the destination: \(destination) is \(cost)")
        return cost
    }
    
    func dijkstra(source: Vertex<Element>, destination: Vertex<Element>) -> [Edge<Element>]? {
        var visitedVertices: [Vertex<Element>: VisitedVertexType<Element>] = [source: .source]
        var queue = Heap<Vertex<Element>>(elements: []) { first, second in
            self.costOfThePath(destination: first, visitedVertices: visitedVertices) <
                self.costOfThePath(destination: second, visitedVertices: visitedVertices)
        }
        queue.enqueue(source)
        while let visitedVertex = queue.dequeueHighestPriorityElement() {
            print("visitedVertex: \(visitedVertex)")
            if visitedVertex == destination {
                return getPathFor(destination: destination, visitedVertices: visitedVertices)
            }
            if let edges = getEdges(source: visitedVertex) {
                for edge in edges where edge.weight != nil {
                    if visitedVertices[edge.destinationVertex] != nil {
                        let newPathCost = costOfThePath(destination: visitedVertex,
                                                        visitedVertices: visitedVertices) + edge.weight!
                        let oldPathCost = costOfThePath(destination: edge.destinationVertex,
                                                        visitedVertices: visitedVertices)
                        if newPathCost < oldPathCost {
                            visitedVertices[edge.destinationVertex] = .edge(edge)
                            queue.enqueue(edge.destinationVertex)
                        }
                    } else {
                        visitedVertices[edge.destinationVertex] = .edge(edge)
                        queue.enqueue(edge.destinationVertex)
                    }
                }
            }
        }
        return nil
    }
    
    func dijkstra(source: Vertex<Element>, destination: Vertex<Element>,
                  numberOFStops: Int) -> [Edge<Element>]? {
        var visitedVertices: [Vertex<Element>: VisitedVertexType<Element>] = [source: .source]
        var queue = Heap<Vertex<Element>>(elements: []) { first, second in
            self.costOfThePath(destination: first, visitedVertices: visitedVertices) <
                self.costOfThePath(destination: second, visitedVertices: visitedVertices)
        }
        queue.enqueue(source)
        while let visitedVertex = queue.dequeueHighestPriorityElement() {
            print("visitedVertex: \(visitedVertex)")
            if visitedVertex == destination {
                let paths = getPathFor(destination: destination, visitedVertices: visitedVertices) ?? []
                return (paths.count - 1) <= numberOFStops ? paths : nil
            }
            if let edges = getEdges(source: visitedVertex) {
                for edge in edges where edge.weight != nil {
                    if visitedVertices[edge.destinationVertex] != nil {
                        let newPathCost = costOfThePath(destination: visitedVertex,
                                                        visitedVertices: visitedVertices) + edge.weight!
                        let newPathStops = (getPathFor(destination: visitedVertex,
                                                       visitedVertices: visitedVertices) ?? []).count
                        let oldPathCost = costOfThePath(destination: edge.destinationVertex,
                                                        visitedVertices: visitedVertices)
                        if newPathCost < oldPathCost,
                           (edge.destinationVertex == destination ? newPathStops <= numberOFStops : newPathStops < numberOFStops) {
                            visitedVertices[edge.destinationVertex] = .edge(edge)
                            queue.enqueue(edge.destinationVertex)
                        }
                    } else {
                        visitedVertices[edge.destinationVertex] = .edge(edge)
                        queue.enqueue(edge.destinationVertex)
                    }
                }
            }
        }
        return nil
    }
}
