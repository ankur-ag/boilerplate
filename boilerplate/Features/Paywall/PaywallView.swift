//
//  PaywallView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI
import RevenueCat

struct PaywallView: View {
    @StateObject private var viewModel = PaywallViewModel()
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Title
                        VStack(spacing: 8) {
                            Text("Upgrade to Premium")
                                .font(.system(size: 28, weight: .bold))
                                .multilineTextAlignment(.center)
                            
                            Text("Unlock all features and remove limits")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Features
                        VStack(alignment: .leading, spacing: 16) {
                            FeatureRow(icon: "checkmark.circle.fill", title: "Unlimited access to all features")
                            FeatureRow(icon: "checkmark.circle.fill", title: "Access to latest AI models")
                            FeatureRow(icon: "checkmark.circle.fill", title: "Priority response times")
                            FeatureRow(icon: "checkmark.circle.fill", title: "Exclusive premium themes")
                        }
                        .padding(.horizontal)
                        
                        // Products Carousel
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                if subscriptionManager.availablePackages.isEmpty {
                                    ForEach(0..<2) { _ in
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.secondary.opacity(0.1))
                                            .frame(width: 260, height: 150)
                                            .overlay(Text("Loading...").foregroundColor(.secondary))
                                    }
                                } else {
                                    ForEach(subscriptionManager.availablePackages, id: \.identifier) { package in
                                        BoilerplatePackageCard(
                                            package: package,
                                            isSelected: viewModel.selectedPackage?.identifier == package.identifier
                                        ) {
                                            viewModel.selectedPackage = package
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        
                        // CTA
                        VStack(spacing: 12) {
                            Button(action: {
                                Task {
                                    await viewModel.purchaseSelected(using: subscriptionManager)
                                }
                            }) {
                                if viewModel.isPurchasing {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("CONTINUE")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(12)
                            .disabled(viewModel.selectedPackage == nil || viewModel.isPurchasing)
                            
                            Button("Restore Purchases") {
                                Task { await subscriptionManager.restorePurchases() }
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        // Footer
                        HStack(spacing: 16) {
                            Link("Terms", destination: URL(string: "https://example.com/terms")!)
                            Link("Privacy", destination: URL(string: "https://example.com/privacy")!)
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .task {
            await subscriptionManager.loadProducts()
            if let first = subscriptionManager.availablePackages.first {
                viewModel.selectedPackage = first
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
            Text(title)
                .font(.subheadline)
            Spacer()
        }
    }
}

private struct BoilerplatePackageCard: View {
    let package: Package
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Spacer(minLength: 0)
                
                Text(package.storeProduct.localizedTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(package.storeProduct.localizedPriceString)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(package.packageType == .annual ? "/ year" : "/ month")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer(minLength: 0)
            }
            .padding()
            .frame(width: 260, height: 150)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .overlay(alignment: .topTrailing) {
                if package.packageType == .annual {
                    Text("SAVE 20%")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .offset(x: -8, y: 8)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
