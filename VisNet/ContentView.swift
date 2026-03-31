//
//  ContentView.swift
//  VisNet
//
//  Created by Ringo Wathelet on 2026/03/31.
//
import SwiftUI
import WebKit


struct ContentView: View {

    @State private var nodes = [
        ["id": 1, "label": "Node 1"],
        ["id": 2, "label": "Node 2"]
    ]

    @State private var edges = [ ["from": 1, "to": 2] ]

    var body: some View {
        VStack {
            VisNetworkView(nodesJSON: json(nodes), edgesJSON: json(edges)) { message in
                print("---> clicked: ", message)
            }.frame(height: 400)

            Button("Add Node") {
                let id = nodes.count + 1
                nodes.append(["id": id, "label": "Node \(id)"])
                edges.append(["from": 1, "to": id])
            }.buttonStyle(.borderedProminent)
        }
    }

    private func json(_ obj: Any) -> String {
        let data = try! JSONSerialization.data(withJSONObject: obj)
        return String(data: data, encoding: .utf8)!
    }
}
