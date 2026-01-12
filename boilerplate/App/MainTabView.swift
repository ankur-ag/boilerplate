//
//  MainTabView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Main tab navigation container
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            PromptView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(Tab.prompt)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(Tab.history)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
    }
}

// MARK: - Tab Enum

enum Tab {
    case home
    case prompt
    case history
    case settings
}
