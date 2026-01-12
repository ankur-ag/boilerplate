//
//  SettingsViewModel.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true
    @Published var selectedTheme: Theme = .system
    @Published var showPaywall: Bool = false
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        // TODO: Load from UserDefaults
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        hapticsEnabled = UserDefaults.standard.bool(forKey: "hapticsEnabled")
        
        if let themeRaw = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = Theme(rawValue: themeRaw) {
            selectedTheme = theme
        }
    }
    
    func saveSettings() {
        // TODO: Save to UserDefaults
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(hapticsEnabled, forKey: "hapticsEnabled")
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
    }
    
    func contactSupport() {
        // TODO: Open email or support form
    }
    
    func clearAllData() {
        // TODO: Clear all local data
    }
}

// MARK: - Theme

enum Theme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}
