//
//  SettingsViewModel.swift
//  boilerplate
//
//  Settings view model
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI
import StoreKit

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var notificationsEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true
    @Published var selectedTheme: Theme = .system
    @Published var showPaywall: Bool = false
    @Published var showFeedback: Bool = false
    @Published var showTailorProfile: Bool = false
    @Published var showTerms: Bool = false
    @Published var showPrivacy: Bool = false
    @Published var showRoastStylePicker: Bool = false
    @Published var showAbout: Bool = false
    @Published var showSignOutConfirmation: Bool = false
    @Published var showResetOnboardingConfirmation: Bool = false
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        hapticsEnabled = UserDefaults.standard.bool(forKey: "hapticsEnabled")
        
        if let themeRaw = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = Theme(rawValue: themeRaw) {
            selectedTheme = theme
        }
    }
    
    func saveSettings() {
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        UserDefaults.standard.set(hapticsEnabled, forKey: "hapticsEnabled")
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
    }
    
    func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func openHelpCenter() {
        if let url = URL(string: "https://posterized.app/help") {
            UIApplication.shared.open(url)
        }
    }
    
    func openTerms() {
        if let url = URL(string: "https://posterized.app/terms") {
            UIApplication.shared.open(url)
        }
    }
    
    func openPrivacy() {
        if let url = URL(string: "https://posterized.app/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    func clearAllData() {
        // Clear UserDefaults
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // Clear local storage
        let storageManager = StorageManager()
        try? storageManager.clearAll()
    }
    
    func openSubscriptionManagement() {
        // Open iOS Subscription Management
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Theme

enum Theme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}
