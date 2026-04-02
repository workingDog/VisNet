//
//  ContentView.swift
//  VisNet
//
//  Created by Ringo Wathelet on 2026/03/31.
//
import SwiftUI
import SwiftVisNetwork


struct ContentView: View {
    @State private var selectedNode: Int?
    @State private var commands: [GraphCommand] = []
    @State private var currentState = GraphState(nodes: [], edges: [])

    // @State private var counter = 0
    
    var body: some View {
        VStack {
            VisNetworkView(commands: $commands) { event in
                handleEvent(event)
            }.frame(height: 400)
            
            /*
             Button("Add a node") {
             let idx = counter + 1
             let newNode = VisNode(
             id: idx,
             label: UUID().uuidString.prefix(5).uppercased(),
             group: "1"
             )
             commands.append(.addNodes([newNode]))
             counter += 1
             }
             */
            
            Button("Add a node") {
                let idx = currentState.nodes.count + 1
                var newState = currentState
                let newNode = VisNode(
                    id: idx,
                    label: UUID().uuidString.prefix(5).uppercased(),
                    group: "1"
                )
                newState.nodes.append(newNode)
                updateGraph(to: newState) // let diff handle it
            }.buttonStyle(.borderedProminent)
        }
        .onAppear {
            let nodes: [VisNode] = (1...20).map { i in
                VisNode(
                    id: i,
                    label: UUID().uuidString.prefix(5).uppercased(),
                    group: "1"
                )
            }
            
            let edges: [VisEdge] = (1...10).map { _ in
                let from = Int.random(in: 1...20)
                var to = Int.random(in: 1...20)
                while to == from {
                    to = Int.random(in: 1...20)
                }
                return VisEdge(from: from, to: to)
            }
            
            updateGraph(to: GraphState(nodes: nodes, edges: edges))
        }
    }
    
    func updateGraph(to newState: GraphState) {
        let cmds = DiffSupport.diffGraph(old: currentState, new: newState)
        currentState = newState
        commands = cmds
    }
    
    func handleEvent(_ event: GraphEvent) {
        print("---> event:", event.type, event.payload ?? "")
        if event.type == "selectNode",
           let ids = event.payload,
           let nodes = ids.nodes,
           let first = nodes.first {
            selectedNode = first
        }
    }
}
