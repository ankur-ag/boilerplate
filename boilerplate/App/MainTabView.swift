//
//  MainTabView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

/// Main tab navigation container for RoastGPT Clone
struct MainTabView: View {
    @State private var selectedTab: Tab = .text
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TextRoastView()
                .tabItem {
                    Label("Text", systemImage: "text.quote")
                }
                .tag(Tab.text)
            
            ImageRoastView()
                .tabItem {
                    Label("Image", systemImage: "photo")
                }
                .tag(Tab.image)
            
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
    case text
    case image
    case history
}
