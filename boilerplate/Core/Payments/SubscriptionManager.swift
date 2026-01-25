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

/// Manages in-app purchases and subscription state via RevenueCat
@MainActor
class SubscriptionManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var subscriptionStatus: SubscriptionStatus = .free
    @Published private(set) var entitlements: Set<Entitlement> = []
    @Published private(set) var availablePackages: [Package] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: SubscriptionError?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    /// Must be called AFTER Purchases.configure()
    func initialize() {
        Purchases.logLevel = .debug
        Purchases.shared.delegate = self
        Task {
            await checkSubscriptionStatus()
        }
    }
    
    // MARK: - Offering Loading
    
    func loadProducts() async {
        isLoading = true
        error = nil
        
        do {
            let offerings = try await Purchases.shared.offerings()
            if let currentOffering = offerings.current {
                self.availablePackages = currentOffering.availablePackages
            }
            await checkSubscriptionStatus()
        } catch {
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
                throw SubscriptionError.purchaseCancelled
            }
            await updateStatus(with: result.customerInfo)
        } catch {
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
        } catch {
            self.error = .restoreFailed(error.localizedDescription)
        }
        
        isLoading = false
    }
    
    // MARK: - Entitlement Checks
    
    func hasEntitlement(_ entitlement: Entitlement) -> Bool {
        return entitlements.contains(entitlement)
    }
    
    var isPremium: Bool {
        switch subscriptionStatus {
        case .subscribed: return true
        default: return false
        }
    }
    
    // MARK: - Private Methods
    
    private func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await updateStatus(with: customerInfo)
        } catch {
            print("❌ Failed to fetch customer info: \(error)")
        }
    }
    
    private func updateStatus(with customerInfo: CustomerInfo) async {
        // Log active entitlements for debugging
        let activeEntitlements = customerInfo.entitlements.active.keys
        print("👤 Customer Info updated. Active entitlements: \(activeEntitlements)")
        
        // Entitlement ID should match your RevenueCat dashboard (usually "premium")
        let entitlementID = "premium"
        
        if let entitlement = customerInfo.entitlements[entitlementID], entitlement.isActive {
            setPremiumStatus()
            print("✅ Premium entitlement is active")
        } else if !customerInfo.entitlements.active.isEmpty {
            // Fallback: If they have ANY active entitlement, they are likely premium
            setPremiumStatus()
            print("✅ User has active entitlements: \(activeEntitlements)")
        } else {
            subscriptionStatus = .free
            entitlements = [.basicFeatures]
            print("ℹ️ No active premium entitlement. Status: Free")
        }
    }
    
    private func setPremiumStatus() {
        subscriptionStatus = .subscribed(tier: .premium)
        // Example entitlements granted with premium
        entitlements = [.basicFeatures, .unlimitedAccess, .prioritySupport]
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
}

enum Entitlement: String, Hashable {
    case basicFeatures
    case unlimitedAccess
    case prioritySupport
}

// MARK: - Subscription Error

enum SubscriptionError: LocalizedError {
    case productLoadFailed(String)
    case purchaseFailed(String)
    case restoreFailed(String)
    case purchaseCancelled
    
    var errorDescription: String? {
        switch self {
        case .productLoadFailed(let message): return "Failed to load products: \(message)"
        case .purchaseFailed(let message): return "Purchase failed: \(message)"
        case .restoreFailed(let message): return "Restore failed: \(message)"
        case .purchaseCancelled: return "Purchase was cancelled"
        }
    }
}
