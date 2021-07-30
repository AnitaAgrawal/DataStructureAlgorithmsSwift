//
//  AppDelegate.swift
//  GraphBFS
//
//  Created by Anita Agrawal on 21/07/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let adjacencyList = AdjacencyList<String>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        createGraph()
        
        return true
    }
    
    func createGraph() {
        let singapore = adjacencyList.createVertex(data: "Singapore")
        let hongKong = adjacencyList.createVertex(data: "Hong Kong")
        let tokyo = adjacencyList.createVertex(data: "Tokyo")
        let detroit = adjacencyList.createVertex(data: "Detroit")
        let austin = adjacencyList.createVertex(data: "Austin Texas")
        let washingtonDC = adjacencyList.createVertex(data: "Washington DC")
        let sanFrancisco = adjacencyList.createVertex(data: "San Francisco")
        let seattle = adjacencyList.createVertex(data: "Seattle")

        adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: singapore,
                                                                        destinationVertex: hongKong,
                                                                        weight: 200))
        adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: singapore,
                                                                        destinationVertex: tokyo,
                                                                        weight: 500))
        adjacencyList.addEdge(edgeType: .undirected, edge: Edge<String>(sourceVertex: hongKong,
                                                                        destinationVertex: sanFrancisco,
                                                                        weight: 300))
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
                                                                        weight: 237))
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
        print("adjacencyList: \(adjacencyList.description)")
        let result = adjacencyList.breadthFirstSearch(source: singapore, destination: seattle)
        
        print("resul of: \(String(describing: result))")
        
        let lessCostPath = adjacencyList.dijkstra(source: singapore, destination: austin)
        print("resul of lessCostPath: \(String(describing: lessCostPath))")
        
        let lessCostStopPath1 = adjacencyList.dijkstra(source: singapore, destination: washingtonDC,
                                                       numberOFStops: 2)
        print("resul of lessCostStopPath1: \(String(describing: lessCostStopPath1))")
        
        let lessCostStopPath2 = adjacencyList.dijkstra(source: singapore, destination: washingtonDC,
                                                       numberOFStops: 1)
        print("resul of lessCostStopPath2: \(String(describing: lessCostStopPath2))")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

