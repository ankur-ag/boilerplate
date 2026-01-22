//
//  RoastCard.swift
//  boilerplate
//
//  Card component for displaying roast output
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Card container for roast text output matching Figma designs
struct RoastCard: View {
    let title: String
    let text: String
    let isStreaming: Bool
    let onCopy: () -> Void
    let onShare: () -> Void
    let onRegenerate: (() -> Void)?
    
    init(
        title: String = "Your Roast",
        text: String,
        isStreaming: Bool = false,
        onCopy: @escaping () -> Void,
        onShare: @escaping () -> Void,
        onRegenerate: (() -> Void)? = nil
    ) {
        self.title = title
        self.text = text
        self.isStreaming = isStreaming
        self.onCopy = onCopy
        self.onShare = onShare
        self.onRegenerate = onRegenerate
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: DesignSystem.IconSize.md))
                    .foregroundColor(DesignSystem.Colors.primaryOrange)
                
                Text(title)
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                if isStreaming {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text("Writing...")
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            
            // Roast Text
            ScrollView {
                Text(text)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineSpacing(DesignSystem.Typography.bodyLineSpacing - 17)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .frame(minHeight: 100, maxHeight: 300)
            
            // Action Buttons
            HStack(spacing: DesignSystem.Spacing.sm) {
                ActionButton(icon: "square.and.arrow.up", label: "Forward", action: onShare)
                
                if let onRegenerate = onRegenerate {
                    ActionButton(icon: "arrow.clockwise", label: "Regenerate", action: onRegenerate)
                }
                
                Spacer()
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.backgroundCard)
        .cornerRadius(DesignSystem.CornerRadius.md)
        .designSystemShadow(DesignSystem.Shadow.card)
    }
}

/// Small action button for roast card actions
private struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: icon)
                    .font(.system(size: DesignSystem.IconSize.sm))
                Text(label)
                    .font(DesignSystem.Typography.footnote)
            }
            .foregroundColor(DesignSystem.Colors.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(DesignSystem.Colors.backgroundTertiary)
            .cornerRadius(DesignSystem.CornerRadius.sm)
        }
    }
}

#Preview {
    VStack {
        RoastCard(
            text: "Wow, you really thought this was a good idea? I've seen better attempts from a blindfolded toddler with mittens on. Your creativity is about as sharp as a marble.",
            isStreaming: false,
            onCopy: {},
            onShare: {},
            onRegenerate: {}
        )
        
        RoastCard(
            text: "Loading response...",
            isStreaming: true,
            onCopy: {},
            onShare: {}
        )
    }
    .padding()
    .background(DesignSystem.Colors.backgroundPrimary)
}
