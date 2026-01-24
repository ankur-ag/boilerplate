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
                            Group {
                                Text("1. Introduction")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("Posterized is an AI roasting app operated by HYRE Talent Sourcing and Matching GmbH. We are committed to protecting your personal data and explaining how we use and process it.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                                
                                Text("2. Data We Collect")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("**Account Information**\nWe collect pseudonymous identifiers, and if shared, email/name via Apple Sign-In.\n\n**Usage & Analytics**\nWe use Firebase to track in-app events, device data, and app interactions to improve our service.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                                
                                Text("**Roast Content & Media**\nWe store images and text inputs you provide, along with AI-generated outputs, in Firebase Storage and Firestore.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                            }
                            
                            Group {
                                Text("3. How We Use Your Data")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("We use data to operate the app, generate AI roasts, analyze user experience, ensure safety/moderation, and comply with legal obligations.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                                
                                Text("4. Third-Party AI Processing")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("**Google Gemini & OpenAI**\nWe send images and text to Google and OpenAI to generate roasts. Under our commercial configuration, this data is NOT used to train their models and is typically deleted after 30-60 days.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                            }
                            
                            Group {
                                Text("5. Data Sharing")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("We do NOT sell your personal data. We only share data with essential processors (Apple, Google, OpenAI) or when required by law.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                                
                                Text("6. International Transfers")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("Data may be processed in countries outside your own, including the USA, subject to appropriate safeguards like Standard Contractual Clauses.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                            }
                            
                            Group {
                                Text("7. Data Retention")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("We keep identifying data as long as your account is active, but delete it within 30 days of closure or after 12 months of inactivity.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                                
                                Text("8. Your Rights")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("Depending on your location (e.g. GDPR), you have rights to access, update, or delete your personal data. Contact us at privacy@hyretalents.com for requests.")
                                    .font(.system(size: 15))
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                                    .lineSpacing(4)
                            }
                            
                            Group {
                                Text("9. Contact Us")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                
                                Text("Privacy Enquiries: privacy@hyretalents.com\nHYRE Talent Sourcing and Matching GmbH\nWarnerweg 13, 14052 Berlin, Germany")
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
    PrivacyView()
}
