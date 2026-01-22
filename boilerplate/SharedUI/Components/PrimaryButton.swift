//
//  PrimaryButton.swift
//  boilerplate
//
//  Primary branded button matching Figma designs
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Primary orange button matching Figma designs
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var fullWidth: Bool = true
    
    init(
        _ title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.fullWidth = fullWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: DesignSystem.IconSize.sm, weight: .semibold))
                }
                
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: 54)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .background(
                backgroundColor
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
        }
        .disabled(isDisabled || isLoading)
        .scaleEffect(isDisabled ? 0.98 : 1.0)
        .animation(DesignSystem.Animation.quick, value: isDisabled)
    }
    
    private var backgroundColor: Color {
        if isDisabled {
            return DesignSystem.Colors.textSecondary.opacity(0.3)
        } else if isLoading {
            return DesignSystem.Colors.primaryOrange.opacity(0.8)
        } else {
            return DesignSystem.Colors.primaryOrange
        }
    }
}

/// Secondary button with outline style
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isDisabled: Bool = false
    var fullWidth: Bool = true
    
    init(
        _ title: String,
        icon: String? = nil,
        isDisabled: Bool = false,
        fullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDisabled = isDisabled
        self.fullWidth = fullWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: DesignSystem.IconSize.sm, weight: .semibold))
                }
                
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isDisabled ? DesignSystem.Colors.textSecondary : DesignSystem.Colors.primaryOrange)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .frame(height: 54)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.backgroundSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(isDisabled ? DesignSystem.Colors.border : DesignSystem.Colors.primaryOrange, lineWidth: DesignSystem.BorderWidth.regular)
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
        }
        .disabled(isDisabled)
        .scaleEffect(isDisabled ? 0.98 : 1.0)
        .animation(DesignSystem.Animation.quick, value: isDisabled)
    }
}

#Preview("Primary Button") {
    VStack(spacing: 20) {
        PrimaryButton("Generate Roast", icon: "flame.fill", action: {})
        PrimaryButton("Loading...", isLoading: true, action: {})
        PrimaryButton("Disabled", isDisabled: true, action: {})
    }
    .padding()
    .background(DesignSystem.Colors.backgroundPrimary)
}

#Preview("Secondary Button") {
    VStack(spacing: 20) {
        SecondaryButton("Cancel", action: {})
        SecondaryButton("Regenerate", icon: "arrow.clockwise", action: {})
        SecondaryButton("Disabled", isDisabled: true, action: {})
    }
    .padding()
    .background(DesignSystem.Colors.backgroundPrimary)
}
