//
//  OutputView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Generic output view for displaying LLM responses with formatting
struct OutputView: View {
    let response: LLMResponse
    @State private var isCopied: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Response Content
                Text(response.content)
                    .font(.body)
                    .textSelection(.enabled)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                // Metadata
                if let usage = response.usage {
                    metadataSection(usage: usage)
                }
                
                // Actions
                actionButtons
            }
            .padding()
        }
        .navigationTitle("Response")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func metadataSection(usage: TokenUsage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Metadata")
                .font(.headline)
            
            HStack {
                Label("\(usage.totalTokens)", systemImage: "number")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(response.timestamp.formatted(.dateTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: copyToClipboard) {
                Label(isCopied ? "Copied!" : "Copy", systemImage: isCopied ? "checkmark" : "doc.on.doc")
            }
            .buttonStyle(.bordered)
            
            Button(action: shareResponse) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.bordered)
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = response.content
        isCopied = true
        
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2s
            isCopied = false
        }
    }
    
    private func shareResponse() {
        // TODO: Implement share sheet
    }
}
