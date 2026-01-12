//
//  PaywallView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var viewModel = PaywallViewModel()
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection
                    
                    // Features
                    featuresSection
                    
                    // Products
                    productsSection
                    
                    // CTA
                    ctaSection
                    
                    // Footer
                    footerSection
                }
                .padding()
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await subscriptionManager.loadProducts()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Unlock Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Get unlimited access to all features")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var featuresSection: some View {
        VStack(spacing: 16) {
            FeatureRow(icon: "infinity", title: "Unlimited Messages", description: "No daily limits")
            FeatureRow(icon: "bolt.fill", title: "Advanced AI Models", description: "Access to latest models")
            FeatureRow(icon: "star.fill", title: "Priority Support", description: "Get help faster")
            FeatureRow(icon: "arrow.down.circle.fill", title: "Offline Mode", description: "Save conversations")
        }
    }
    
    private var productsSection: some View {
        VStack(spacing: 12) {
            if subscriptionManager.isLoading {
                ProgressView()
                    .padding()
            } else {
                ForEach(subscriptionManager.availableProducts, id: \.id) { product in
                    ProductCard(product: product, isSelected: viewModel.selectedProduct?.id == product.id) {
                        viewModel.selectedProduct = product
                    }
                }
            }
        }
    }
    
    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                Task {
                    await viewModel.purchaseSelected(using: subscriptionManager)
                }
            }) {
                if viewModel.isPurchasing {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Text("Subscribe Now")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(viewModel.selectedProduct == nil || viewModel.isPurchasing)
            
            Button("Restore Purchases") {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            }
            .font(.subheadline)
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("Auto-renewable subscription. Cancel anytime.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Link("Terms", destination: URL(string: "https://example.com/terms")!)
                Text("•")
                Link("Privacy", destination: URL(string: "https://example.com/privacy")!)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Product Card

private struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                    
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
