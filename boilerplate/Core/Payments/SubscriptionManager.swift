//
//  SubscriptionManager.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI
import StoreKit
import RevenueCat

/// Manages in-app purchases and subscription state
/// Entitlements-based approach for multi-platform support
@MainActor
class SubscriptionManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .free
    @Published private(set) var entitlements: Set<Entitlement> = []
    @Published private(set) var availablePackages: [Package] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: SubscriptionError?
    
    // MARK: - Private Properties
    
    // RevenueCat listener for customer info updates
    private var customerInfoUpdateListener: Any?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        configureRevenueCat()
    }
    
    private func configureRevenueCat() {
        Purchases.shared.delegate = self
        
        // Initial check
        Task {
            await checkSubscriptionStatus()
        }
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        isLoading = true
        error = nil
        
        do {
            let offerings = try await Purchases.shared.offerings()
            
            if let currentOffering = offerings.current {
                self.availablePackages = currentOffering.availablePackages
                print("✅ Loaded \(availablePackages.count) packages from RevenueCat")
            } else {
                print("⚠️ No current offering found in RevenueCat")
            }
            
            // Check current entitlements
            await checkSubscriptionStatus()
            
        } catch {
            print("❌ Failed to load offerings: \(error)")
            self.error = .productLoadFailed(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase Methods
    
    func purchase(_ package: Package) async throws {
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let result = try await Purchases.shared.purchase(package: package)
            
            if result.userCancelled {
                print("ℹ️ User cancelled purchase")
                throw SubscriptionError.purchaseCancelled
            }
            
            // Update status with new customer info
            await updateStatus(with: result.customerInfo)
            
            print("✅ Purchase successful: \(package.storeProduct.localizedTitle)")
            
        } catch {
            if let subError = error as? SubscriptionError {
                throw subError
            }
            
            let subError = SubscriptionError.purchaseFailed(error.localizedDescription)
            self.error = subError
            throw subError
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        error = nil
        
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            await updateStatus(with: customerInfo)
            print("✅ Purchases restored successfully")
            
        } catch {
            print("❌ Failed to restore purchases: \(error)")
            self.error = .restoreFailed(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // MARK: - Entitlement Checks
    
    func hasEntitlement(_ entitlement: Entitlement) -> Bool {
        return entitlements.contains(entitlement)
    }
    
    func requiresSubscription(for feature: String) -> Bool {
        // TODO: Implement feature-to-entitlement mapping
        return subscriptionStatus == .free
    }
    
    var isPremium: Bool {
        switch subscriptionStatus {
        case .subscribed:
            return true
        case .free, .expired, .cancelled:
            return false
        }
    }
    
    // MARK: - Private Methods
    
    /// Check and update subscription status based on current entitlements
    private func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await updateStatus(with: customerInfo)
        } catch {
            print("❌ Failed to fetch customer info: \(error)")
        }
    }
    
    private func updateStatus(with customerInfo: CustomerInfo) async {
        // Define our entitlement ID (should match RevenueCat dashboard)
        let entitlementID = "premium"
        
        if let entitlement = customerInfo.entitlements[entitlementID], entitlement.isActive {
            // User has active premium entitlement
            subscriptionStatus = .subscribed(tier: .premium)
            entitlements = [
                .basicFeatures,
                .unlimitedMessages,
                .unlimitedTextRoasts,
                .unlimitedImageRoasts,
                .prioritySupport,
                .advancedModels,
                .offlineMode,
                .customization
            ]
            print("✅ Premium entitlement is active")
        } else {
            subscriptionStatus = .free
            entitlements = [.basicFeatures]
            print("ℹ️ No active premium entitlement")
        }
    }
    
    
    // MARK: - Public Update Method (for testing/development)
    
    func updateSubscriptionStatus(_ status: SubscriptionStatus) async {
        self.subscriptionStatus = status
        
        // Update entitlements based on status
        switch status {
        case .subscribed(let tier):
            // Grant premium entitlements
            entitlements = [
                .basicFeatures,
                .unlimitedMessages,
                .unlimitedTextRoasts,
                .unlimitedImageRoasts,
                .prioritySupport,
                .advancedModels,
                .offlineMode,
                .customization
            ]
            print("✅ Subscription updated to: \(tier.rawValue)")
        case .free:
            entitlements = [.basicFeatures]
        case .expired, .cancelled:
            entitlements = [.basicFeatures]
        }
    }
}

// MARK: - PurchasesDelegate

extension SubscriptionManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task {
            await updateStatus(with: customerInfo)
        }
    }
}

// MARK: - Subscription Models

enum SubscriptionStatus: Equatable {
    case free
    case subscribed(tier: SubscriptionTier)
    case expired
    case cancelled
}

enum SubscriptionTier: String {
    case premium = "premium"
    case monthly = "monthly"
    case yearly = "yearly"
    case annual = "annual"
    case lifetime = "lifetime"
}

enum Entitlement: String, Hashable {
    case basicFeatures
    case unlimitedMessages
    case unlimitedTextRoasts
    case unlimitedImageRoasts
    case prioritySupport
    case advancedModels
    case offlineMode
    case customization
    
    // TODO: Add more entitlements as needed
}

// MARK: - Subscription Error

enum SubscriptionError: LocalizedError {
    case productLoadFailed(String)
    case purchaseFailed(String)
    case restoreFailed(String)
    case verificationFailed
    case purchaseCancelled
    case purchasePending
    case unknownError
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .productLoadFailed(let message):
            return "Failed to load products: \(message)"
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .restoreFailed(let message):
            return "Restore failed: \(message)"
        case .verificationFailed:
            return "Failed to verify purchase"
        case .purchaseCancelled:
            return "Purchase was cancelled"
        case .purchasePending:
            return "Purchase is pending approval"
        case .unknownError:
            return "An unknown error occurred"
        case .cancelled:
            return "Purchase was cancelled"
        }
    }
}
