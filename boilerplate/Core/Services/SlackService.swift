//
//  SlackService.swift
//  boilerplate
//
//  Slack webhook integration for feedback
//

import Foundation
import UIKit

class SlackService {
    static let shared = SlackService()
    
    private init() {}
    
    private var webhookURL: String {
        Config.slackWebhookURL
    }
    
    func sendFeedback(
        category: FeedbackCategory,
        message: String,
        userEmail: String? = nil
    ) async throws {
        guard let url = URL(string: webhookURL), !webhookURL.contains("YOUR_SLACK") else {
            throw SlackError.invalidWebhookURL
        }
        
        // Build Slack message payload
        let payload = buildSlackPayload(
            category: category,
            message: message,
            userEmail: userEmail
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw SlackError.requestFailed
        }
    }
    
    private func buildSlackPayload(
        category: FeedbackCategory,
        message: String,
        userEmail: String?
    ) -> [String: Any] {
        let deviceInfo = """
        Device: \(UIDevice.current.model)
        System: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
        """
        
        let categoryEmoji: String
        switch category {
        case .bug: categoryEmoji = "🐛"
        case .feature: categoryEmoji = "💡"
        case .general: categoryEmoji = "💬"
        }
        
        var blocks: [[String: Any]] = [
            [
                "type": "header",
                "text": [
                    "type": "plain_text",
                    "text": "\(categoryEmoji) New Feedback: \(category.title)"
                ]
            ],
            [
                "type": "section",
                "fields": [
                    [
                        "type": "mrkdwn",
                        "text": "*Category:*\n\(category.shortTitle)"
                    ],
                    [
                        "type": "mrkdwn",
                        "text": "*Time:*\n\(formatDate(Date()))"
                    ]
                ]
            ],
            [
                "type": "section",
                "text": [
                    "type": "mrkdwn",
                    "text": "*Message:*\n\(message)"
                ]
            ],
            [
                "type": "context",
                "elements": [
                    [
                        "type": "mrkdwn",
                        "text": deviceInfo
                    ]
                ]
            ]
        ]
        
        if let email = userEmail {
            blocks.insert([
                "type": "section",
                "text": [
                    "type": "mrkdwn",
                    "text": "*User:* \(email)"
                ]
            ], at: 2)
        }
        
        return [
            "blocks": blocks
        ]
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum FeedbackCategory: String, CaseIterable {
    case bug = "bug"
    case feature = "feature"
    case general = "general"
    
    var title: String {
        switch self {
        case .bug: return "Report a Bug"
        case .feature: return "Request a Feature"
        case .general: return "General Feedback"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .bug: return "Bug"
        case .feature: return "Feature"
        case .general: return "General"
        }
    }
}

enum SlackError: LocalizedError {
    case invalidWebhookURL
    case requestFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidWebhookURL:
            return "Invalid Slack webhook URL"
        case .requestFailed:
            return "Failed to send feedback to Slack"
        }
    }
}
