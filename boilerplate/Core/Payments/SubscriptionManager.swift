//
//  SubscriptionManager.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI
import StoreKit

/// Manages in-app purchases and subscription state
/// Entitlements-based approach for multi-platform support
@MainActor
class SubscriptionManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .free
    @Published private(set) var entitlements: Set<Entitlement> = []
    @Published private(set) var availableProducts: [Product] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: SubscriptionError?
    
    // MARK: - Private Properties
    
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Initialization
    
    init() {
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        isLoading = true
        error = nil
        
        do {
            // Load products from StoreKit using actual product IDs
            availableProducts = try await Product.products(for: ProductIdentifier.allProducts)
            
            print("✅ Loaded \(availableProducts.count) products from StoreKit")
            for product in availableProducts {
                print("  - \(product.displayName): \(product.displayPrice)")
            }
            
            // Check current entitlements
            await checkSubscriptionStatus()
            
        } catch {
            print("❌ Failed to load products: \(error)")
            self.error = .productLoadFailed(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase Methods
    
    func purchase(_ product: Product) async throws {
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            // Attempt purchase
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify transaction
                let transaction = try checkVerified(verification)
                
                // Update user entitlements
                await updateEntitlements(for: transaction)
                
                // Finish the transaction
                await transaction.finish()
                
                print("✅ Purchase successful: \(product.displayName)")
                
            case .userCancelled:
                print("ℹ️ User cancelled purchase")
                throw SubscriptionError.purchaseCancelled
                
            case .pending:
                print("⏳ Purchase pending approval")
                throw SubscriptionError.purchasePending
                
            @unknown default:
                print("❌ Unknown purchase result")
                throw SubscriptionError.unknownError
            }
            
        } catch {
            let subError = error as? SubscriptionError ?? .purchaseFailed(error.localizedDescription)
            self.error = subError
            throw subError
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        error = nil
        
        do {
            // Sync with App Store to restore purchases
            try await AppStore.sync()
            
            // Check subscription status after sync
            await checkSubscriptionStatus()
            
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
        var hasActiveSubscription = false
        var activeTier: SubscriptionTier?
        
        // Check for active subscriptions
        for await result in StoreKit.Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            // Check if transaction is for one of our products
            if let tier = ProductTier(productId: transaction.productID) {
                hasActiveSubscription = true
                
                // Determine subscription tier
                switch tier {
                case .lifetime:
                    activeTier = .lifetime
                case .annual:
                    activeTier = .annual
                case .monthly:
                    activeTier = .monthly
                case .weekly:
                    activeTier = .premium // Map weekly to premium
                }
                
                print("✅ Active subscription found: \(tier.displayName)")
                break
            }
        }
        
        // Update subscription status
        if hasActiveSubscription, let tier = activeTier {
            subscriptionStatus = .subscribed(tier: tier)
            entitlements = [
                .basicFeatures,
                .unlimitedMessages,
                .prioritySupport,
                .advancedModels,
                .offlineMode,
                .customization
            ]
        } else {
            subscriptionStatus = .free
            entitlements = [.basicFeatures]
        }
    }
    
    /// Update entitlements after a purchase
    private func updateEntitlements(for transaction: StoreKit.Transaction) async {
        guard let tier = ProductTier(productId: transaction.productID) else {
            print("⚠️ Unknown product: \(transaction.productID)")
            return
        }
        
        // Map product tier to subscription tier
        let subscriptionTier: SubscriptionTier
        switch tier {
        case .lifetime:
            subscriptionTier = .lifetime
        case .annual:
            subscriptionTier = .annual
        case .monthly:
            subscriptionTier = .monthly
        case .weekly:
            subscriptionTier = .premium
        }
        
        // Update status
        subscriptionStatus = .subscribed(tier: subscriptionTier)
        entitlements = [
            .basicFeatures,
            .unlimitedMessages,
            .prioritySupport,
            .advancedModels,
            .offlineMode,
            .customization
        ]
        
        print("✅ Entitlements updated for: \(tier.displayName)")
    }
    
    /// Verify transaction to prevent fraud
    private func checkVerified<T>(_ result: StoreKit.VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            // Transaction failed verification
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            // Transaction is verified
            return safe
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { @MainActor [weak self] in
            // Listen for transaction updates
            for await result in StoreKit.Transaction.updates {
                await self?.handleTransaction(result)
            }
        }
    }
    
    private func handleTransaction(_ result: StoreKit.VerificationResult<StoreKit.Transaction>) async {
        do {
            let transaction = try checkVerified(result)
            
            // Update entitlements based on transaction
            await updateEntitlements(for: transaction)
            
            // Always finish a transaction
            await transaction.finish()
            
            print("✅ Transaction processed: \(transaction.productID)")
            
        } catch {
            print("❌ Transaction verification failed: \(error)")
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
        
        // TODO: In production, sync with backend
        // await syncSubscriptionStatusWithBackend(status)
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
