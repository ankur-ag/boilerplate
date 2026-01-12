//
//  AppConstants.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation

enum AppConstants {
    // MARK: - API
    enum API {
        static let baseURL = "https://api.example.com"
        static let timeout: TimeInterval = 30.0
        static let maxRetries = 3
    }
    
    // MARK: - UI
    enum UI {
        static let animationDuration: Double = 0.3
        static let cornerRadius: CGFloat = 12.0
        static let defaultPadding: CGFloat = 16.0
    }
    
    // MARK: - Limits
    enum Limits {
        static let maxMessageLength = 4000
        static let freeMessageLimit = 10
        static let maxConversationHistory = 100
    }
    
    // MARK: - URLs
    enum URLs {
        static let privacyPolicy = "https://example.com/privacy"
        static let termsOfService = "https://example.com/terms"
        static let support = "mailto:support@example.com"
    }
}
