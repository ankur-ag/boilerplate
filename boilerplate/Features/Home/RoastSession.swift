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

struct RoastSession: Identifiable, Codable {
    let id: String
    let userId: String
    let inputText: String
    let roastText: String
    let timestamp: Date
    let imageURL: String?
    let ocrText: String?
    let regenerationCount: Int
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        inputText: String,
        roastText: String,
        timestamp: Date = Date(),
        imageURL: String? = nil,
        ocrText: String? = nil,
        regenerationCount: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.inputText = inputText
        self.roastText = roastText
        self.timestamp = timestamp
        self.imageURL = imageURL
        self.ocrText = ocrText
        self.regenerationCount = regenerationCount
    }
    
    var preview: String {
        String(roastText.prefix(100))
    }
    
    var hasImage: Bool {
        imageURL != nil
    }
}

// MARK: - Roast Input Type

enum RoastInputType {
    case text(String)
    case image(UIImage, extractedText: String?)
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
