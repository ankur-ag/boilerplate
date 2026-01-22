//
//  RoastModeSelectionView.swift
//  boilerplate
//
//  Posterized - Mode Selection Screen
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct RoastModeSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMode: RoastMode?
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("New Roast")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.primaryOrange)
                    
                    Text("Select Mode")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                .padding(.top, 60)
                .padding(.bottom, DesignSystem.Spacing.xl)
                
                // Mode Options
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Text Roast Option
                        ModeOptionCard(
                            icon: "text.bubble.fill",
                            iconColor: DesignSystem.Colors.primaryOrange,
                            title: "Text Roast",
                            description: "Paste a chat, bio, or any text to unleash the heat.",
                            buttonText: "Start Text Roast",
                            buttonStyle: .primary,
                            action: {
                                selectedMode = .text
                            }
                        )
                        
                        // Image Roast Option
                        ModeOptionCard(
                            icon: "photo.fill",
                            iconColor: DesignSystem.Colors.accentCyan,
                            title: "Image Roast",
                            description: "Upload a screenshot or photo for visual destruction.",
                            buttonText: "Start Image Roast",
                            buttonStyle: .secondary,
                            action: {
                                selectedMode = .image
                            }
                        )
                        
                        // AI Info Card
                        AIInfoCard()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Mode Option Card

struct ModeOptionCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let buttonText: String
    let buttonStyle: ButtonStyleType
    let action: () -> Void
    
    enum ButtonStyleType {
        case primary
        case secondary
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Icon and Content
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DesignSystem.Colors.backgroundCard)
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(iconColor)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineSpacing(4)
                }
            }
            
            // Action Button
            Button(action: action) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(buttonText)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Image(systemName: buttonStyle == .primary ? "arrow.right" : "camera.fill")
                        .font(.system(size: 16))
                }
                .foregroundColor(buttonStyle == .primary ? .white : .black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(buttonStyle == .primary ? DesignSystem.Colors.primaryOrange : .white)
                .cornerRadius(DesignSystem.CornerRadius.lg)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.backgroundCard)
        .cornerRadius(DesignSystem.CornerRadius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .stroke(DesignSystem.Colors.border.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - AI Info Card

struct AIInfoCard: View {
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Info Icon
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.backgroundCard)
                    .frame(width: 48, height: 48)
                
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text("AI powered")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Our advanced roast engine analyzes context and subtext for maximum psychological damage.")
                    .font(.system(size: 13))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .lineSpacing(3)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.backgroundCard)
        .cornerRadius(DesignSystem.CornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .stroke(DesignSystem.Colors.border.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Roast Mode Enum

enum RoastMode {
    case text
    case image
}

// MARK: - Preview

#Preview {
    RoastModeSelectionView(selectedMode: .constant(nil))
}
