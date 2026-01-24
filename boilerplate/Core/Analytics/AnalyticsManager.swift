//
//  AnalyticsManager.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import FirebaseAnalytics
import SwiftUI

/// Protocol for analytics providers (Firebase, Mixpanel, etc.)
protocol AnalyticsProvider {
    func logEvent(_ event: String, parameters: [String: Any]?)
    func setUserProperty(_ value: String, forName name: String)
    func setUserId(_ userId: String?)
}

// MARK: - Firebase Analytics Provider

class FirebaseAnalyticsProvider: AnalyticsProvider {
    func logEvent(_ event: String, parameters: [String: Any]?) {
        Analytics.logEvent(event, parameters: parameters)
        
        #if DEBUG
        if let params = parameters, !params.isEmpty {
            print("📊 Firebase Analytics: \(event) - \(params)")
        } else {
            print("📊 Firebase Analytics: \(event)")
        }
        #endif
    }
    
    func setUserProperty(_ value: String, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
        
        #if DEBUG
        print("📊 Firebase User Property: \(name) = \(value)")
        #endif
    }
    
    func setUserId(_ userId: String?) {
        Analytics.setUserID(userId)
        
        #if DEBUG
        print("📊 Firebase User ID: \(userId ?? "nil")")
        #endif
    }
}

/// Centralized analytics manager
/// Supports multiple analytics providers simultaneously
class AnalyticsManager: ObservableObject {
    // MARK: - Properties
    
    private var providers: [AnalyticsProvider] = []
    private let isEnabled: Bool
    
    // MARK: - Initialization
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
        
        // Initialize Firebase Analytics provider
        let firebaseProvider = FirebaseAnalyticsProvider()
        providers.append(firebaseProvider)
        
        print("✅ Analytics initialized with Firebase")
    }
    
    // MARK: - Provider Management
    
    func addProvider(_ provider: AnalyticsProvider) {
        providers.append(provider)
    }
    
    // MARK: - Event Logging
    
    func logEvent(_ event: AnalyticsEvent) {
        guard isEnabled else { return }
        
        let parameters = event.parameters
        providers.forEach { provider in
            provider.logEvent(event.name, parameters: parameters)
        }
        
        #if DEBUG
        print("📊 Analytics: \(event.name) - \(parameters ?? [:])")
        #endif
    }
    
    func logScreenView(_ screenName: String) {
        logEvent(.screenView(screenName))
    }
    
    // MARK: - User Properties
    
    func setUserId(_ userId: String?) {
        guard isEnabled else { return }
        
        providers.forEach { provider in
            provider.setUserId(userId)
        }
    }
    
    func setUserProperty(_ value: String, forName name: String) {
        guard isEnabled else { return }
        
        providers.forEach { provider in
            provider.setUserProperty(value, forName: name)
        }
    }
}

// MARK: - Analytics Events

enum AnalyticsEvent {
    // Onboarding
    case onboardingStarted
    case onboardingCompleted
    case onboardingSkipped
    
    // Authentication
    case signInStarted
    case signInCompleted(method: String)
    case signOutCompleted
    
    // LLM Interactions
    case promptSent(length: Int)
    case responsReceived(length: Int, duration: TimeInterval)
    case streamingStarted
    case streamingCompleted
    
    // Subscriptions
    case paywallViewed
    case purchaseStarted(productId: String)
    case purchaseCompleted(productId: String)
    case purchaseFailed(error: String)
    case restorePurchases
    
    // Navigation
    case screenView(String)
    case tabChanged(String)
    
    // Errors
    case errorOccurred(type: String, message: String)
    
    // MARK: - Event Properties
    
    var name: String {
        switch self {
        case .onboardingStarted: return "onboarding_started"
        case .onboardingCompleted: return "onboarding_completed"
        case .onboardingSkipped: return "onboarding_skipped"
        case .signInStarted: return "sign_in_started"
        case .signInCompleted: return "sign_in_completed"
        case .signOutCompleted: return "sign_out_completed"
        case .promptSent: return "prompt_sent"
        case .responsReceived: return "response_received"
        case .streamingStarted: return "streaming_started"
        case .streamingCompleted: return "streaming_completed"
        case .paywallViewed: return "paywall_viewed"
        case .purchaseStarted: return "purchase_started"
        case .purchaseCompleted: return "purchase_completed"
        case .purchaseFailed: return "purchase_failed"
        case .restorePurchases: return "restore_purchases"
        case .screenView: return "screen_view"
        case .tabChanged: return "tab_changed"
        case .errorOccurred: return "error_occurred"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .signInCompleted(let method):
            return ["method": method]
        case .promptSent(let length):
            return ["length": length]
        case .responsReceived(let length, let duration):
            return ["length": length, "duration": duration]
        case .purchaseStarted(let productId), .purchaseCompleted(let productId):
            return ["product_id": productId]
        case .purchaseFailed(let error):
            return ["error": error]
        case .screenView(let screenName):
            return ["screen_name": screenName]
        case .tabChanged(let tabName):
            return ["tab_name": tabName]
        case .errorOccurred(let type, let message):
            return ["error_type": type, "message": message]
        default:
            return nil
        }
    }
}
