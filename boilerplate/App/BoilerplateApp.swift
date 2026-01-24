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
        
        let openAIKey = SecretConfig.openAIAPIKey
        let geminiKey = SecretConfig.geminiAPIKey
        
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
        
        let revenueCatKey = SecretConfig.revenueCatAPIKey
        
        if !revenueCatKey.isEmpty {
            Purchases.configure(withAPIKey: revenueCatKey)
            print("✅ RevenueCat configured")
            
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
