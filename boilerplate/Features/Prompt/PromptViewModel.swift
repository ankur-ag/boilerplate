//
//  PromptViewModel.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI

@MainActor
class PromptViewModel: ObservableObject {
    @Published var messages: [LLMMessage] = []
    @Published var inputText: String = ""
    @Published var isStreaming: Bool = false
    @Published var currentConversation: Conversation?
    
    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isStreaming
    }
    
    func sendMessage(using llmManager: LLMManager) async {
        guard canSend else { return }
        
        let userMessage = LLMMessage(role: .user, content: inputText)
        messages.append(userMessage)
        
        let prompt = inputText
        inputText = ""
        isStreaming = true
        
        do {
            // TODO: Choose between streaming and non-streaming based on feature flag
            
            // Non-streaming example
            let response = try await llmManager.sendPrompt(prompt, context: messages)
            let assistantMessage = LLMMessage(
                role: .assistant,
                content: response.content
            )
            messages.append(assistantMessage)
            
            // TODO: Save conversation to storage
            
        } catch {
            // TODO: Show error to user
            print("Error sending message: \(error)")
        }
        
        isStreaming = false
    }
    
    func sendMessageWithStreaming(using llmManager: LLMManager) async {
        guard canSend else { return }
        
        let userMessage = LLMMessage(role: .user, content: inputText)
        messages.append(userMessage)
        
        let prompt = inputText
        inputText = ""
        isStreaming = true
        
        // Create placeholder for streaming response
        let assistantMessage = LLMMessage(role: .assistant, content: "")
        messages.append(assistantMessage)
        
        do {
            var fullResponse = ""
            
            try await llmManager.streamPrompt(
                prompt,
                context: messages,
                onChunk: { chunk in
                    fullResponse += chunk
                    if let index = self.messages.firstIndex(where: { $0.id == assistantMessage.id }) {
                        self.messages[index] = LLMMessage(
                            id: assistantMessage.id,
                            role: .assistant,
                            content: fullResponse,
                            timestamp: assistantMessage.timestamp
                        )
                    }
                },
                onComplete: { response in
                    // TODO: Save conversation to storage
                }
            )
            
        } catch {
            // TODO: Show error to user
            print("Error streaming message: \(error)")
            // Remove placeholder message on error
            messages.removeAll { $0.id == assistantMessage.id }
        }
        
        isStreaming = false
    }
    
    func startNewConversation() {
        messages = []
        currentConversation = nil
        // TODO: Create new conversation in storage
    }
    
    func loadConversation(_ conversation: Conversation) {
        currentConversation = conversation
        messages = conversation.messages
    }
}
