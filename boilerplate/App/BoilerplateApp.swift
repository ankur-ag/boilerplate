//
//  BoilerplateApp.swift
//  boilerplate
//

import SwiftUI
import FirebaseCore
import RevenueCat
import GoogleSignIn

@main
struct BoilerplateApp: App {
    // MARK: - Environment Objects
    @StateObject private var authManager = AuthManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var featureFlagManager = FeatureFlagManager()
    @StateObject private var appConfigManager = AppConfigManager()
    
    // Example AI Manager (LLM)
    @StateObject private var llmManager: LLMManager = {
        let manager = LLMManager()
        
        // Load API keys from Environment Variables (set these in Xcode Scheme)
        let openAIKey = (ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let geminiKey = (ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Placeholder for service configuration
        // if !openAIKey.isEmpty { manager.configure(with: OpenAIService(apiKey: openAIKey)) }
        
        return manager
    }()
    
    init() {
        // 1. Initialize Firebase
        // Ensure GoogleService-Info.plist is added to your project member target
        FirebaseApp.configure()
        print("✅ Firebase initialized")
        
        // 2. Initialize RevenueCat
        Purchases.logLevel = .debug
        let prodKey = ProcessInfo.processInfo.environment["REVENUECAT_API_KEY"]
        let testKey = ProcessInfo.processInfo.environment["REVENUECAT_TEST_KEY"] ?? "test_DtFJeDcDURuYslDVfFEodZCxYAo"
        
        let revenueCatKey = (prodKey ?? testKey).trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !revenueCatKey.isEmpty {
            Purchases.configure(withAPIKey: revenueCatKey)
            let keyType = prodKey != nil ? "PRODUCTION KEY" : "TEST KEY"
            print("✅ RevenueCat configured (\(keyType))")
            
            // Safe to initialize manager now that SDK is configured
            subscriptionManager.initialize()
        } else {
            print("⚠️ RevenueCat API Key missing")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(authManager)
                .environmentObject(llmManager)
                .environmentObject(subscriptionManager)
                .environmentObject(featureFlagManager)
                .environmentObject(appConfigManager)
                .onOpenURL { url in
                    // Handle Google Sign In redirect
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
