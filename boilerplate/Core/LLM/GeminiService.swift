//
//  GeminiService.swift
//  boilerplate
//
//  Gemini API service for text generation
//  Created by Ankur on 1/12/26.
//

import Foundation

/// Gemini API service for text generation (roasts)
class GeminiService: LLMServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta"
    private let model = "gemini-flash-latest"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func sendRequest(_ request: LLMRequest) async throws -> LLMResponse {
        let endpoint = "\(baseURL)/models/\(model):generateContent?key=\(apiKey)"
        let maskedKey = apiKey.count > 8 ? String(apiKey.prefix(4)) + "..." + String(apiKey.suffix(4)) : "Present"
        print("📤 Gemini Request URL: \(baseURL)/models/\(model):generateContent?key=\(maskedKey)")
        
        guard let url = URL(string: endpoint) else {
            throw LLMError.networkError("Invalid URL")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build Gemini request
        let geminiRequest = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [
                        GeminiPart(text: buildPromptText(from: request))
                    ]
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: request.temperature,
                maxOutputTokens: request.maxTokens
            )
        )
        
        let requestData = try JSONEncoder().encode(geminiRequest)
        if let requestString = String(data: requestData, encoding: .utf8) {
            print("📤 Gemini Request Body: \(requestString)")
        }
        urlRequest.httpBody = requestData
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.networkError("Invalid response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Gemini API Response (\(httpResponse.statusCode)): \(errorMessage)")
            throw LLMError.networkError("Gemini API error (\(httpResponse.statusCode)): \(errorMessage)")
        }
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Gemini API Response (Success): \(String(responseString.prefix(500)))...")
        }
        
        let geminiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        guard let firstCandidate = geminiResponse.candidates.first,
              let firstPart = firstCandidate.content.parts.first,
              let text = firstPart.text else {
            throw LLMError.invalidResponse
        }
        
        return LLMResponse(content: text)
    }
    
    func streamRequest(_ request: LLMRequest, onChunk: @escaping (String) -> Void, onComplete: @escaping (LLMResponse) -> Void) async throws {
        let maskedKey = apiKey.count > 8 ? String(apiKey.prefix(4)) + "..." + String(apiKey.suffix(4)) : "Present"
        let endpoint = "\(baseURL)/models/\(model):streamGenerateContent?key=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw LLMError.networkError("Invalid URL")
        }
        print("📤 Gemini Stream Request URL: \(baseURL)/models/\(model):streamGenerateContent?key=\(maskedKey)")
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build Gemini request
        let geminiRequest = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [
                        GeminiPart(text: buildPromptText(from: request))
                    ]
                )
            ],
            generationConfig: GeminiGenerationConfig(
                temperature: request.temperature,
                maxOutputTokens: request.maxTokens
            )
        )
        
        let requestData = try JSONEncoder().encode(geminiRequest)
        if let requestString = String(data: requestData, encoding: .utf8) {
            print("📤 Gemini Stream Request Body: \(requestString)")
        }
        urlRequest.httpBody = requestData
        
        let (bytes, response) = try await URLSession.shared.bytes(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.networkError("Invalid response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            var errorBody = ""
            for try await line in bytes.lines {
                errorBody += line
            }
            print("❌ Gemini Stream API Response (\(httpResponse.statusCode)): \(errorBody)")
            throw LLMError.networkError("Gemini API error (\(httpResponse.statusCode)): \(errorBody)")
        }
        
        var fullText = ""
        
        for try await line in bytes.lines {
            // Gemini streams JSON objects, one per line
            guard !line.isEmpty else { continue }
            
            // Clean up the line: it might start with [, ], or end with , in a JSON array stream
            var cleanedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanedLine.hasPrefix("[") { cleanedLine.removeFirst() }
            if cleanedLine.hasSuffix("]") { cleanedLine.removeLast() }
            if cleanedLine.hasSuffix(",") { cleanedLine.removeLast() }
            
            guard !cleanedLine.isEmpty else { continue }
            
            if let data = cleanedLine.data(using: .utf8) {
                do {
                    let streamResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
                    if let candidate = streamResponse.candidates.first,
                       let part = candidate.content.parts.first,
                       let text = part.text {
                        fullText += text
                        print("📥 Gemini Stream Chunk: \(text)")
                        await MainActor.run {
                            onChunk(text)
                        }
                    }
                } catch {
                    print("⚠️ Gemini Stream Decoding Error: \(error). Raw line: \(line)")
                }
            }
        }
        
        await MainActor.run {
            onComplete(LLMResponse(content: fullText))
        }
    }
    
    private func buildPromptText(from request: LLMRequest) -> String {
        var promptText = ""
        
        // Add context messages
        for message in request.messages {
            let role = message.role == .user ? "User" : "Assistant"
            promptText += "\(role): \(message.content)\n\n"
        }
        
        return promptText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Gemini API Models

private struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let generationConfig: GeminiGenerationConfig?
}

private struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

private struct GeminiPart: Codable {
    let text: String?
}

private struct GeminiGenerationConfig: Codable {
    let temperature: Double?
    let maxOutputTokens: Int?
}

private struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]
}

private struct GeminiCandidate: Codable {
    let content: GeminiContent
}
