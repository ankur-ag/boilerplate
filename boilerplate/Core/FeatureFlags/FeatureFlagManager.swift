//
//  FeatureFlagManager.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI

/// Manages feature flags for A/B testing and gradual rollouts
/// Can be backed by Firebase Remote Config, LaunchDarkly, or local config
@MainActor
class FeatureFlagManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var isLoading: Bool = false
    @Published private var flags: [String: FeatureFlagValue] = [:]
    
    // MARK: - Initialization
    
    init() {
        loadLocalDefaults()
    }
    
    // MARK: - Configuration
    
    func fetchRemoteFlags() async {
        isLoading = true
        
        // TODO: Fetch from Firebase Remote Config
        // TODO: Fetch from backend API
        // TODO: Apply user-specific overrides
        
        // Simulate network fetch
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        isLoading = false
    }
    
    // MARK: - Feature Flag Access
    
    func isEnabled(_ flag: FeatureFlag) -> Bool {
        return flags[flag.key]?.boolValue ?? flag.defaultValue.boolValue
    }
    
    func stringValue(for flag: FeatureFlag) -> String? {
        return flags[flag.key]?.stringValue ?? flag.defaultValue.stringValue
    }
    
    func intValue(for flag: FeatureFlag) -> Int? {
        return flags[flag.key]?.intValue ?? flag.defaultValue.intValue
    }
    
    func doubleValue(for flag: FeatureFlag) -> Double? {
        return flags[flag.key]?.doubleValue ?? flag.defaultValue.doubleValue
    }
    
    // MARK: - Override (for testing)
    
    func setFlag(_ flag: FeatureFlag, value: FeatureFlagValue) {
        flags[flag.key] = value
    }
    
    func resetFlag(_ flag: FeatureFlag) {
        flags[flag.key] = flag.defaultValue
    }
    
    func resetAllFlags() {
        loadLocalDefaults()
    }
    
    // MARK: - Private Methods
    
    private func loadLocalDefaults() {
        FeatureFlag.allFlags.forEach { flag in
            flags[flag.key] = flag.defaultValue
        }
    }
}

// MARK: - Feature Flag Definition

struct FeatureFlag {
    let key: String
    let defaultValue: FeatureFlagValue
    let description: String
    
    // MARK: - Feature Flags
    
    // Onboarding
    static let skipOnboarding = FeatureFlag(
        key: "skip_onboarding",
        defaultValue: .bool(false),
        description: "Skip onboarding flow"
    )
    
    // LLM Features
    static let enableStreaming = FeatureFlag(
        key: "enable_streaming",
        defaultValue: .bool(true),
        description: "Enable streaming LLM responses"
    )
    
    static let maxMessageLength = FeatureFlag(
        key: "max_message_length",
        defaultValue: .int(4000),
        description: "Maximum message length in characters"
    )
    
    // Subscriptions
    static let showPaywall = FeatureFlag(
        key: "show_paywall",
        defaultValue: .bool(true),
        description: "Show paywall to free users"
    )
    
    static let freeMessageLimit = FeatureFlag(
        key: "free_message_limit",
        defaultValue: .int(10),
        description: "Number of free messages for non-subscribers"
    )
    
    // UI Features
    static let enableDarkMode = FeatureFlag(
        key: "enable_dark_mode",
        defaultValue: .bool(true),
        description: "Enable dark mode support"
    )
    
    static let showHistory = FeatureFlag(
        key: "show_history",
        defaultValue: .bool(true),
        description: "Show conversation history tab"
    )
    
    // TODO: Add more feature flags as needed
    
    // MARK: - All Flags
    
    static let allFlags: [FeatureFlag] = [
        .skipOnboarding,
        .enableStreaming,
        .maxMessageLength,
        .showPaywall,
        .freeMessageLimit,
        .enableDarkMode,
        .showHistory
    ]
}

// MARK: - Feature Flag Value

enum FeatureFlagValue {
    case bool(Bool)
    case string(String)
    case int(Int)
    case double(Double)
    
    var boolValue: Bool {
        if case .bool(let value) = self {
            return value
        }
        return false
    }
    
    var stringValue: String? {
        if case .string(let value) = self {
            return value
        }
        return nil
    }
    
    var intValue: Int? {
        if case .int(let value) = self {
            return value
        }
        return nil
    }
    
    var doubleValue: Double? {
        if case .double(let value) = self {
            return value
        }
        return nil
    }
}
