//
//  DesignSystem.swift
//  boilerplate
//
//  Design tokens and styling system matching Figma designs
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Centralized design system for consistent styling across the app
enum DesignSystem {
    
    // MARK: - Colors
    
    enum Colors {
        // Primary Colors
        static let primaryOrange = Color(hex: "FF5722")
        static let primaryOrangeDark = Color(hex: "E64A19")
        
        // Backgrounds
        static let backgroundPrimary = Color(hex: "000000")
        static let backgroundSecondary = Color(hex: "1C1C1E")
        static let backgroundTertiary = Color(hex: "2C2C2E")
        static let backgroundCard = Color(hex: "1C1C1E")
        
        // Text Colors
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "EBEBF5").opacity(0.6)
        static let textTertiary = Color(hex: "EBEBF5").opacity(0.3)
        static let textPlaceholder = Color(hex: "EBEBF5").opacity(0.3)
        
        // Accent Colors
        static let accentBlue = Color(hex: "007AFF")
        static let accentCyan = Color(hex: "00D9FF") // Posterized selection color
        static let accentGreen = Color(hex: "34C759")
        static let accentRed = Color(hex: "FF3B30")
        static let accentYellow = Color(hex: "FFCC00")
        
        // Border & Divider
        static let border = Color(hex: "38383A")
        static let divider = Color(hex: "38383A").opacity(0.65)
        
        // Input
        static let inputBackground = Color(hex: "1C1C1E")
        static let inputBorder = Color(hex: "38383A")
        static let inputFocused = primaryOrange
        
        // Status
        static let success = accentGreen
        static let error = accentRed
        static let warning = accentYellow
        static let info = accentBlue
    }
    
    // MARK: - Typography
    
    enum Typography {
        // Large Title
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let largeTitleLineSpacing: CGFloat = 41
        
        // Title 1
        static let title1 = Font.system(size: 28, weight: .bold)
        static let title1LineSpacing: CGFloat = 34
        
        // Title 2
        static let title2 = Font.system(size: 22, weight: .bold)
        static let title2LineSpacing: CGFloat = 28
        
        // Title 3
        static let title3 = Font.system(size: 20, weight: .semibold)
        static let title3LineSpacing: CGFloat = 25
        
        // Headline
        static let headline = Font.system(size: 17, weight: .semibold)
        static let headlineLineSpacing: CGFloat = 22
        
        // Body
        static let body = Font.system(size: 17, weight: .regular)
        static let bodyLineSpacing: CGFloat = 22
        
        // Callout
        static let callout = Font.system(size: 16, weight: .regular)
        static let calloutLineSpacing: CGFloat = 21
        
        // Subheadline
        static let subheadline = Font.system(size: 15, weight: .regular)
        static let subheadlineLineSpacing: CGFloat = 20
        
        // Footnote
        static let footnote = Font.system(size: 13, weight: .regular)
        static let footnoteLineSpacing: CGFloat = 18
        
        // Caption 1
        static let caption1 = Font.system(size: 12, weight: .regular)
        static let caption1LineSpacing: CGFloat = 16
        
        // Caption 2
        static let caption2 = Font.system(size: 11, weight: .regular)
        static let caption2LineSpacing: CGFloat = 13
    }
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
        static let xxxxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let full: CGFloat = 999
    }
    
    // MARK: - Shadow
    
    enum Shadow {
        static let small = ShadowStyle(
            color: Color.black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )
        
        static let medium = ShadowStyle(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let large = ShadowStyle(
            color: Color.black.opacity(0.2),
            radius: 16,
            x: 0,
            y: 8
        )
        
        static let card = ShadowStyle(
            color: Color.black.opacity(0.25),
            radius: 12,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Border Width
    
    enum BorderWidth {
        static let thin: CGFloat = 0.5
        static let regular: CGFloat = 1
        static let medium: CGFloat = 1.5
        static let thick: CGFloat = 2
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    }
    
    // MARK: - Icon Sizes
    
    enum IconSize {
        static let xs: CGFloat = 12
        static let sm: CGFloat = 16
        static let md: CGFloat = 20
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
    }
}

// MARK: - Shadow Style

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extension for Shadows

extension View {
    func designSystemShadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
