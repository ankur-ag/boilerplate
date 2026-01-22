//
//  ImageGenerationService.swift
//  boilerplate
//
//  Image generation service supporting multiple providers
//  Created by Ankur on 1/12/26.
//

import Foundation
import UIKit

// MARK: - Image Generation Service Protocol

protocol ImageGenerationServiceProtocol {
    func generateImage(prompt: String, style: ImageStyle) async throws -> GeneratedImage
}

// MARK: - Image Generation Manager

@MainActor
class ImageGenerationManager: ObservableObject {
    @Published private(set) var isGenerating: Bool = false
    @Published private(set) var error: ImageGenerationError?
    
    private var service: ImageGenerationServiceProtocol?
    
    init() {}
    
    func configure(with service: ImageGenerationServiceProtocol) {
        self.service = service
    }
    
    func generateImage(prompt: String, style: ImageStyle = .posterized) async throws -> GeneratedImage {
        guard let service = service else {
            throw ImageGenerationError.serviceNotConfigured
        }
        
        isGenerating = true
        error = nil
        
        defer {
            isGenerating = false
        }
        
        do {
            let image = try await service.generateImage(prompt: prompt, style: style)
            return image
        } catch {
            let imageError = error as? ImageGenerationError ?? .generationFailed(error.localizedDescription)
            self.error = imageError
            throw imageError
        }
    }
}

// MARK: - Gemini Nano Image Generation Service

class GeminiImageGenerationService: ImageGenerationServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta"
    
    // Image size settings - optimized for memes (small, cost-effective)
    private let imageWidth = 512   // Small size for memes
    private let imageHeight = 512  // Square format
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateImage(prompt: String, style: ImageStyle) async throws -> GeneratedImage {
        // Build the enhanced prompt for Gemini
        let enhancedPrompt = buildImagePrompt(userPrompt: prompt, style: style)
        
        // Note: Gemini API (generativelanguage.googleapis.com) does not support image generation
        // For image generation, you need to use:
        // 1. Vertex AI Imagen API (requires Google Cloud project)
        // 2. Third-party services (Stability AI, DALL-E, etc.)
        // 3. For now, we'll use Gemini to generate a text-based meme description
        
        // Use Gemini Pro to generate a detailed image description
        let maskedKey = apiKey.count > 8 ? String(apiKey.prefix(4)) + "..." + String(apiKey.suffix(4)) : "***"
        let endpoint = "\(baseURL)/models/gemini-3-pro-image-preview:generateContent?key=\(apiKey)"
        
        print("🌐 [Gemini Image] Request URL: \(baseURL)/models/gemini-3-pro-image-preview:generateContent?key=\(maskedKey)")
        
        guard let url = URL(string: endpoint) else {
            throw ImageGenerationError.invalidRequest
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("📋 [Gemini Image] HTTP Method: POST")
        print("📋 [Gemini Image] Headers: Content-Type: application/json")
        
        // Ask Gemini to generate the meme image directly
        let imagePrompt = "Generate a sports roast meme image. Scenario: \(prompt). Style: \(style.description). The image should be a classic meme format with bold text."
        
        print("💬 [Gemini Image] Image Prompt: \(imagePrompt)")
        
        // Ask Gemini to generate the meme image directly
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": imagePrompt]
                    ]
                ]
            ],
            "generationConfig": [
                "response_modalities": ["IMAGE"]
            ],
            "safetySettings": [
                ["category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"],
                ["category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"],
                ["category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"],
                ["category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"]
            ]
        ]
        
        if let requestData = try? JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted),
           let requestString = String(data: requestData, encoding: .utf8) {
            print("📤 [Gemini Image] Full Request Body:\n\(requestString)")
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ImageGenerationError.networkError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ImageGenerationError.apiError("Gemini API error (\(httpResponse.statusCode)): \(errorMessage)")
        }
        
        // Parse Gemini response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            let body = String(data: data, encoding: .utf8) ?? "Empty body"
            print("❌ [Gemini] Could not parse response as JSON. Body: \(body)")
            throw ImageGenerationError.invalidResponse
        }
        
        // 1. Check for Top-Level Error
        if let error = json["error"] as? [String: Any] {
            let message = error["message"] as? String ?? "No message"
            print("❌ [Gemini] API Level Error: \(message)")
            throw ImageGenerationError.apiError("Gemini Error: \(message)")
        }
        
        // 2. Check Candidates
        guard let candidatesArray = json["candidates"] as? [[String: Any]], !candidatesArray.isEmpty else {
            print("❌ [Gemini] No candidates found in response. Keys: \(json.keys.joined(separator: ", "))")
            throw ImageGenerationError.invalidResponse
        }
        
        let firstCandidate = candidatesArray[0]
        
        // 3. Check Finish Reason (Safety Block)
        if let finishReason = firstCandidate["finishReason"] as? String, finishReason != "STOP" {
            print("⚠️ [Gemini] Generation stopped early. Reason: \(finishReason)")
            if finishReason == "SAFETY" {
                throw ImageGenerationError.generationFailed("Meme generation blocked by safety filters. Try a different roast!")
            }
        }
        
        // 4. Extract Content
        guard let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]] else {
            print("❌ [Gemini] Candidate has no content or parts. Keys: \(firstCandidate.keys.joined(separator: ", "))")
            
            // Log full response for debugging if structure is truly weird
            if let responseData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let responseString = String(data: responseData, encoding: .utf8) {
                print("📝 [Gemini] Full Response Body: \(responseString)")
            }
            throw ImageGenerationError.invalidResponse
        }
        
        // Find image data in parts
        var imageData: Data?
        var imageDescription: String = "Generated Roast Meme"
        
        for part in parts {
            if let inlineData = part["inlineData"] as? [String: Any],
               let base64Data = inlineData["data"] as? String {
                imageData = Data(base64Encoded: base64Data)
                print("✅ [Gemini] Found image data in response")
            } else if let text = part["text"] as? String {
                imageDescription = text
                print("📝 [Gemini] Found text in response: \(text.prefix(50))...")
            }
        }
        
        guard let finalImageData = imageData else {
            print("❌ [Gemini] No image data found in candidate parts. Parts count: \(parts.count)")
            throw ImageGenerationError.invalidResponse
        }
        
        // Save image data to local file
        let fileName = "meme_\(UUID().uuidString).png"
        let fileURL = try getDocumentsDirectory().appendingPathComponent(fileName)
        try finalImageData.write(to: fileURL)
        
        print("✅ Generated image saved to: \(fileURL.path)")
        
        return GeneratedImage(
            imageURL: fileURL.absoluteString,
            prompt: imageDescription,
            style: style,
            timestamp: Date()
        )
    }
    
    private func getDocumentsDirectory() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    private func buildImagePrompt(userPrompt: String, style: ImageStyle) -> String {
        let basePrompt = """
        Create a sports roast meme image: \(userPrompt)
        
        Style: \(style.description)
        
        Requirements:
        - NBA/Basketball themed meme
        - Bold text overlay with roast message
        - Simple, clean design (meme quality, not photorealistic)
        - High contrast colors
        - Humorous and playful
        - Square format (512x512)
        - Team colors if relevant
        - Suitable for sharing as a meme
        """
        
        return basePrompt
    }
}

