//
//  PrivacyView.swift
//  boilerplate
//
//  Privacy Policy Screen
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                        // Header
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Privacy Policy")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(DesignSystem.Colors.primaryOrange)
                            
                            Text("Last updated: January 2026")
                                .font(.system(size: 14))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        .padding(.top, DesignSystem.Spacing.lg)
                        
                        Divider()
                            .background(DesignSystem.Colors.border)
                        
                        // Content
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                            privacySection(
                                title: "Introduction",
                                content: "Welcome to Posterized. We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we collect, use, and safeguard your information when you use our app."
                            )
                            
                            privacySection(
                                title: "Information We Collect",
                                content: "We collect the following types of information:\n\n• Account Information: When you create an account, we collect your email address and authentication details.\n\n• Usage Data: We collect information about how you use the app, including roast generations, features accessed, and interaction patterns.\n\n• Device Information: We collect device type, operating system version, and unique device identifiers.\n\n• User Preferences: Your selected teams, roast intensity preferences, and app settings."
                            )
                            
                            privacySection(
                                title: "How We Use Your Information",
                                content: "We use your information to:\n\n• Provide and maintain our service\n• Generate AI-powered roasts based on your preferences\n• Improve and personalize your experience\n• Process subscriptions and payments\n• Send you updates and notifications (with your consent)\n• Analyze usage patterns to improve the app\n• Prevent fraud and ensure security"
                            )
                            
                            privacySection(
                                title: "Data Sharing and Disclosure",
                                content: "We do not sell your personal data. We may share your information with:\n\n• Service Providers: We use Firebase for authentication and data storage, and OpenAI for AI roast generation.\n\n• Analytics Partners: We may use analytics services to understand app usage.\n\n• Legal Requirements: We may disclose information if required by law or to protect our rights."
                            )
                            
                            privacySection(
                                title: "Your Roast Content",
                                content: "Text and images you submit are processed by our AI service (OpenAI) to generate roasts. We do not permanently store your input text or images beyond what's necessary for the service. Generated roasts are stored in your account history."
                            )
                            
                            privacySection(
                                title: "Data Security",
                                content: "We implement industry-standard security measures to protect your data, including encryption in transit and at rest. However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security."
                            )
                            
                            privacySection(
                                title: "Your Rights",
                                content: "You have the right to:\n\n• Access your personal data\n• Correct inaccurate data\n• Delete your account and data\n• Opt-out of marketing communications\n• Withdraw consent for data processing\n\nTo exercise these rights, contact us at privacy@posterized.app"
                            )
                            
                            privacySection(
                                title: "Children's Privacy",
                                content: "Posterized is not intended for users under 13 years of age. We do not knowingly collect personal information from children under 13. If you believe we have collected such information, please contact us immediately."
                            )
                            
                            privacySection(
                                title: "Changes to This Policy",
                                content: "We may update this privacy policy from time to time. We will notify you of any material changes by posting the new policy in the app and updating the \"Last updated\" date."
                            )
                            
                            privacySection(
                                title: "Contact Us",
                                content: "If you have any questions about this Privacy Policy, please contact us at:\n\nprivacy@posterized.app\n\nOr write to us at:\nPosterized\n[Your Company Address]"
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
        }
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .lineSpacing(4)
        }
    }
}

#Preview {
    PrivacyView()
}
