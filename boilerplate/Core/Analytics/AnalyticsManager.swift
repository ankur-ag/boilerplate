//
//  AnalyticsManager.swift
//  boilerplate
//
//  Posterized - Analytics tracking with Firebase
//  Created by Ankur on 1/12/26.
//

import Foundation
// import FirebaseAnalytics

/// Protocol for analytics providers (Firebase, Mixpanel, etc.)
protocol AnalyticsProvider {
    func logEvent(_ event: String, parameters: [String: Any]?)
    func setUserProperty(_ value: String, forName name: String)
    func setUserId(_ userId: String?)
}

// MARK: - Firebase Analytics Provider

class FirebaseAnalyticsProvider: AnalyticsProvider {
    func logEvent(_ event: String, parameters: [String: Any]?) {
        // Log to Firebase
        // Analytics.logEvent(event, parameters: parameters)
        
        // Also log to console in DEBUG for visibility
        #if DEBUG
        if let params = parameters, !params.isEmpty {
            print("📊 Firebase Analytics: \(event) - \(params)")
        } else {
            print("📊 Firebase Analytics: \(event)")
        }
        #endif
    }
    
    func setUserProperty(_ value: String, forName name: String) {
        // Analytics.setUserProperty(value, forName: name)
        
        #if DEBUG
        print("📊 Firebase User Property: \(name) = \(value)")
        #endif
    }
    
    func setUserId(_ userId: String?) {
        // Analytics.setUserID(userId)
        
        #if DEBUG
        print("📊 Firebase User ID: \(userId ?? "nil")")
        #endif
    }
}

/// Centralized analytics manager
/// Supports multiple analytics providers simultaneously
class AnalyticsManager {
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
    case termsAgreed
    
    // Authentication
    case signInStarted
    case signInCompleted(method: String)
    case signOutCompleted
    
    // Tailor Profile
    case tailorProfileOpened
    case teamSelected(team: String, type: String) // type: "my_team" or "rival"
    case intensitySelected(level: String)
    case profileSaved
    
    // Mode Selection
    case modeSelectionViewed
    case modeSelected(mode: String) // "text" or "image"
    
    // Roast Generation
    case roastStarted(mode: String, intensity: String)
    case roastCompleted(mode: String, intensity: String, duration: TimeInterval)
    case roastFailed(mode: String, error: String)
    case roastRegenerated(mode: String)
    case roastCopied(mode: String)
    case roastShared(mode: String)
    
    // LLM Interactions
    case promptSent(length: Int)
    case responseReceived(length: Int, duration: TimeInterval)
    case streamingStarted
    case streamingCompleted
    
    // Subscriptions
    case paywallViewed
    case purchaseStarted(productId: String)
    case purchaseCompleted(productId: String, price: String)
    case purchaseFailed(error: String)
    case restorePurchases
    case subscriptionStatusChanged(status: String)
    
    // Settings
    case settingsOpened
    case feedbackSubmitted(category: String)
    case termsViewed
    case privacyViewed
    
    // History
    case historyViewed
    case historyItemOpened
    case historyItemDeleted
    case historyCleared
    
    // Navigation
    case screenView(String)
    case tabChanged(String)
    
    // Errors
    case errorOccurred(type: String, message: String)
    
    // MARK: - Event Properties
    
    var name: String {
        switch self {
        // Onboarding
        case .onboardingStarted: return "onboarding_started"
        case .onboardingCompleted: return "onboarding_completed"
        case .onboardingSkipped: return "onboarding_skipped"
        case .termsAgreed: return "terms_agreed"
        
        // Authentication
        case .signInStarted: return "sign_in_started"
        case .signInCompleted: return "sign_in_completed"
        case .signOutCompleted: return "sign_out_completed"
        
        // Tailor Profile
        case .tailorProfileOpened: return "tailor_profile_opened"
        case .teamSelected: return "team_selected"
        case .intensitySelected: return "intensity_selected"
        case .profileSaved: return "profile_saved"
        
        // Mode Selection
        case .modeSelectionViewed: return "mode_selection_viewed"
        case .modeSelected: return "mode_selected"
        
        // Roast Generation
        case .roastStarted: return "roast_started"
        case .roastCompleted: return "roast_completed"
        case .roastFailed: return "roast_failed"
        case .roastRegenerated: return "roast_regenerated"
        case .roastCopied: return "roast_copied"
        case .roastShared: return "roast_shared"
        
        // LLM
        case .promptSent: return "prompt_sent"
        case .responseReceived: return "response_received"
        case .streamingStarted: return "streaming_started"
        case .streamingCompleted: return "streaming_completed"
        
        // Subscriptions
        case .paywallViewed: return "paywall_viewed"
        case .purchaseStarted: return "purchase_started"
        case .purchaseCompleted: return "purchase_completed"
        case .purchaseFailed: return "purchase_failed"
        case .restorePurchases: return "restore_purchases"
        case .subscriptionStatusChanged: return "subscription_status_changed"
        
        // Settings
        case .settingsOpened: return "settings_opened"
        case .feedbackSubmitted: return "feedback_submitted"
        case .termsViewed: return "terms_viewed"
        case .privacyViewed: return "privacy_viewed"
        
        // History
        case .historyViewed: return "history_viewed"
        case .historyItemOpened: return "history_item_opened"
        case .historyItemDeleted: return "history_item_deleted"
        case .historyCleared: return "history_cleared"
        
        // Navigation
        case .screenView: return "screen_view"
        case .tabChanged: return "tab_changed"
        
        // Errors
        case .errorOccurred: return "error_occurred"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        // Authentication
        case .signInCompleted(let method):
            return ["method": method]
        
        // Tailor Profile
        case .teamSelected(let team, let type):
            return ["team": team, "type": type]
        case .intensitySelected(let level):
            return ["intensity": level]
        
        // Mode Selection
        case .modeSelected(let mode):
            return ["mode": mode]
        
        // Roast Generation
        case .roastStarted(let mode, let intensity):
            return ["mode": mode, "intensity": intensity]
        case .roastCompleted(let mode, let intensity, let duration):
            return ["mode": mode, "intensity": intensity, "duration": duration]
        case .roastFailed(let mode, let error):
            return ["mode": mode, "error": error]
        case .roastRegenerated(let mode):
            return ["mode": mode]
        case .roastCopied(let mode):
            return ["mode": mode]
        case .roastShared(let mode):
            return ["mode": mode]
        
        // LLM
        case .promptSent(let length):
            return ["length": length]
        case .responseReceived(let length, let duration):
            return ["length": length, "duration": duration]
        
        // Subscriptions
        case .purchaseStarted(let productId):
            return ["product_id": productId]
        case .purchaseCompleted(let productId, let price):
            return ["product_id": productId, "price": price]
        case .purchaseFailed(let error):
            return ["error": error]
        case .subscriptionStatusChanged(let status):
            return ["status": status]
        
        // Settings
        case .feedbackSubmitted(let category):
            return ["category": category]
        
        // Navigation
        case .screenView(let screenName):
            return ["screen_name": screenName]
        case .tabChanged(let tabName):
            return ["tab_name": tabName]
        
        // Errors
        case .errorOccurred(let type, let message):
            return ["error_type": type, "message": message]
        
        default:
            return nil
        }
    }
}
