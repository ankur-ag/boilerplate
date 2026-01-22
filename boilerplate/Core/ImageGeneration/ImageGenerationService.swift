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



