//
//  PaywallView.swift
//  boilerplate
//
//  Posterized - Premium Subscription Paywall
//  Created by Ankur on 1/12/26.
//

import SwiftUI
import StoreKit
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PaywallViewModel()
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.analyticsManager) private var analyticsManager
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close Button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    .padding(.trailing, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Title
                        Text("Unlock Unlimited\nRoasts")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.primaryOrange)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.top, DesignSystem.Spacing.md)
                        
                        // Subtitle
                        Text("Join the roast family & never run out of\nheat.")
                            .font(.system(size: 16))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                        
                        // Rating Badge
                        HStack(spacing: 8) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.yellow)
                            }
                            
                            Text("4.8★ from 10M+ users")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(DesignSystem.Colors.backgroundCard)
                        .cornerRadius(20)
                        
                        // Features List
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                            FeatureRow(
                                icon: "checkmark.square.fill",
                                iconColor: DesignSystem.Colors.primaryOrange,
                                title: "Unlimited text & image roasts"
                            )
                            
                            FeatureRow(
                                icon: "flame.fill",
                                iconColor: DesignSystem.Colors.primaryOrange,
                                title: "Full BRUTAL mode & priority generation"
                            )
                            
                            FeatureRow(
                                icon: "sparkles",
                                iconColor: DesignSystem.Colors.primaryOrange,
                                title: "First access to new meme features"
                            )
                            
                            FeatureRow(
                                icon: "photo.fill",
                                iconColor: DesignSystem.Colors.primaryOrange,
                                title: "No watermarks on exports (v2)"
                            )
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        
                        // Subscription Plans
                        subscriptionPlansCarousel
                        
                        // Continue Button
                        Button(action: {
                            viewModel.purchase()
                        }) {
                            HStack {
                                if viewModel.isProcessing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("CONTINUE")
                                        .font(.system(size: 18, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(DesignSystem.Colors.primaryOrange)
                            .cornerRadius(DesignSystem.CornerRadius.lg)
                        }
                        .disabled(viewModel.isProcessing)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        
                        // Maybe Later Button
                        Button(action: { dismiss() }) {
                            Text("Maybe later")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        .padding(.bottom, DesignSystem.Spacing.sm)
                        
                        // No Commitment Badge
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("No commitment. Cancel anytime.")
                                .font(.system(size: 14))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        // Footer Links
                        HStack(spacing: 20) {
                            Button("Privacy Policy") {
                                viewModel.showPrivacy = true
                            }
                            
                            Button("Restore") {
                                viewModel.restorePurchases()
                            }
                            
                            Button("Terms") {
                                viewModel.showTerms = true
                            }
                        }
                        .font(.system(size: 13))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .padding(.bottom, DesignSystem.Spacing.xl)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showPrivacy) {
            PrivacyView()
        }
        .sheet(isPresented: $viewModel.showTerms) {
            TermsView()
        }
        .alert("Success", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Welcome to Premium! Enjoy unlimited roasts.")
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
        .task {
            viewModel.setSubscriptionManager(subscriptionManager)
            viewModel.setAnalyticsManager(analyticsManager)
            await viewModel.loadProducts()
        }
        .trackScreenView("Paywall")
        .onAppear {
            analyticsManager.logEvent(.paywallViewed)
        }
    }
    
    // MARK: - Subscription Plans Carousel
    
    private var subscriptionPlansCarousel: some View {
        Group {
            if viewModel.plans.isEmpty {
                // Empty state - no products loaded
                VStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(DesignSystem.Colors.accentYellow)
                    
                    Text("No Products Available")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("StoreKit products not loaded.\nCheck Xcode scheme settings.")
                        .font(.system(size: 14))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Reload") {
                        Task {
                            await viewModel.loadProducts()
                        }
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primaryOrange)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(DesignSystem.Colors.backgroundCard)
                    .cornerRadius(12)
                }
                .frame(height: 220)
                .padding()
            } else {
                TabView(selection: $viewModel.selectedPlanIndex) {
                    ForEach(Array(viewModel.plans.enumerated()), id: \.offset) { index, plan in
                        SubscriptionPlanCard(
                            plan: plan,
                            isSelected: viewModel.selectedPlanIndex == index
                        )
                        .tag(index)
                        .onTapGesture {
                            viewModel.selectedPlanIndex = index
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 220)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Subscription Plan Card

struct SubscriptionPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Discount Badge
            if let discount = plan.discount {
                Text("-\(discount)%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.green)
                    .cornerRadius(12)
            }
            
            // Plan Name
            Text(plan.name)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            // Price
            Text(plan.price)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            // Period
            Text(plan.period)
                .font(.system(size: 14))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            // Select Button
            Button(action: {}) {
                Text("Select")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : DesignSystem.Colors.accentCyan)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(isSelected ? DesignSystem.Colors.accentCyan : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(DesignSystem.Colors.accentCyan, lineWidth: 2)
                    )
                    .cornerRadius(DesignSystem.CornerRadius.lg)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: 280)
        .background(DesignSystem.Colors.backgroundCard)
        .cornerRadius(DesignSystem.CornerRadius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .stroke(isSelected ? DesignSystem.Colors.accentCyan : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Paywall View Model

@MainActor
class PaywallViewModel: ObservableObject {
    @Published var plans: [SubscriptionPlan] = []
    @Published var selectedPlanIndex: Int = 0
    @Published var isProcessing: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var showPrivacy: Bool = false
    @Published var showTerms: Bool = false
    @Published var error: Error?
    
    private var subscriptionManager: SubscriptionManager?
    private var analyticsManager: AnalyticsManager?
    private var packages: [Package] = []
    
    func setSubscriptionManager(_ manager: SubscriptionManager) {
        self.subscriptionManager = manager
    }
    
    func setAnalyticsManager(_ manager: AnalyticsManager) {
        self.analyticsManager = manager
    }
    
    func loadProducts() async {
        guard let manager = subscriptionManager else {
            print("⚠️ PaywallViewModel: SubscriptionManager not set")
            return
        }
        
        print("📦 PaywallViewModel: Loading products from RevenueCat...")
        
        // Load offerings through SubscriptionManager
        await manager.loadProducts()
        
        // Get available packages
        packages = manager.availablePackages
        print("📦 PaywallViewModel: Received \(packages.count) packages from SubscriptionManager")
        
        if packages.isEmpty {
            print("⚠️ PaywallViewModel: No packages available!")
            return
        }
        
        // Map RevenueCat packages to display plans
        plans = packages.compactMap { package in
            let product = package.storeProduct
            print("  📱 Mapping package: \(package.identifier) - \(product.localizedTitle) - \(product.localizedPriceString)")
            
            // Determine display info based on package type or product ID
            let period: String
            let discount: Int?
            var name = product.localizedTitle
            
            switch package.packageType {
            case .annual:
                period = "/ year"
                discount = 20
                name = "Annual"
            case .monthly:
                period = "/ month"
                discount = nil
                name = "Monthly"
            case .weekly:
                period = "/ week"
                discount = nil
                name = "Weekly"
            case .lifetime:
                period = "one-time"
                discount = nil
                name = "Lifetime"
            case .custom:
                period = ""
                discount = nil
            default:
                period = ""
                discount = nil
            }
            
            return SubscriptionPlan(
                id: package.identifier,
                name: name,
                price: product.localizedPriceString,
                period: period,
                discount: discount,
                package: package
            )
        }
        .sorted { plan1, plan2 in
            // Sort order: Annual, Monthly, Weekly, Lifetime
            let order: [PackageType] = [.annual, .monthly, .weekly, .lifetime]
            let type1 = plan1.package?.packageType ?? .unknown
            let type2 = plan2.package?.packageType ?? .unknown
            
            let index1 = order.firstIndex(of: type1) ?? 999
            let index2 = order.firstIndex(of: type2) ?? 999
            return index1 < index2
        }
        
        print("✅ Loaded \(plans.count) subscription plans for display")
    }
    
    func purchase() {
        guard !isProcessing else { return }
        guard selectedPlanIndex < plans.count else { return }
        guard let manager = subscriptionManager else {
            print("⚠️ SubscriptionManager not set")
            return
        }
        
        let selectedPlan = plans[selectedPlanIndex]
        
        // Get the package
        guard let package = selectedPlan.package else {
            print("❌ No package for plan: \(selectedPlan.name)")
            return
        }
        
        isProcessing = true
        
        // Log purchase start
        analyticsManager?.logEvent(.purchaseStarted(productId: package.storeProduct.productIdentifier))
        
        Task {
            do {
                // Attempt purchase through SubscriptionManager
                try await manager.purchase(package)
                
                // Log successful purchase
                analyticsManager?.logEvent(.purchaseCompleted(
                    productId: package.storeProduct.productIdentifier,
                    price: package.storeProduct.localizedPriceString
                ))
                
                // Show success
                showSuccessAlert = true
                print("✅ Purchase completed: \(package.storeProduct.localizedTitle)")
                
            } catch {
                // Log failed purchase
                analyticsManager?.logEvent(.purchaseFailed(error: error.localizedDescription))
                
                self.error = error
                print("❌ Purchase failed: \(error.localizedDescription)")
            }
            
            isProcessing = false
        }
    }
    
    func restorePurchases() {
        guard let manager = subscriptionManager else {
            print("⚠️ SubscriptionManager not set")
            return
        }
        
        isProcessing = true
        
        // Log restore attempt
        analyticsManager?.logEvent(.restorePurchases)
        
        Task {
            await manager.restorePurchases()
            
            // Check if restoration was successful
            if manager.subscriptionStatus != .free {
                showSuccessAlert = true
                print("✅ Purchases restored successfully")
            } else {
                print("ℹ️ No purchases to restore")
            }
            
            isProcessing = false
        }
    }
}

// MARK: - Subscription Plan Model

struct SubscriptionPlan: Identifiable {
    let id: String
    let name: String
    let price: String
    let period: String
    let discount: Int?
    let package: Package? // RevenueCat package for actual purchase
    
    init(id: String, name: String, price: String, period: String, discount: Int?, package: Package? = nil) {
        self.id = id
        self.name = name
        self.price = price
        self.period = period
        self.discount = discount
        self.package = package
    }
}

#Preview {
    PaywallView()
}
