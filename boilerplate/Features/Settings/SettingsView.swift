//
//  SettingsView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var appConfigManager: AppConfigManager
    
    var body: some View {
        NavigationStack {
            List {
                // Account Section
                accountSection
                
                // Subscription Section
                subscriptionSection
                
                // Preferences Section
                preferencesSection
                
                // About Section
                aboutSection
                
                // Debug Section (only in debug builds)
                #if DEBUG
                debugSection
                #endif
            }
            .navigationTitle("Settings")
        }
    }
    
    private var accountSection: some View {
        Section("Account") {
            if let user = authManager.currentUser {
                HStack {
                    Text("User ID")
                    Spacer()
                    Text(user.displayName ?? "Anonymous")
                        .foregroundColor(.secondary)
                }
                
                if user.isAnonymous {
                    Button("Upgrade Account") {
                        Task {
                            await authManager.upgradeAnonymousAccount()
                        }
                    }
                }
            }
            
            Button("Sign Out", role: .destructive) {
                Task {
                    await authManager.signOut()
                }
            }
        }
    }
    
    private var subscriptionSection: some View {
        Section("Subscription") {
            HStack {
                Text("Status")
                Spacer()
                Text(subscriptionStatusText)
                    .foregroundColor(.secondary)
            }
            
            if subscriptionManager.subscriptionStatus == .free {
                Button("Upgrade to Premium") {
                    viewModel.showPaywall = true
                }
            }
            
            Button("Restore Purchases") {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            }
        }
    }
    
    private var preferencesSection: some View {
        Section("Preferences") {
            Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
            
            Toggle("Enable Haptics", isOn: $viewModel.hapticsEnabled)
            
            Picker("Theme", selection: $viewModel.selectedTheme) {
                ForEach(Theme.allCases, id: \.self) { theme in
                    Text(theme.rawValue).tag(theme)
                }
            }
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(appConfigManager.appVersion)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Build")
                Spacer()
                Text(appConfigManager.buildNumber)
                    .foregroundColor(.secondary)
            }
            
            Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
            
            Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
            
            Button("Contact Support") {
                viewModel.contactSupport()
            }
        }
    }
    
    #if DEBUG
    private var debugSection: some View {
        Section("Debug") {
            Button("Reset Onboarding") {
                appConfigManager.resetOnboarding()
            }
            
            Button("Clear All Data", role: .destructive) {
                viewModel.clearAllData()
            }
        }
    }
    #endif
    
    private var subscriptionStatusText: String {
        switch subscriptionManager.subscriptionStatus {
        case .free:
            return "Free"
        case .subscribed(let tier):
            return tier.rawValue.capitalized
        case .expired:
            return "Expired"
        case .cancelled:
            return "Cancelled"
        }
    }
}
