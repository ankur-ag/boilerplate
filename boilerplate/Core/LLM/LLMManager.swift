//
//  LLMManager.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI

/// Generic LLM manager - handles network communication with any LLM provider
/// Provider-specific logic should be injected via LLMServiceProtocol
@MainActor
class LLMManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: LLMError?
    @Published private(set) var currentResponse: LLMResponse?
    
    // MARK: - Dependencies
    
    private let networkManager: NetworkManaging
    private var llmService: LLMServiceProtocol?
    
    // MARK: - Initialization
    
    init(networkManager: NetworkManaging = NetworkManager()) {
        self.networkManager = networkManager
        // TODO: Inject LLM service based on app configuration
    }
    
    // MARK: - Configuration
    
    /// Set the LLM service provider (OpenAI, Anthropic, etc.)
    func configure(with service: LLMServiceProtocol) {
        self.llmService = service
        print("✅ LLMManager configured with service: \(type(of: service))")
    }
    
    /// Add a service (alias for configure for single-service architecture)
    func addService(_ service: LLMServiceProtocol) {
        configure(with: service)
    }
    
    var isConfigured: Bool {
        llmService != nil
    }
    
    // MARK: - Request Methods
    
    /// Send a prompt and get a complete response
    func sendPrompt(
        _ prompt: String,
        context: [LLMMessage] = []
    ) async throws -> LLMResponse {
        guard let service = llmService else {
            throw LLMError.serviceNotConfigured
        }
        
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let userMessage = LLMMessage(
                role: .user,
                content: prompt
            )
            
            let request = LLMRequest(
                messages: context + [userMessage],
                temperature: 0.7,
                maxTokens: 2000
            )
            
            let response = try await service.sendRequest(request)
            currentResponse = response
            return response
            
        } catch {
            let llmError = error as? LLMError ?? .networkError(error.localizedDescription)
            self.error = llmError
            throw llmError
        }
    }
    
    /// Send a prompt and stream the response
    func streamPrompt(
        _ prompt: String,
        context: [LLMMessage] = [],
        onChunk: @escaping (String) -> Void,
        onComplete: @escaping (LLMResponse) -> Void
    ) async throws {
        guard let service = llmService else {
            print("❌ LLMManager.streamPrompt: llmService is nil!")
            throw LLMError.serviceNotConfigured
        }
        
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let request = LLMRequest(
                messages: context + [LLMMessage(role: .user, content: prompt)],
                temperature: 0.7,
                maxTokens: 2000,
                stream: true
            )
            
            try await service.streamRequest(request, onChunk: onChunk, onComplete: { response in
                self.currentResponse = response
                onComplete(response)
            })
            
        } catch {
            let llmError = error as? LLMError ?? .networkError(error.localizedDescription)
            self.error = llmError
            throw llmError
        }
    }
    
    // MARK: - Helper Methods
    
    func clearError() {
        error = nil
    }
    
    func cancelCurrentRequest() {
        // TODO: Implement request cancellation
    }
}

// MARK: - LLM Service Protocol

/// Protocol that any LLM provider must implement
protocol LLMServiceProtocol {
    func sendRequest(_ request: LLMRequest) async throws -> LLMResponse
    func streamRequest(
        _ request: LLMRequest,
        onChunk: @escaping (String) -> Void,
        onComplete: @escaping (LLMResponse) -> Void
    ) async throws
}

// MARK: - Models

struct LLMRequest {
    let messages: [LLMMessage]
    let temperature: Double
    let maxTokens: Int
    let stream: Bool
    
    init(
        messages: [LLMMessage],
        temperature: Double = 0.7,
        maxTokens: Int = 2000,
        stream: Bool = false
    ) {
        self.messages = messages
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.stream = stream
    }
}

struct LLMMessage: Codable, Identifiable {
    let id: String
    let role: MessageRole
    let content: String
    let timestamp: Date
    
    init(
        id: String = UUID().uuidString,
        role: MessageRole,
        content: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

enum MessageRole: String, Codable {
    case system
    case user
    case assistant
}

struct LLMResponse: Identifiable {
    let id: String
    let content: String
    let role: MessageRole
    let timestamp: Date
    let usage: TokenUsage?
    let finishReason: String?
    
    init(
        id: String = UUID().uuidString,
        content: String,
        role: MessageRole = .assistant,
        timestamp: Date = Date(),
        usage: TokenUsage? = nil,
        finishReason: String? = nil
    ) {
        self.id = id
        self.content = content
        self.role = role
        self.timestamp = timestamp
        self.usage = usage
        self.finishReason = finishReason
    }
}

struct TokenUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
}

// MARK: - LLM Error

enum LLMError: LocalizedError {
    case serviceNotConfigured
    case networkError(String)
    case invalidResponse
    case rateLimitExceeded
    case apiKeyInvalid
    case contentFiltered
    
    var errorDescription: String? {
        switch self {
        case .serviceNotConfigured:
            return "LLM service is not configured"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from LLM service"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .apiKeyInvalid:
            return "Invalid API key"
        case .contentFiltered:
            return "Content was filtered by the LLM provider"
        }
    }
}
