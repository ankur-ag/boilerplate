//
//  SettingsView.swift
//  boilerplate
//
//  Settings screen matching Figma designs
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var appConfigManager: AppConfigManager
    @EnvironmentObject private var usageManager: UsageManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Title
                        Text("Settings")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.primaryOrange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.top, 60)
                            .padding(.bottom, DesignSystem.Spacing.xl)
                        
                        // Subscription Section
                        SettingsSectionHeader(title: "Subscription")
                        subscriptionSection
                        
                        // Account Section
                        SettingsSectionHeader(title: "Account")
                        accountSection
                        
                        // Legal Section
                        SettingsSectionHeader(title: "Legal")
                        legalSection
                        
                        // Debug Section
                        #if DEBUG
                        SettingsSectionHeader(title: "Debug")
                        debugSection
                        #endif
                        
                        // Version Info
                        versionInfo
                            .padding(.top, DesignSystem.Spacing.xxl)
                        
                        // Log Out Button
                        logOutButton
                            .padding(.top, DesignSystem.Spacing.xl)
                            .padding(.bottom, DesignSystem.Spacing.xxl)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showFeedback) {
                FeedbackView()
            }
            .sheet(isPresented: $viewModel.showTailorProfile) {
                TailorView()
            }
            .sheet(isPresented: $viewModel.showTerms) {
                TermsView()
            }
            .sheet(isPresented: $viewModel.showPrivacy) {
                PrivacyView()
            }
            .sheet(isPresented: $viewModel.showPaywall) {
                PaywallView()
            }
            .alert("Sign Out", isPresented: $viewModel.showSignOutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    Task {
                        await authManager.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Reset Onboarding", isPresented: $viewModel.showResetOnboardingConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset & Restart", role: .destructive) {
                    appConfigManager.resetOnboarding()
                    // Force restart by exiting
                    exit(0)
                }
            } message: {
                Text("This will reset your onboarding progress and restart the app. You'll see the welcome screens again.")
            }
        }
    }
    
    // MARK: - Subscription Section
    
    private var subscriptionSection: some View {
        VStack(spacing: 0) {
            // Current Plan Card
            if isPremium {
                premiumSubscriptionCard
            } else {
                freeSubscriptionCard
            }
        }
    }
    
    private var isPremium: Bool {
        // Check if user has active subscription
        switch subscriptionManager.subscriptionStatus {
        case .subscribed:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Free Subscription Card
    
    private var freeSubscriptionCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Current Plan")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(DesignSystem.Colors.accentCyan)
                            .frame(width: 8, height: 8)
                        
                        Text("Free Plan")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(DesignSystem.Colors.accentCyan)
                    }
                }
                
                Spacer()
                
                // Lock Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DesignSystem.Colors.backgroundCard)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.primaryOrange)
                }
            }
            
            // Upgrade Button
            Button(action: {
                viewModel.showPaywall = true
            }) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Upgrade to Premium")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(DesignSystem.Colors.primaryOrange)
                .cornerRadius(DesignSystem.CornerRadius.lg)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.backgroundCard)
        .cornerRadius(DesignSystem.CornerRadius.xl)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.xl)
    }
    
    // MARK: - Premium Subscription Card
    
    private var premiumSubscriptionCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Current Plan")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                        
                        Text(premiumPlanName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                // Crown Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(DesignSystem.Colors.primaryOrange.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DesignSystem.Colors.primaryOrange)
                }
            }
            
            // Premium Benefits
            VStack(spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Unlimited roasts")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Priority generation")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("No watermarks")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                    Spacer()
                }
            }
            
            Divider()
                .background(DesignSystem.Colors.border)
            
            // Manage Subscription Button
            Button(action: {
                viewModel.openSubscriptionManagement()
            }) {
                HStack {
                    Text("Manage Subscription")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.accentCyan)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(DesignSystem.Colors.accentCyan)
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.backgroundCard)
        .cornerRadius(DesignSystem.CornerRadius.xl)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.xl)
    }
    
    private var premiumPlanName: String {
        switch subscriptionManager.subscriptionStatus {
        case .subscribed(let tier):
            return "\(tier.rawValue.capitalized) Plan"
        default:
            return "Premium"
        }
    }
    
    // MARK: - Account Section
    
    private var accountSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Tailor Profile Row
            Button(action: {
                viewModel.showTailorProfile = true
            }) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.backgroundCard)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.Colors.primaryOrange)
                    }
                    
                    // Text
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tailor Profile")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Edit your roasting persona")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            
            // Support & Feedback Row
            Button(action: {
                viewModel.showFeedback = true
            }) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.backgroundCard)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "message.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.Colors.primaryOrange)
                    }
                    
                    // Text
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Support & Feedback")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Get help or request features")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.xl)
    }
    
    // MARK: - Legal Section
    
    private var legalSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Terms & Conditions Row
            Button(action: {
                viewModel.showTerms = true
            }) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.backgroundCard)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    // Text
                    Text("Terms & Conditions")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            
            // Privacy Policy Row
            Button(action: {
                viewModel.showPrivacy = true
            }) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.backgroundCard)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "shield.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    // Text
                    Text("Privacy Policy")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.xl)
    }
    
    // MARK: - Debug Section
    
    #if DEBUG
    private var debugSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Simulate Premium Row
            Button(action: {
                Task {
                    if isPremium {
                        await subscriptionManager.updateSubscriptionStatus(.free)
                    } else {
                        await subscriptionManager.updateSubscriptionStatus(.subscribed(tier: .premium))
                    }
                }
            }) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.backgroundCard)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                    }
                    
                    // Text
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isPremium ? "Remove Premium" : "Simulate Premium")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Toggle subscription status")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            
            // Show Paywall Row
            Button(action: {
                viewModel.showPaywall = true
            }) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.backgroundCard)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.Colors.primaryOrange)
                    }
                    
                    // Text
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Show Paywall")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Test premium subscription")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            
            // Reset Onboarding Row
            Button(action: {
                viewModel.showResetOnboardingConfirmation = true
            }) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.backgroundCard)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.Colors.accentYellow)
                    }
                    
                    // Text
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reset Onboarding")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("See welcome screens again")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            
            // Reset Free Roasts Row
            Button(action: {
                usageManager.resetUsage()
            }) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.backgroundCard)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "gobackward")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.Colors.accentCyan)
                    }
                    
                    // Text
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reset Free Roasts")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Text: \(usageManager.textRoastCount)/1, Image: \(usageManager.imageRoastCount)/1")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            
            // Clear All Data Row
            Button(action: {
                viewModel.clearAllData()
            }) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.backgroundCard)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "trash.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DesignSystem.Colors.accentRed)
                    }
                    
                    // Text
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clear All Data")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Delete local cache")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.bottom, DesignSystem.Spacing.xl)
    }
    #endif
    
    // MARK: - Version Info
    
    private var versionInfo: some View {
        Text("Version 2.4.0")
            .font(.system(size: 14))
            .foregroundColor(DesignSystem.Colors.textTertiary)
    }
    
    // MARK: - Log Out Button
    
    private var logOutButton: some View {
        Button(action: {
            viewModel.showSignOutConfirmation = true
        }) {
            Text("Log Out")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.primaryOrange)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthManager())
            .environmentObject(SubscriptionManager())
            .environmentObject(AppConfigManager())
    }
}
