//
//  OCRManager.swift
//  boilerplate
//
//  RoastGPT Clone - OCR using Apple Vision Framework
//  Created by Ankur on 1/12/26.
//

import Foundation
import UIKit
import Vision

/// Manages OCR operations using Apple's Vision framework
@MainActor
class OCRManager: ObservableObject {
    @Published private(set) var isProcessing: Bool = false
    @Published private(set) var error: OCRError?
    
    // MARK: - Text Recognition
    
    /// Extract text from an image using Vision framework
    func recognizeText(from image: UIImage) async throws -> String {
        isProcessing = true
        error = nil
        
        defer {
            isProcessing = false
        }
        
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: OCRError.visionError(error.localizedDescription))
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: OCRError.noTextFound)
                    return
                }
                
                // Extract all text with confidence threshold
                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")
                
                if recognizedText.isEmpty {
                    continuation.resume(throwing: OCRError.noTextFound)
                } else {
                    continuation.resume(returning: recognizedText)
                }
            }
            
            // Configure request for best accuracy
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true
            
            // Perform request
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: OCRError.visionError(error.localizedDescription))
            }
        }
    }
    
    /// Extract text with progress updates (for large images)
    func recognizeTextWithProgress(
        from image: UIImage,
        onProgress: @escaping (Double) -> Void
    ) async throws -> String {
        // For simplicity, we'll just call the main method
        // In production, you might chunk the image or provide fake progress
        onProgress(0.0)
        let text = try await recognizeText(from: image)
        onProgress(1.0)
        return text
    }
    
    // MARK: - Text Cleaning
    
    /// Clean extracted text (remove extra whitespace, etc.)
    func cleanExtractedText(_ text: String) -> String {
        var cleaned = text
        
        // Remove excessive newlines
        cleaned = cleaned.replacingOccurrences(of: "\n\n\n+", with: "\n\n", options: .regularExpression)
        
        // Trim whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
}

// MARK: - OCR Error

enum OCRError: LocalizedError {
    case invalidImage
    case noTextFound
    case visionError(String)
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid or corrupted image"
        case .noTextFound:
            return "No text found in image. Please try a different image with clear text."
        case .visionError(let message):
            return "OCR failed: \(message)"
        case .processingFailed:
            return "Failed to process image"
        }
    }
}
