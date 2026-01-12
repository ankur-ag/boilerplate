//
//  PromptView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct PromptView: View {
    @StateObject private var viewModel = PromptViewModel()
    @EnvironmentObject private var llmManager: LLMManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            if viewModel.isStreaming {
                                StreamingIndicator()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                // Input Area
                inputArea
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.startNewConversation) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
    }
    
    private var inputArea: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Type a message...", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...5)
                .disabled(viewModel.isStreaming)
            
            Button(action: {
                Task {
                    await viewModel.sendMessage(using: llmManager)
                }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(viewModel.canSend ? .accentColor : .gray)
            }
            .disabled(!viewModel.canSend)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: LLMMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(backgroundColor)
                    .foregroundColor(textColor)
                    .cornerRadius(16)
                
                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
    
    private var backgroundColor: Color {
        message.role == .user ? Color.accentColor : Color.gray.opacity(0.2)
    }
    
    private var textColor: Color {
        message.role == .user ? .white : .primary
    }
}

// MARK: - Streaming Indicator

private struct StreamingIndicator: View {
    @State private var animationAmount: CGFloat = 1
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animationAmount)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: animationAmount
                        )
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(16)
            
            Spacer()
        }
        .onAppear {
            animationAmount = 1.5
        }
    }
}