// MARK: - Models

struct GeneratedImage: Identifiable {
    let id: String
    let imageURL: String
    let prompt: String
    let style: ImageStyle
    let timestamp: Date
    
    init(id: String = UUID().uuidString, imageURL: String, prompt: String, style: ImageStyle, timestamp: Date = Date()) {
        self.id = id
        self.imageURL = imageURL
        self.prompt = prompt
        self.style = style
        self.timestamp = timestamp
    }
}

enum ImageStyle: String, CaseIterable {
    case posterized = "posterized"
    case dunkedOn = "dunked_on"
    case trashTalk = "trash_talk"
    
    var description: String {
        switch self {
        case .posterized:
            return "Maximum intensity - brutal, savage roast with dramatic visual effects"
        case .dunkedOn:
            return "High intensity - strong roast with bold imagery"
        case .trashTalk:
            return "Moderate intensity - playful roast with fun visual style"
        }
    }
}

// MARK: - Errors

enum ImageGenerationError: LocalizedError {
    case serviceNotConfigured
    case invalidPrompt
    case invalidRequest
    case invalidResponse
    case generationFailed(String)
    case apiError(String)
    case invalidAPIKey
    case rateLimitExceeded
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .serviceNotConfigured:
            return "Image generation service is not configured"
        case .invalidPrompt:
            return "Invalid prompt provided"
        case .invalidRequest:
            return "Invalid API request"
        case .invalidResponse:
            return "Invalid API response"
        case .generationFailed(let message):
            return "Image generation failed: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        case .invalidAPIKey:
            return "Invalid API key for image generation service"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .networkError:
            return "Network error occurred"
        }
    }
}

// MARK: - Replicate Image Generation Service

class ReplicateImageGenerationService: ImageGenerationServiceProtocol {
    private let apiKey: String
    private let modelVersion: String
    // using generic model endpoint, though specific version could be pinned if needed
    // Defaulting to what the user requested.
    private let modelOwner = "black-forest-labs"
    private let modelName = "flux-schnell"
    
    init(apiKey: String, modelVersion: String = "") {
        self.apiKey = apiKey
        self.modelVersion = modelVersion
    }
    
