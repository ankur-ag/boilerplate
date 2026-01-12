//
//  RoastSession.swift
//  boilerplate
//
//  RoastGPT Clone - Data Models
//  Created by Ankur on 1/12/26.
//

import Foundation
import UIKit

// MARK: - Roast Session

struct RoastSession: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    let inputText: String
    let roastText: String
    let timestamp: Date
    let imageURL: String?
    let ocrText: String?
    let source: RoastInputSource
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        inputText: String,
        roastText: String,
        timestamp: Date = Date(),
        imageURL: String? = nil,
        ocrText: String? = nil,
        source: RoastInputSource? = nil
    ) {
        self.id = id
        self.userId = userId
        self.inputText = inputText
        self.roastText = roastText
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.ocrText = ocrText
        
        // Auto-detect source if not provided
        if let source = source {
            self.source = source
        } else {
            self.source = (imageURL != nil || ocrText != nil) ? .image : .text
        }
    }
    
    var preview: String {
        String(roastText.prefix(100))
    }
    
    var hasImage: Bool {
        imageURL != nil
    }
}

// MARK: - Roast Input Source

enum RoastInputSource: String, Codable {
    case text
    case image
}

// MARK: - Roast Generation State

enum RoastGenerationState: Equatable {
    case idle
    case extractingText
    case generating
    case streaming(String)
    case completed(RoastSession)
    case error(String)
    
    var isProcessing: Bool {
        switch self {
        case .extractingText, .generating, .streaming:
            return true
        default:
            return false
        }
    }
}
