//
//  VisNetworkView.swift
//  VisNet
//
//  Created by Ringo Wathelet on 2026/03/31.
//
import SwiftUI
import WebKit
import Foundation

#if os(macOS)
typealias PlatformViewRepresentable = NSViewRepresentable
#else
typealias PlatformViewRepresentable = UIViewRepresentable
#endif


struct VisNetworkView: PlatformViewRepresentable {

    var nodesJSON: String
    var edgesJSON: String
    var onMessage: (Any) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onMessage: onMessage)
    }

    // MARK: - Platform-specific creation

    #if os(macOS)
    func makeNSView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        updateWebView(webView, context: context)
    }
    #else
    func makeUIView(context: Context) -> WKWebView {
        makeWebView(context: context)
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        updateWebView(webView, context: context)
    }
    #endif

    // MARK: - Shared logic

    private func makeWebView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "callback")

        let webView = WKWebView(frame: .zero, configuration: config)

        if let url = Bundle.main.url(forResource: "network", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }

        context.coordinator.webView = webView
        return webView
    }

    private func updateWebView(_ webView: WKWebView, context: Context) {
        context.coordinator.pendingNodes = nodesJSON
        context.coordinator.pendingEdges = edgesJSON
        context.coordinator.trySend()
    }

    // MARK: - Coordinator (shared)

    final class Coordinator: NSObject, WKScriptMessageHandler {

        weak var webView: WKWebView?

        var isReady = false
        var pendingNodes: String?
        var pendingEdges: String?

        let onMessage: (Any) -> Void

        init(onMessage: @escaping (Any) -> Void) {
            self.onMessage = onMessage
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {

            guard let dict = message.body as? [String: Any],
                  let type = dict["type"] as? String else {
                return
            }

            if type == "ready" {
                isReady = true
                trySend()
            } else {
                onMessage(dict)
            }
        }

        func trySend() {
            guard isReady,
                  let webView,
                  let nodes = pendingNodes,
                  let edges = pendingEdges else { return }

            let js = "setGraph(\(nodes), \(edges));"

            webView.evaluateJavaScript(js) { _, error in
                if let error {
                    print("JS error:", error)
                }
            }
        }
    }
}
