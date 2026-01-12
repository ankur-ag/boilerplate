//
//  OpenAIService.swift
//  boilerplate
//
//  Example LLM Service Implementation for OpenAI
//  Created by Ankur on 1/12/26.
//

import Foundation

/// Example OpenAI implementation of LLMServiceProtocol
/// This is a reference implementation - customize as needed
class OpenAIService: LLMServiceProtocol {
    private let apiKey: String
    private let networkManager: NetworkManaging
    private let baseURL = "https://api.openai.com/v1"
    
    init(apiKey: String, networkManager: NetworkManaging = NetworkManager()) {
        self.apiKey = apiKey
        self.networkManager = networkManager
    }
    
    func sendRequest(_ request: LLMRequest) async throws -> LLMResponse {
        let endpoint = OpenAIChatEndpoint(
            baseURL: baseURL,
            apiKey: apiKey,
            request: request
        )
        
        let openAIResponse: OpenAIChatResponse = try await networkManager.request(endpoint)
        
        guard let firstChoice = openAIResponse.choices.first else {
            throw LLMError.invalidResponse
        }
        
        return LLMResponse(
            content: firstChoice.message.content,
            role: .assistant,
            usage: TokenUsage(
                promptTokens: openAIResponse.usage.promptTokens,
                completionTokens: openAIResponse.usage.completionTokens,
                totalTokens: openAIResponse.usage.totalTokens
            ),
            finishReason: firstChoice.finishReason
        )
    }
    
    func streamRequest(
        _ request: LLMRequest,
        onChunk: @escaping (String) -> Void,
        onComplete: @escaping (LLMResponse) -> Void
    ) async throws {
        // TODO: Implement streaming using URLSessionDataDelegate
        // For now, fall back to non-streaming
        let response = try await sendRequest(request)
        onChunk(response.content)
        onComplete(response)
    }
}

// MARK: - OpenAI Endpoint

private struct OpenAIChatEndpoint: Endpoint {
    let baseURL: String
    let apiKey: String
    let request: LLMRequest
    
    var path: String {
        return "/chat/completions"
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var headers: [String: String] {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        let messages = request.messages.map { message in
            OpenAIMessage(
                role: message.role.rawValue,
                content: message.content
            )
        }
        
        let requestBody = OpenAIChatRequest(
            model: "gpt-4", // or "gpt-3.5-turbo"
            messages: messages,
            temperature: request.temperature,
            maxTokens: request.maxTokens,
            stream: request.stream
        )
        
        return try? JSONEncoder().encode(requestBody)
    }
}

// MARK: - OpenAI Models

private struct OpenAIChatRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let maxTokens: Int
    let stream: Bool
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
        case stream
    }
}

private struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

private struct OpenAIChatResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage
}

private struct OpenAIChoice: Codable {
    let index: Int
    let message: OpenAIMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index
        case message
        case finishReason = "finish_reason"
    }
}

private struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
