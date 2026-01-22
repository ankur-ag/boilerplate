//
//  SafetyManager.swift
//  boilerplate
//
//  Centralized safety and moderation logic
//  Created by Ankur on 1/12/26.
//

import Foundation

/// Errors related to safety violations
enum SafetyError: LocalizedError {
    case blockedContent(String)
    
    var errorDescription: String? {
        switch self {
        case .blockedContent(let category):
            return "This input contains content that violates nuestra safety guidelines (\(category)). Please try something else."
        }
    }
}

/// Manages AI safety by filtering blocked keywords and phrases
class SafetyManager {
    static let shared = SafetyManager()
    
    private init() {}
    
    /// Blocklist categories and their associated keywords
    private let blocklist: [String: [String]] = [
        "hate_speech": [
            "nazi", "hitler", "holocaust", "supremacy", "racist", "bigot"
        ],
        "self_harm": [
            "suicide", "kill myself", "self harm", "cutting", "hanging", "overdose"
        ],
        "illegal": [
            "bomb", "terrorism", "meth", "cocaine", "heroin", "illegal drugs", "child abuse"
        ],
        "explicit": [
            "porn", "nsfw", "hardcore", "xxx"
        ]
    ]
    
    /// Checks input against the blocklist and throws an error if a violation is found
    func validateInput(_ input: String) throws {
        let normalizedInput = input.lowercased()
        
        for (category, keywords) in blocklist {
            for keyword in keywords {
                if normalizedInput.contains(keyword) {
                    print("⚠️ [Safety] Violation detected! Category: \(category), Keyword: \(keyword)")
                    throw SafetyError.blockedContent(category.replacingOccurrences(of: "_", with: " "))
                }
            }
        }
    }
    
    /// Convenience method to clean text by removing/masking common slurs (if needed)
    /// This is a simple proof-of-concept; in production, use a professional moderation API.
    func cleanText(_ text: String) -> String {
        // Implementation for masking if desired
        return text
    }
}
