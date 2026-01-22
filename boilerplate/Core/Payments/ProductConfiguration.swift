//
//  ProductConfiguration.swift
//  boilerplate
//
//  Posterized - StoreKit Product IDs Configuration
//  Created by Ankur on 1/12/26.
//

import Foundation

/// StoreKit product identifiers for Posterized subscriptions
enum ProductIdentifier {
    // MARK: - Auto-Renewable Subscriptions
    
    /// Weekly subscription - com.posterized.pro.weekly
    static let weekly = "com.posterized.pro.weekly"
    
    /// Monthly subscription - com.posterized.pro.monthly
    static let monthly = "com.posterized.pro.monthly"
    
    /// Annual subscription - com.posterized.pro.annual
    static let annual = "com.posterized.pro.annual"
    
    // MARK: - Non-Renewable (One-Time Purchase)
    
    /// Lifetime access - com.posterized.pro.lifetime
    static let lifetime = "com.posterized.pro.lifetime"
    
    // MARK: - All Products
    
    /// All product IDs for fetching from StoreKit
    static let allProducts: Set<String> = [
        weekly,
        monthly,
        annual,
        lifetime
    ]
    
    /// Auto-renewable subscription IDs only
    static let subscriptions: Set<String> = [
        weekly,
        monthly,
        annual
    ]
    
    /// One-time purchase IDs only
    static let nonConsumables: Set<String> = [
        lifetime
    ]
}

/// Product tier for determining access level
enum ProductTier {
    case weekly
    case monthly
    case annual
    case lifetime
    
    init?(productId: String) {
        switch productId {
        case ProductIdentifier.weekly:
            self = .weekly
        case ProductIdentifier.monthly:
            self = .monthly
        case ProductIdentifier.annual:
            self = .annual
        case ProductIdentifier.lifetime:
            self = .lifetime
        default:
            return nil
        }
    }
    
    var displayName: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .annual: return "Annual"
        case .lifetime: return "Lifetime"
        }
    }
    
    var isRecurring: Bool {
        switch self {
        case .weekly, .monthly, .annual:
            return true
        case .lifetime:
            return false
        }
    }
}
