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
        FirebaseApp.configure()
        print("✅ Firebase initialized")
        
        // 2. Initialize RevenueCat
        Purchases.logLevel = .debug
        
        // Environment variables only work in local debug schemes.
        // For TestFlight, we use the hardcoded fallback.
        let prodKey = ProcessInfo.processInfo.environment["REVENUECAT_API_KEY"]
        let testKey = ProcessInfo.processInfo.environment["REVENUECAT_TEST_KEY"]
        let fallbackKey = "test_DtFJeDcDURuYslDVfFEodZCxYAo" // Use your PROD key here for TestFlight
        
        let revenueCatKey = (prodKey ?? testKey ?? fallbackKey).trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !revenueCatKey.isEmpty {
            Purchases.configure(withAPIKey: revenueCatKey)
            print("✅ RevenueCat configured with: \(prodKey != nil ? "Production Key (Scheme)" : (testKey != nil ? "Test Key (Scheme)" : "Bundled/Fallback Key"))")
            
            // Safe to initialize manager now
            subscriptionManager.initialize()
        } else {
            print("❌ RevenueCat API Key missing - App may crash if subscription features are accessed")
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
