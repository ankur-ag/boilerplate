//
//  BoilerplateApp.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

@main
struct BoilerplateApp: App {
    // MARK: - Environment Objects
    @StateObject private var authManager = AuthManager()
    @StateObject private var llmManager = LLMManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var featureFlagManager = FeatureFlagManager()
    @StateObject private var appConfigManager = AppConfigManager()
    
    init() {
        // TODO: Initialize Firebase here
        // TODO: Configure Analytics
        // TODO: Set up crash reporting
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(authManager)
                .environmentObject(llmManager)
                .environmentObject(subscriptionManager)
                .environmentObject(featureFlagManager)
                .environmentObject(appConfigManager)
        }
    }
}
