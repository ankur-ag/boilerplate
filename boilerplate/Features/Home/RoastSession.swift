//
//  RoastSession.swift
//  boilerplate
//
//  Posterized - Data Models
//  Created by Ankur on 1/12/26.
//

import Foundation

// MARK: - Roast Session

struct RoastSession: Identifiable, Codable, Equatable {
    let id: String
    let userId: String
    let inputText: String
    let roastText: String
    let secondaryRoastText: String?
    let timestamp: Date
    let imageURL: String?
    let secondaryImageURL: String?
    let ocrText: String?
    let source: RoastInputSource
    let intensity: RoastIntensity
    let sport: SportType
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        inputText: String,
        roastText: String,
        secondaryRoastText: String? = nil,
        timestamp: Date = Date(),
        imageURL: String? = nil,
        secondaryImageURL: String? = nil,
        ocrText: String? = nil,
        source: RoastInputSource? = nil,
        intensity: RoastIntensity = .posterized,
        sport: SportType = .nba
    ) {
        self.id = id
        self.userId = userId
        self.inputText = inputText
        self.roastText = roastText
        self.secondaryRoastText = secondaryRoastText
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.secondaryImageURL = secondaryImageURL
        self.ocrText = ocrText
        self.intensity = intensity
        self.sport = sport
        
        // Auto-detect source if not provided
        if let source = source {
            self.source = source
        } else {
            self.source = (imageURL != nil || secondaryImageURL != nil || ocrText != nil) ? .image : .text
        }
    }
    
    var preview: String {
        String(roastText.prefix(100))
    }
    
    var hasImage: Bool {
        imageURL != nil || secondaryImageURL != nil
    }
}

// MARK: - Roast Input Source

public enum RoastInputSource: String, Codable {
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