    func generateImage(prompt: String, style: ImageStyle) async throws -> GeneratedImage {
        let enhancedPrompt = buildImagePrompt(userPrompt: prompt, style: style)
        
        // 1. Create Prediction
        let predictionURL = URL(string: "https://api.replicate.com/v1/predictions")!
        var request = URLRequest(url: predictionURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Flux Schnell input schema:
        // - prompt: String
        // - aspect_ratio: String (e.g. "1:1")
        // - go_fast: Bool (optimized inference)
        // - output_format: String (webp, jpg, png)
        // - output_quality: Int (0-100)
        // - num_outputs: Int
        let input: [String: Any] = [
            "prompt": enhancedPrompt,
            "aspect_ratio": "1:1",
            "go_fast": true,
            "output_format": "jpg",
            "output_quality": 80,
            "num_outputs": 1
        ]
        
        // Use version if provided, otherwise letting Replicate use latest for the model path is usually done via model endpoint,
        // but creating a prediction requires a version or using the model deployment if available.
        // For 'black-forest-labs/flux-schnell', we might need to lookup the version first or use the model URL.
        // Replicate API encourages using a specific version.
        // However, we can also use the models/{owner}/{name}/predictions endpoint to use the latest version automatically.
        
        let createEndpoint = "https://api.replicate.com/v1/models/\(modelOwner)/\(modelName)/predictions"
        guard let url = URL(string: createEndpoint) else {
             throw ImageGenerationError.invalidRequest
        }
        
        var predictionData: Data?
        var creationAttempts = 0
        let maxCreationAttempts = 3
        
        repeat {
            creationAttempts += 1
            
            var versionedRequest = URLRequest(url: url)
            versionedRequest.httpMethod = "POST"
            versionedRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            versionedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = ["input": input]
            versionedRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            print("🚀 [Replicate] Creating prediction for model: \(modelOwner)/\(modelName) (Attempt \(creationAttempts))")
            
            let (data, response) = try await URLSession.shared.data(for: versionedRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ImageGenerationError.networkError
            }
            
            if httpResponse.statusCode == 201 {
                predictionData = data
                break // Success!
            } else if httpResponse.statusCode == 429 {
                print("⚠️ [Replicate] Rate Limit Hit (429)")
                
                // Determine wait time from header or body
                var retryAfterSeconds: Double = 10 // Default fallback
                
                if let retryHeader = httpResponse.value(forHTTPHeaderField: "Retry-After"),
                   let seconds = Double(retryHeader) {
                    retryAfterSeconds = seconds
                } else if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let retryIn = json["retry_after"] as? Double {
                    retryAfterSeconds = retryIn
                }
                
                // Add a small buffer
                retryAfterSeconds += 1
                
                print("⏳ Waiting \(retryAfterSeconds) seconds before retrying...")
                try await Task.sleep(nanoseconds: UInt64(retryAfterSeconds * 1_000_000_000))
                
                if creationAttempts >= maxCreationAttempts {
                    throw ImageGenerationError.rateLimitExceeded
                }
                
                // Continue loop
                continue
            } else {
                // Other error
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("❌ [Replicate] Error creating prediction: \(errorJson)")
                }
                throw ImageGenerationError.apiError("Replicate API Error: \(httpResponse.statusCode)")
            }
            
        } while creationAttempts < maxCreationAttempts
        
        guard let data = predictionData,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let predictionId = json["id"] as? String,
              let urls = json["urls"] as? [String: Any],
              let getURLString = urls["get"] as? String,
              let getURL = URL(string: getURLString) else {
            throw ImageGenerationError.invalidResponse
        }
        
        print("⏳ [Replicate] Prediction created: \(predictionId). Waiting for result...")
        
        // 2. Poll for Result
        var imageURL: String? = nil
        var attempts = 0
        let maxAttempts = 60 // 1 minute roughly
        
        while imageURL == nil && attempts < maxAttempts {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            attempts += 1
            
            var statusRequest = URLRequest(url: getURL)
            statusRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let (statusData, statusResponse) = try await URLSession.shared.data(for: statusRequest)
            
            guard let statusHttpResponse = statusResponse as? HTTPURLResponse, statusHttpResponse.statusCode == 200 else {
                 print("⚠️ [Replicate] Polling failed with status: \((statusResponse as? HTTPURLResponse)?.statusCode ?? 0)")
                 continue
            }
            
            guard let statusJson = try? JSONSerialization.jsonObject(with: statusData) as? [String: Any],
                  let status = statusJson["status"] as? String else {
                continue
            }
            
            if status == "succeeded" {
                if let output = statusJson["output"] as? [String], let firstOutput = output.first {
                    imageURL = firstOutput
                } else if let outputStr = statusJson["output"] as? String {
                     imageURL = outputStr
                }
            } else if status == "failed" || status == "canceled" {
                throw ImageGenerationError.generationFailed("Replicate prediction failed or canceled")
            }
        }
        
        guard let finalImageURL = imageURL else {
            throw ImageGenerationError.generationFailed("Timeout waiting for image generation")
        }
        
        print("✅ [Replicate] Image generated: \(finalImageURL)")
        
        // 3. Download and Save locally (to match existing behavior)
        guard let remoteURL = URL(string: finalImageURL),
              let imageData = try? Data(contentsOf: remoteURL) else {
            throw ImageGenerationError.networkError
        }
        
        let fileName = "replicate_\(UUID().uuidString).png"
        let fileURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(fileName)
        try imageData.write(to: fileURL)
        
        return GeneratedImage(
            imageURL: fileURL.absoluteString,
            prompt: prompt,
            style: style,
            timestamp: Date()
        )
    }
    
    private func buildImagePrompt(userPrompt: String, style: ImageStyle) -> String {
        return "Sports roast meme, \(style.description). \(userPrompt)"
    }
}

