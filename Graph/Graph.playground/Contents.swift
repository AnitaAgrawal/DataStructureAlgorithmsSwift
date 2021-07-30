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
        
        while let visitedVertex = queue.pop() {
            if visitedVertex == destination {
                return getPathFor(destination: visitedVertex, visitedVertices: visitedVertices)
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
        return cost
    }
    
    func dijsktra(source: Vertex<Element>, destination: Vertex<Element>) -> [Edge<Element>]? {
        var visitedVertices: [Vertex<Element>: VisitedVertexType<Element>] = [source: .source]
        var queue = Heap<Vertex<Element>>(elements: []) { first, second in
            self.costOfThePath(destination: first, visitedVertices: visitedVertices) <
                self.costOfThePath(destination: second, visitedVertices: visitedVertices)
        }
        queue.enqueue(source)
        while let visitedVertex = queue.dequeueHighestPriorityElement() {
            if visitedVertex == destination {
                return getPathFor(destination: destination, visitedVertices: visitedVertices)
            }
            if let edges = getEdges(source: visitedVertex) {
                for edge in edges {
                    if case let .edge(visitedEdge) = visitedVertices[edge.destinationVertex] {
                        let newPathCost = costOfThePath(destination: visitedVertex,
                                                        visitedVertices: visitedVertices) +
                            (visitedEdge.weight ?? 0)
                        let oldPathCost = costOfThePath(destination: edge.destinationVertex,
                                                        visitedVertices: visitedVertices)
                        if newPathCost < oldPathCost {
                            queue.enqueue(edge.destinationVertex)
                            visitedVertices[edge.destinationVertex] = .edge(edge)
                        }
                    } else {
                        queue.enqueue(edge.destinationVertex)
                        visitedVertices[edge.destinationVertex] = .edge(edge)
                    }
                }
            }
        }
        return nil
    }
    
    
}

let adjacencyList = AdjacencyList<String>()
let singapore = adjacencyList.createVertex(data: "Singapore")
let hongKong = adjacencyList.createVertex(data: "Hong Kong")
let tokyo = adjacencyList.createVertex(data: "Tokyo")
let detroit = adjacencyList.createVertex(data: "Detroit")
//let austin = adjacencyList.createVertex(data: "Austin Texas")
let washingtonDC = adjacencyList.createVertex(data: "Washington DC")
let sanFrancisco = adjacencyList.createVertex(data: "San Francisco")
//let seattle = adjacencyList.createVertex(data: "Seattle")

adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: singapore,
                                                                destinationVertex: hongKong,
                                                                weight: 200))
adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: singapore,
                                                                destinationVertex: tokyo,
                                                                weight: 500))
adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: hongKong,
                                                                destinationVertex: sanFrancisco,
                                                                weight: 600))
adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: hongKong,
                                                                destinationVertex: tokyo,
                                                                weight: 250))
adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: tokyo,
                                                                destinationVertex: detroit,
                                                                weight: 450))
adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: tokyo,
                                                                destinationVertex: washingtonDC,
                                                                weight: 300))
adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: sanFrancisco,
                                                                destinationVertex: washingtonDC,
                                                                weight: 337))
/*
adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: sanFrancisco,
                                                                destinationVertex: seattle,
                                                                weight: 218))
adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: sanFrancisco,
                                                                destinationVertex: austin,
                                                                weight: 297))
adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: detroit,
                                                                destinationVertex: austin,
                                                                weight: 50))
adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: austin,
                                                                destinationVertex: washingtonDC,
                                                                weight: 292))
adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: washingtonDC,
                                                                destinationVertex: seattle,
                                                                weight: 277))
*/
//adjacencyList.description
//adjacencyList.breadthFirstSearch(source: singapore, destination: tokyo)

adjacencyList.dijsktra(source: singapore, destination: tokyo)

/*
adjacencyList.addEdge(edgeType: .directed, edge: Edge<String>(sourceVertex: singapore,
                                                                destinationVertex: hongKong,
                                                                weight: 300))
adjacencyList.addEdge(edgeType: .directed, edge: Edge<String>(sourceVertex: singapore,
                                                                destinationVertex: detroit,
                                                                weight: 500))
adjacencyList.addEdge(edgeType: .directed, edge: Edge<String>(sourceVertex: hongKong,
                                                                destinationVertex: singapore,
                                                                weight: 300))
adjacencyList.addEdge(edgeType: .directed, edge: Edge<String>(sourceVertex: hongKong,
                                                                destinationVertex: sanFrancisco,
                                                                weight: 600))
adjacencyList.addEdge(edgeType: .directed, edge: Edge<String>(sourceVertex: hongKong,
                                                                destinationVertex: tokyo,
                                                                weight: 250))
adjacencyList.addEdge(edgeType: .directed, edge: Edge<String>(sourceVertex: tokyo,
                                                                destinationVertex: detroit,
                                                                weight: 450))
adjacencyList.addEdge(edgeType: .directed, edge: Edge<String>(sourceVertex: sanFrancisco,
                                                                destinationVertex: washingtonDC,
                                                                weight: 337))
adjacencyList.addEdge(edgeType: .directed, edge: Edge<String>(sourceVertex: sanFrancisco,
                                                                destinationVertex: tokyo,
                                                               weight: 218))
 */

/*
func findTheCheapestPrice(source: Vertex<String>, destination: Vertex<String>) -> Double {
    let result = Double.greatestFiniteMagnitude
    var pathsStack = Stack<Edge<String>>()
    var resultCosts = [Double]()
    var nextSource = source
    while true {
        if let edges = adjacencyList.getEdges(source: nextSource) {
            for edge in edges {
                if edge.destinationVertex == destination {
                    let sum = pathsStack.value.reduce(0) { result, edge in
                        result + (edge.weight ?? 0)
                    }
                    resultCosts.append(sum + (edge.weight ?? 0))
                } else {
                    pathsStack.push(edge)
                    nextSource = edge.destinationVertex
                }
            }
        }
    }
    return result
}
*/



/**
 11
 [[0,3,3],[3,4,3],[4,1,3],[0,5,1],[5,1,100],[0,6,2],[6,1,100],[0,7,1],[7,8,1],[8,9,1],[9,1,1],[1,10,1],[10,2,1],[1,2,100]]
 0
 2
 4
 [Expected 11]
 */

/**
 5, [[0,1,1],[0,2,5],[1,2,1],[2,3,1],[3,4,1]], 0, 4, 2
 */
