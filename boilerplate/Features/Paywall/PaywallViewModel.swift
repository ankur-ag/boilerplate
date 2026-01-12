//
//  PaywallViewModel.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import StoreKit

@MainActor
class PaywallViewModel: ObservableObject {
    @Published var selectedProduct: Product?
    @Published var isPurchasing: Bool = false
    @Published var error: PaywallError?
    
    func purchaseSelected(using subscriptionManager: SubscriptionManager) async {
        guard let product = selectedProduct else { return }
        
        isPurchasing = true
        error = nil
        
        do {
            try await subscriptionManager.purchase(product)
            // TODO: Dismiss paywall on success
            
        } catch {
            self.error = .purchaseFailed(error.localizedDescription)
        }
        
        isPurchasing = false
    }
}

// MARK: - Paywall Error

enum PaywallError: LocalizedError {
    case purchaseFailed(String)
    case noProductSelected
    
    var errorDescription: String? {
        switch self {
        case .purchaseFailed(let message):
            return "Purchase failed: \(message)"
        case .noProductSelected:
            return "Please select a subscription plan"
        }
    }
}
