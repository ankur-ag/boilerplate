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
        // Use GPT-4 Vision if message contains images
        let hasImages = request.messages.contains { $0.hasImages }
        
        let endpoint = OpenAIChatEndpoint(
            baseURL: baseURL,
            apiKey: apiKey,
            request: request,
            useVision: hasImages
        )
        
        let openAIResponse: OpenAIChatResponse = try await networkManager.request(endpoint)
        
        guard let firstChoice = openAIResponse.choices.first,
              let content = firstChoice.message.content, !content.isEmpty else {
            throw LLMError.invalidResponse
        }
        
        return LLMResponse(
            content: content,
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
    let useVision: Bool
    
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
        if useVision {
            // Use vision-compatible message format
            let messages = request.messages.map { message -> OpenAIVisionMessage in
                if message.hasImages {
                    // Create content array with text and images
                    var contentParts: [OpenAIContentPart] = []
                    
                    // Add text content
                    if !message.content.isEmpty {
                        contentParts.append(OpenAIContentPart(
                            type: "text",
                            text: message.content
                        ))
                    }
                    
                    // Add image attachments
                    for attachment in message.attachments where attachment.type == .image {
                        if let base64Data = attachment.base64Data {
                            contentParts.append(OpenAIContentPart(
                                type: "image_url",
                                imageUrl: OpenAIImageURL(
                                    url: "data:\(attachment.mimeType);base64,\(base64Data)"
                                )
                            ))
                        }
                    }
                    
                    return OpenAIVisionMessage(
                        role: message.role.rawValue,
                        content: contentParts
                    )
                } else {
                    // Text-only message
                    return OpenAIVisionMessage(
                        role: message.role.rawValue,
                        content: [OpenAIContentPart(type: "text", text: message.content)]
                    )
                }
            }
            
            let requestBody = OpenAIVisionRequest(
                model: "gpt-4-vision-preview", // or "gpt-4o"
                messages: messages,
                temperature: request.temperature,
                maxTokens: request.maxTokens
            )
            
            return try? JSONEncoder().encode(requestBody)
        } else {
            // Standard text-only format
            let messages = request.messages.map { message in
                OpenAIMessage(
                    role: message.role.rawValue,
                    content: message.content
                )
            }
            
            let requestBody = OpenAIChatRequest(
                model: "gpt-3.5-turbo", // Use gpt-3.5-turbo for faster responses
                messages: messages,
                temperature: request.temperature,
                maxTokens: request.maxTokens,
                stream: false // Disable streaming to avoid SSE parsing
            )
            
            return try? JSONEncoder().encode(requestBody)
        }
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
    let content: String?
    let refusal: String?
    let annotations: [String]?
    
    init(role: String, content: String) {
        self.role = role
        self.content = content
        self.refusal = nil
        self.annotations = nil
    }
}

private struct OpenAIChatResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage
    let serviceTier: String?
    let systemFingerprint: String?
    
    enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case serviceTier = "service_tier"
        case systemFingerprint = "system_fingerprint"
    }
}

private struct OpenAIChoice: Codable {
    let index: Int
    let message: OpenAIMessage
    let finishReason: String?
    let logprobs: String?
    
    enum CodingKeys: String, CodingKey {
        case index
        case message
        case finishReason = "finish_reason"
        case logprobs
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        index = try container.decode(Int.self, forKey: .index)
        message = try container.decode(OpenAIMessage.self, forKey: .message)
        finishReason = try? container.decode(String.self, forKey: .finishReason)
        logprobs = try? container.decode(String.self, forKey: .logprobs)
    }
}

private struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    let promptTokensDetails: TokenDetails?
    let completionTokensDetails: TokenDetails?
    
    struct TokenDetails: Codable {
        let cachedTokens: Int?
        let audioTokens: Int?
        let reasoningTokens: Int?
        let acceptedPredictionTokens: Int?
        let rejectedPredictionTokens: Int?
        
        enum CodingKeys: String, CodingKey {
            case cachedTokens = "cached_tokens"
            case audioTokens = "audio_tokens"
            case reasoningTokens = "reasoning_tokens"
            case acceptedPredictionTokens = "accepted_prediction_tokens"
            case rejectedPredictionTokens = "rejected_prediction_tokens"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case promptTokensDetails = "prompt_tokens_details"
        case completionTokensDetails = "completion_tokens_details"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Provide default values if fields are missing
        promptTokens = (try? container.decode(Int.self, forKey: .promptTokens)) ?? 0
        completionTokens = (try? container.decode(Int.self, forKey: .completionTokens)) ?? 0
        totalTokens = (try? container.decode(Int.self, forKey: .totalTokens)) ?? 0
        promptTokensDetails = try? container.decode(TokenDetails.self, forKey: .promptTokensDetails)
        completionTokensDetails = try? container.decode(TokenDetails.self, forKey: .completionTokensDetails)
    }
}

// MARK: - Vision API Models

private struct OpenAIVisionRequest: Codable {
    let model: String
    let messages: [OpenAIVisionMessage]
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxTokens = "max_tokens"
    }
}

private struct OpenAIVisionMessage: Codable {
    let role: String
    let content: [OpenAIContentPart]
}

private struct OpenAIContentPart: Codable {
    let type: String
    let text: String?
    let imageUrl: OpenAIImageURL?
    
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageUrl = "image_url"
    }
    
    init(type: String, text: String? = nil, imageUrl: OpenAIImageURL? = nil) {
        self.type = type
        self.text = text
        self.imageUrl = imageUrl
    }
}

private struct OpenAIImageURL: Codable {
    let url: String
}
