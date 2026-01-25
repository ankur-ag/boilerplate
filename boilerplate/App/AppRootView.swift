//
//  AppRootView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Root view that handles app-level routing based on authentication and onboarding state
struct AppRootView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var appConfigManager: AppConfigManager
    
    var body: some View {
        Group {
            switch appState {
            case .loading:
                LoadingView()
            case .onboarding:
                OnboardingView()
            case .authenticated:
                MainTabView()
            case .unauthenticated:
                OnboardingView()
            }
        }
        .task {
            await initializeApp()
        }
    }
    
    // MARK: - App State
    
    private var appState: AppState {
        if authManager.isInitializing || appConfigManager.isLoading {
            return .loading
        }
        
        if !appConfigManager.hasCompletedOnboarding {
            return .onboarding
        }
        
        if authManager.isAuthenticated {
            return .authenticated
        }
        
        return .unauthenticated
    }
    
    // MARK: - Initialization
    
    private func initializeApp() async {
        // Initialize managers in parallel
        async let authInit: () = authManager.initialize()
        async let configInit: () = appConfigManager.loadConfig()
        
        _ = await (authInit, configInit)
    }
}

// MARK: - App State Enum

enum AppState {
    case loading
    case onboarding
    case authenticated
    case unauthenticated
}

// MARK: - Loading View

private struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
