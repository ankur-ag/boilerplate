//
//  AppConfigManager.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI

/// Manages app-level configuration and state
/// Handles onboarding completion, app version, etc.
@MainActor
class AppConfigManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var hasCompletedOnboarding: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var appVersion: String = ""
    @Published private(set) var buildNumber: String = ""
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let lastAppVersion = "lastAppVersion"
    }
    
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadAppInfo()
        loadPersistedState()
    }
    
    // MARK: - Configuration Loading
    
    func loadConfig() async {
        isLoading = true
        
        // TODO: Load remote configuration
        // TODO: Check for app updates
        // TODO: Load critical app settings
        
        // Simulate loading
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        
        isLoading = false
    }
    
    // MARK: - Onboarding
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        userDefaults.set(true, forKey: Keys.hasCompletedOnboarding)
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        userDefaults.set(false, forKey: Keys.hasCompletedOnboarding)
    }
    
    // MARK: - App Info
    
    var isFirstLaunch: Bool {
        return !hasCompletedOnboarding
    }
    
    var needsUpdate: Bool {
        // TODO: Compare with minimum required version from backend
        return false
    }
    
    // MARK: - Private Methods
    
    private func loadAppInfo() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildNumber = build
        }
    }
    
    private func loadPersistedState() {
        hasCompletedOnboarding = userDefaults.bool(forKey: Keys.hasCompletedOnboarding)
    }
    
    // MARK: - Debug Helpers
    
    #if DEBUG
    func resetAllSettings() {
        hasCompletedOnboarding = false
        userDefaults.removeObject(forKey: Keys.hasCompletedOnboarding)
        userDefaults.removeObject(forKey: Keys.lastAppVersion)
    }
    #endif
}

// MARK: - App Configuration

struct AppConfiguration {
    let apiBaseURL: String
    let apiTimeout: TimeInterval
    let maxRetries: Int
    let analyticsEnabled: Bool
    let crashReportingEnabled: Bool
    
    static let `default` = AppConfiguration(
        apiBaseURL: "https://api.example.com",
        apiTimeout: 30.0,
        maxRetries: 3,
        analyticsEnabled: true,
        crashReportingEnabled: true
    )
    
    #if DEBUG
    static let debug = AppConfiguration(
        apiBaseURL: "https://dev-api.example.com",
        apiTimeout: 60.0,
        maxRetries: 1,
        analyticsEnabled: false,
        crashReportingEnabled: false
    )
    #endif
}
