//
//  StreamingTextView.swift
//  boilerplate
//
//  Posterized - Reusable Streaming Text Component
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Reusable component for displaying streaming text from LLM
struct StreamingTextView: View {
    let text: String
    let isStreaming: Bool
    var font: Font = .body
    var alignment: TextAlignment = .leading
    
    @State private var cursorVisible = true
    
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack(alignment: alignment == .leading ? .leading : .center, spacing: 0) {
                    Text(text + (isStreaming && cursorVisible ? "▊" : ""))
                        .font(font)
                        .textSelection(.enabled)
                        .id("streamingText")
                }
                .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
                .padding()
                .onChange(of: text) { _, _ in
                    withAnimation {
                        proxy.scrollTo("streamingText", anchor: .bottom)
                    }
                }
            }
        }
        .onAppear {
            if isStreaming {
                startCursorAnimation()
            }
        }
        .onChange(of: isStreaming) { _, streaming in
            if streaming {
                startCursorAnimation()
            }
        }
    }
    
    private func startCursorAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if !isStreaming {
                timer.invalidate()
                cursorVisible = false
            } else {
                cursorVisible.toggle()
            }
        }
    }
}

// MARK: - Streaming Text Card

struct StreamingTextCard: View {
    let title: String
    let text: String
    let isStreaming: Bool
    let onCopy: (() -> Void)?
    let onShare: (() -> Void)?
    let onRegenerate: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isStreaming {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            // Content
            if text.isEmpty && isStreaming {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Generating roast...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 40)
            } else {
                StreamingTextView(
                    text: text,
                    isStreaming: isStreaming,
                    font: .body
                )
                .frame(minHeight: 150)
            }
            
            // Actions (only show when not streaming and has content)
            if !isStreaming && !text.isEmpty {
                HStack(spacing: 16) {
                    if let onCopy = onCopy {
                        ActionButton(icon: "doc.on.doc", title: "Copy", action: onCopy)
                    }
                    
                    if let onShare = onShare {
                        ActionButton(icon: "square.and.arrow.up", title: "Share", action: onShare)
                    }
                    
                    if let onRegenerate = onRegenerate {
                        ActionButton(icon: "arrow.clockwise", title: "Regenerate", action: onRegenerate)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Action Button

private struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.accentColor.opacity(0.1))
            .foregroundColor(.accentColor)
            .cornerRadius(8)
        }
    }
}
