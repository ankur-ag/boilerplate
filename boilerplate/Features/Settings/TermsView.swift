//
//  TermsView.swift
//  boilerplate
//
//  Terms & Conditions Screen
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct TermsView: View {
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
                            Text("Terms of Service")
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
                            Group {
                                Text("1. Acceptance of Terms")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("By downloading, installing, or using the Posterized application (the \"App\"), you agree to be bound by these Terms of Service (\"Terms\"). If you do not agree to these Terms, do not use the App.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                                
                                Text("2. Eligibility & Registration")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("**Age Requirement**\nYou must be at least 16 years old to use Posterized. The App is not directed at children under 16, and we do not knowingly collect data from anyone under 16.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                            }
                            
                            Group {
                                Text("3. Subscriptions, Billing & Refunds")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("Posterized offers a free tier and optional paid access:\n\n• **Free tier:** Limited free roasts with watermarked outputs and feature restrictions.\n• **Paid plans:** Auto-renewing subscriptions and may include a one-time lifetime plan.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                                
                                Text("**Cancellation**\nYou may cancel your subscription at any time through iOS Settings. Your subscription remains active until the end of the current billing period.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                            }
                            
                            Group {
                                Text("4. Acceptable Use Policy")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("You agree NOT to use Posterized to:\n\n• Create or share illegal content or threats of violence.\n• Generate or distribute hate speech targeting protected characteristics.\n• Upload or create non-consensual intimate imagery.\n• Harass, bully, or threaten any individual or group.\n• Infringe on third-party intellectual property rights.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                            }
                            
                            Group {
                                Text("5. Intellectual Property")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("Posterized is owned by HYRE Talent Sourcing and Matching GmbH. You retain rights to User Content you upload, but grant us a limited license to host and process it to provide the service.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                                
                                Text("6. AI-Generated Content Disclaimer")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("AI Content is intended only for fun and entertainment. It is not factual information or professional advice. Despite moderation, AI Content may be offensive, crude, or inaccurate.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                            }
                            
                            Group {
                                Text("7. Warranty Disclaimer")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("THE APP AND ALL CONTENT ARE PROVIDED \"AS IS\" AND \"AS AVAILABLE,\" WITHOUT ANY WARRANTY OF ANY KIND.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                                
                                Text("8. Limitation of Liability")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("To the maximum extent permitted by law, we are not liable for any indirect, incidental, special, or consequential damages. Our total liability is limited to the amount paid in the 12 months prior to the claim.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                            }
                            
                            Group {
                                Text("9. Governing Law")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("These Terms are governed by the laws of the Federal Republic of Germany. You agree to the exclusive jurisdiction of the courts of Berlin, Germany.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                                
                                Text("10. Contact")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("Support: support@hyretalents.com\nHYRE Talent Sourcing and Matching GmbH\nWarnerweg 13, 14052 Berlin, Germany")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                            }
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
}

#Preview {
    TermsView()
}
