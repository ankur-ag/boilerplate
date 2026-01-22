//
//  MainTabView.swift
//  boilerplate
//
//  Main tab navigation matching Figma designs
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Main tab navigation container for Posterized
struct MainTabView: View {
    @State private var selectedTab: Tab = .roast
    
    init() {
        // Customize tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(DesignSystem.Colors.backgroundSecondary)
        
        // Selected item color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(DesignSystem.Colors.primaryOrange)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(DesignSystem.Colors.primaryOrange)
        ]
        
        // Normal item color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(DesignSystem.Colors.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(DesignSystem.Colors.textSecondary)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Posterize Tab
            RoastFlowView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.roast)
            
            // History Tab
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(Tab.history)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .tint(DesignSystem.Colors.primaryOrange)
    }
}

// MARK: - Tab Enum

enum Tab {
    case roast
    case history
    case settings
}

#Preview {
    MainTabView()
        .environmentObject(LLMManager())
        .environmentObject(AuthManager())
        .environmentObject(SubscriptionManager())
        .environmentObject(FeatureFlagManager())
        .environmentObject(AppConfigManager())
}
