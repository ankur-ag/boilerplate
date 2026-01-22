//
//  GeminiFlashService.swift
//  boilerplate
//
//  Restored Gemini Flash Image Generation Service
//

import Foundation
import UIKit

class GeminiFlashService: ImageGenerationServiceProtocol {
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
        
        // Debug: Log masked key to verify consistency
        let keyLength = apiKey.count
        let maskedKey = keyLength > 8 ? "\(apiKey.prefix(4))...\(apiKey.suffix(4))" : "***"
        print("🔑 [Gemini Flash] Using API Key: \(maskedKey) (Length: \(keyLength))")
        
        // This endpoint was identified from earlier git history
        let endpoint = "\(baseURL)/models/gemini-2.5-flash-image:generateContent?key=\(apiKey)"
        
        print("🌐 [Gemini Flash] Request URL: \(baseURL)/models/gemini-2.5-flash-image:generateContent")
        
        guard let url = URL(string: endpoint) else {
            throw ImageGenerationError.invalidRequest
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create request body with the Enhanced Prompt
        print("💬 [Gemini Flash] Image Prompt:\n\(enhancedPrompt)")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": enhancedPrompt]
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
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ImageGenerationError.networkError
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ [Gemini Flash] API Error: \(errorMessage)")
            throw ImageGenerationError.apiError("Gemini API error (\(httpResponse.statusCode)): \(errorMessage)")
        }
        
        // Parse Gemini response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ImageGenerationError.invalidResponse
        }
        
        // Check Candidates
        guard let candidatesArray = json["candidates"] as? [[String: Any]], !candidatesArray.isEmpty else {
            throw ImageGenerationError.invalidResponse
        }
        
        let firstCandidate = candidatesArray[0]
        
        // Extract Content
        guard let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]] else {
            throw ImageGenerationError.invalidResponse
        }
        
        // Find image data in parts
        var imageData: Data?
        var imageDescription: String = "Generated Roast Meme"
        
        for part in parts {
            if let inlineData = part["inlineData"] as? [String: Any],
               let base64Data = inlineData["data"] as? String {
                imageData = Data(base64Encoded: base64Data)
                print("✅ [Gemini Flash] Found image data in response")
            } else if let text = part["text"] as? String {
                imageDescription = text
            }
        }
        
        guard let finalImageData = imageData else {
            print("❌ [Gemini Flash] No image data found in candidate parts.")
            throw ImageGenerationError.invalidResponse
        }
        
        // Save image data to local file
        let fileName = "meme_flash_\(UUID().uuidString).png"
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
        return """
        You are an AI image director creating a single savage, funny NBA-themed roast image designed to go viral in group chats.

        Goal:
        Create ONE clear, high-impact NBA roast image based on the user’s context.

        Core rules:
        - The image must clearly be about basketball / the NBA (players, teams, arenas, locker rooms, posters, mascots, refs, fans, scoreboards, etc.).
        - If real NBA players or teams are mentioned, depict recognizable versions of those players or teams (not generic stand-ins).
        - Style: semi-realistic sports graphic, similar to an NBA promo thumbnail or ESPN meme edit.
        - Aspect ratio: 1:1 (Square).
        - Roast intensity is controlled by {intensity}:
          - trash talk (mild): playful banter, light embarrassment
          - dunk on (medium): obvious humiliation but still playful
          - posterized (severe, default): maximum visual humiliation and clowning
        - You may include on-image text (headlines, speech bubbles, scoreboards) or emoji-style elements if they enhance the humor, but they are optional.
        - Hard no-go topics: do NOT include or imply self-harm, suicide, or mocking disabilities or visible medical conditions.

        Allowed roast angles:
        Ego, skill level, choking, clutch failures, “washed” debates, ring debates, fanbase delusion, refs favoritism, media hype, etc.

        Inputs:
        - Context: \(userPrompt)
        - Intensity: \(style.rawValue.replacingOccurrences(of: "_", with: " "))
        - Has Reference Image: false

        Reference image behavior:
        - If {has_reference_image} == true:
          Reuse the core layout or structure described in {reference_layout_description}, re-skinned into an NBA roast that fits {context_text}.
        - If {has_reference_image} == false:
          Create a fresh, original NBA roast image.

        Output requirement:
        - Generate ONE complete NBA roast image concept and render it as a single image.
        """
    }
}
