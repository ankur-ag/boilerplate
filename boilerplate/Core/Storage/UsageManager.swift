//
//  UsageManager.swift
//  boilerplate
//
//  Posterized - Track free tier usage
//  Created by Ankur on 1/12/26.
//

import Foundation

/// Manages free tier usage limits
class UsageManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var textRoastCount: Int = 0
    @Published private(set) var imageRoastCount: Int = 0
    
    // MARK: - Constants
    
    private let freeTextRoastLimit = 1
    private let freeImageRoastLimit = 1
    
    // MARK: - Storage Keys
    
    private enum Keys {
        static let textRoastCount = "usage_text_roast_count"
        static let imageRoastCount = "usage_image_roast_count"
        static let lastResetDate = "usage_last_reset_date"
    }
    
    // MARK: - Initialization
    
    init() {
        loadUsage()
    }
    
    // MARK: - Usage Checks
    
    /// Checks if user can generate a text roast
    /// Logic:
    /// 1. If user has active premium subscription → Always allowed (unlimited)
    /// 2. If user is free tier → Check if they have free credits remaining (< 1)
    func canGenerateTextRoast(isPremium: Bool) -> Bool {
        // Premium users: unlimited roasts
        if isPremium {
            print("✅ Text roast allowed: Premium subscription active")
            return true
        }
        
        // Free users: check remaining credits
        let hasCredits = textRoastCount < freeTextRoastLimit
        if hasCredits {
            print("✅ Text roast allowed: Free credit available (\(textRoastCount)/\(freeTextRoastLimit))")
        } else {
            print("❌ Text roast blocked: No free credits, no subscription (\(textRoastCount)/\(freeTextRoastLimit))")
        }
        return hasCredits
    }
    
    /// Checks if user can generate an image roast
    /// Logic:
    /// 1. If user has active premium subscription → Always allowed (unlimited)
    /// 2. If user is free tier → Check if they have free credits remaining (< 1)
    func canGenerateImageRoast(isPremium: Bool) -> Bool {
        // Premium users: unlimited roasts
        if isPremium {
            print("✅ Image roast allowed: Premium subscription active")
            return true
        }
        
        // Free users: check remaining credits
        let hasCredits = imageRoastCount < freeImageRoastLimit
        if hasCredits {
            print("✅ Image roast allowed: Free credit available (\(imageRoastCount)/\(freeImageRoastLimit))")
        } else {
            print("❌ Image roast blocked: No free credits, no subscription (\(imageRoastCount)/\(freeImageRoastLimit))")
        }
        return hasCredits
    }
    
    func hasUsedFreeRoasts() -> Bool {
        return textRoastCount >= freeTextRoastLimit || imageRoastCount >= freeImageRoastLimit
    }
    
    // MARK: - Usage Tracking
    
    func incrementTextRoastCount() {
        textRoastCount += 1
        saveUsage()
    }
    
    func incrementImageRoastCount() {
        imageRoastCount += 1
        saveUsage()
    }
    
    // MARK: - Reset
    
    func resetUsage() {
        textRoastCount = 0
        imageRoastCount = 0
        saveUsage()
        print("✅ Usage reset")
    }
    
    // MARK: - Persistence
    
    private func loadUsage() {
        textRoastCount = UserDefaults.standard.integer(forKey: Keys.textRoastCount)
        imageRoastCount = UserDefaults.standard.integer(forKey: Keys.imageRoastCount)
        
        print("📊 Usage loaded: Text=\(textRoastCount), Image=\(imageRoastCount)")
    }
    
    private func saveUsage() {
        UserDefaults.standard.set(textRoastCount, forKey: Keys.textRoastCount)
        UserDefaults.standard.set(imageRoastCount, forKey: Keys.imageRoastCount)
        
        print("💾 Usage saved: Text=\(textRoastCount), Image=\(imageRoastCount)")
    }
}
