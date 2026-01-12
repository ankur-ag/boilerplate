//
//  MainTabView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Main tab navigation container for RoastGPT Clone
struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Roast", systemImage: "flame.fill")
                }
                .tag(Tab.home)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(Tab.history)
        }
        .accentColor(.orange)
    }
}

// MARK: - Tab Enum

enum Tab {
    case home
    case history
}
