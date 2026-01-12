//
//  BoilerplateApp.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI
import FirebaseCore

@main
struct BoilerplateApp: App {
    // MARK: - Environment Objects
    @StateObject private var authManager = AuthManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var featureFlagManager = FeatureFlagManager()
    @StateObject private var appConfigManager = AppConfigManager()
    
    // LLM Manager with OpenAI configuration
    @StateObject private var llmManager: LLMManager = {
        let manager = LLMManager()
        
        // Get API key from environment variable
        // Add OPENAI_API_KEY to Xcode scheme: Product → Scheme → Edit Scheme → Run → Arguments → Environment Variables
        let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        
        if !apiKey.isEmpty {
            let openAIService = OpenAIService(apiKey: apiKey)
            manager.configure(with: openAIService)
            print("✅ OpenAI configured")
        } else {
            print("⚠️ No OPENAI_API_KEY found in environment variables")
        }
        
        return manager
    }()
    
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured")
        
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
