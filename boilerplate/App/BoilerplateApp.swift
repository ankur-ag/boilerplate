//
//  BoilerplateApp.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI
import FirebaseCore
import RevenueCat

@main
struct BoilerplateApp: App {
    // MARK: - Environment Objects
    @StateObject private var authManager = AuthManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var featureFlagManager = FeatureFlagManager()
    @StateObject private var appConfigManager = AppConfigManager()
    @StateObject private var usageManager = UsageManager()
    @StateObject private var imageGenerationManager: ImageGenerationManager = {
        let manager = ImageGenerationManager()

        let geminiKey = (ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // TEST MODE: Prioritize Gemini Flash
        if !geminiKey.isEmpty {
            let geminiService = GeminiFlashService(apiKey: geminiKey)
            manager.configure(with: geminiService)
            print("✅ Image Generation configured with Gemini Flash (TEST MODE)")
        } else {
            print("⚠️ Image Generation Service NOT configured (Missing API Keys)")
        }
        
        return manager
    }()
    
    @StateObject private var analyticsManager = AnalyticsManager()
    
    // LLM Manager with OpenAI and Gemini configuration
    @StateObject private var llmManager: LLMManager = {
        let manager = LLMManager()
        
        // Get API keys from environment variables
        let openAIKey = (ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let geminiKey = (ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Configure Services
        if !openAIKey.isEmpty {
            let openAIService = OpenAIService(apiKey: openAIKey)
            manager.configure(with: openAIService)
            print("✅ OpenAI configured")
        }
        
        if !geminiKey.isEmpty {
            let geminiService = GeminiService(apiKey: geminiKey)
            manager.addService(geminiService)
            print("✅ Gemini configured")
        }
        
        return manager
    }()
    
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured")
        
        // Initialize RevenueCat
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "test_DtFJeDcDURuYslDVfFEodZCxYAo")
        print("✅ RevenueCat configured")
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(authManager)
                .environmentObject(llmManager)
                .environmentObject(subscriptionManager)
                .environmentObject(featureFlagManager)
                .environmentObject(appConfigManager)
                .environmentObject(usageManager)
                .environmentObject(imageGenerationManager)
                .environmentObject(analyticsManager)
        }
    }
}
