//
//  SettingsRow.swift
//  boilerplate
//
//  Settings row components matching Figma designs
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Standard settings row with icon, label, and navigation
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let value: String?
    let showChevron: Bool
    let action: () -> Void
    
    init(
        icon: String,
        iconColor: Color = DesignSystem.Colors.primaryOrange,
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        showChevron: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: DesignSystem.IconSize.md))
                        .foregroundColor(iconColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DesignSystem.Typography.footnote)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Value & Chevron
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if let value = value {
                        Text(value)
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    if showChevron {
                        Image(systemName: "chevron.right")
                            .font(.system(size: DesignSystem.IconSize.sm, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.backgroundCard)
            .cornerRadius(DesignSystem.CornerRadius.md)
        }
    }
}

/// Settings row with toggle switch
struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    
    init(
        icon: String,
        iconColor: Color = DesignSystem.Colors.primaryOrange,
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: DesignSystem.IconSize.md))
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.footnote)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(DesignSystem.Colors.primaryOrange)
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.backgroundCard)
        .cornerRadius(DesignSystem.CornerRadius.md)
    }
}

/// Section header for settings groups
struct SettingsSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(DesignSystem.Typography.caption1)
            .fontWeight(.semibold)
            .foregroundColor(DesignSystem.Colors.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.xs)
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.md) {
        SettingsSectionHeader(title: "Account")
        
        SettingsRow(
            icon: "person.circle.fill",
            iconColor: DesignSystem.Colors.accentBlue,
            title: "Profile",
            subtitle: "Manage your account",
            action: {}
        )
        
        SettingsRow(
            icon: "crown.fill",
            iconColor: DesignSystem.Colors.accentYellow,
            title: "Subscription",
            subtitle: "Free Plan",
            value: "Upgrade",
            action: {}
        )
        
        SettingsSectionHeader(title: "Preferences")
        
        SettingsToggleRow(
            icon: "moon.fill",
            iconColor: DesignSystem.Colors.accentBlue,
            title: "Dark Mode",
            subtitle: "Always use dark theme",
            isOn: .constant(true)
        )
        
        SettingsToggleRow(
            icon: "bell.fill",
            iconColor: DesignSystem.Colors.primaryOrange,
            title: "Notifications",
            isOn: .constant(false)
        )
    }
    .padding()
    .background(DesignSystem.Colors.backgroundPrimary)
}
