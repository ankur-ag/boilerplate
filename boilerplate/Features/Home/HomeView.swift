//
//  HomeView.swift
//  boilerplate
//
//  Posterized - Text Roast Screen
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: HomeViewModel
    @EnvironmentObject private var llmManager: LLMManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var usageManager: UsageManager
    @FocusState private var isInputFocused: Bool
    @State private var showPaywall = false
    
    let initialSession: RoastSession?
    
    init(viewModel: HomeViewModel? = nil, session: RoastSession? = nil) {
        self.viewModel = viewModel ?? HomeViewModel()
        self.initialSession = session
    }
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerBar
                
                // Content
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        // Prompt Card
                        promptCard
                        
                        // User Input (if already generated)
                        if viewModel.hasOutput || viewModel.isGenerating {
                            userInputCard
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Roast Outputs (Top 2 levels only)
                        if viewModel.hasOutput || viewModel.isGenerating {
                            roastOutputsSection
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.top, DesignSystem.Spacing.sm)
                    .padding(.bottom, 180) // Space for bottom input + regenerate
                    .animation(.easeInOut(duration: 0.4), value: viewModel.hasOutput)
                }
                .onChange(of: viewModel.hasOutput) { newValue in
                    if newValue { isInputFocused = false }
                }
                .onAppear {
                    if let userId = authManager.currentUser?.id {
                        Task {
                            await viewModel.refreshPreferences(userId: userId)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Bottom Input Section (always visible)
            VStack {
                Spacer()
                bottomInputSection
            }
            
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isInputFocused = false
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let session = initialSession {
                viewModel.loadSession(session)
            }
        }
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack {
            // Back Button
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.body)
                    .foregroundColor(DesignSystem.Colors.accentCyan)
                    .frame(width: 32, height: 32)
            }
            
            Spacer()
            
            // Title
            Text("TEXT ROAST")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(DesignSystem.Colors.primaryOrange)
            
            Spacer()
            
            // Spacer for centering
            Color.clear
                .frame(width: 32)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .frame(height: 44)
    }
    
    // MARK: - Prompt Card
    
    private var promptCard: some View {
        Text("Whom do you want to clown about what?")
            .font(.system(size: 14))
            .foregroundColor(DesignSystem.Colors.textSecondary)
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignSystem.Colors.backgroundCard)
            .cornerRadius(DesignSystem.CornerRadius.md)
    }
    
    // MARK: - User Input Card
    
    private var userInputCard: some View {
        Text(viewModel.submittedInput)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color(hex: "FF4500"), Color(hex: "FF6B35")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
    }
    
    // MARK: - Roast Outputs Section (Top 2 levels only)
    
    private var roastOutputsSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Primary Roast (Generated Intensity - fixed after generation)
            if let primaryIntensity = viewModel.generatedPrimaryIntensity {
                roastOutputCard(
                    intensity: primaryIntensity,
                    text: viewModel.primaryRoastText,
                    borderColor: primaryIntensity == .posterized ? Color(hex: "FF4500") : 
                                 primaryIntensity == .dunkedOn ? DesignSystem.Colors.accentCyan :
                                 DesignSystem.Colors.primaryOrange
                )
            }
            
            // Secondary Roast (Generated Intensity - fixed after generation)
            if let secondaryIntensity = viewModel.generatedSecondaryIntensity {
                roastOutputCard(
                    intensity: secondaryIntensity,
                    text: viewModel.secondaryRoastText,
                    borderColor: secondaryIntensity == .posterized ? Color(hex: "FF4500") : 
                                 secondaryIntensity == .dunkedOn ? DesignSystem.Colors.accentCyan :
                                 DesignSystem.Colors.primaryOrange
                )
            }
        }
    }
    
    private func roastOutputCard(intensity: RoastIntensity, text: String, borderColor: Color) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Tags
            HStack(spacing: DesignSystem.Spacing.xs) {
                // Intensity Tag
                Text(intensity.rawValue)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(intensity.contentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(intensity.color)
                    .cornerRadius(3)
                
                Spacer()
                
                // Forward Button
                Button(action: {
                    viewModel.shareRoast(text)
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                        .foregroundColor(DesignSystem.Colors.accentCyan)
                }
            }
            
            // Roast Text
            if !text.isEmpty {
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineSpacing(3)
                    .padding(.top, DesignSystem.Spacing.xs)
            } else if viewModel.isGenerating {
                roastingLoadingView(intensity: intensity)
                    .padding(.top, DesignSystem.Spacing.xs)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 100)
        .background(DesignSystem.Colors.backgroundPrimary)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(borderColor, lineWidth: 2)
        )
        .cornerRadius(DesignSystem.CornerRadius.md)
    }
    
    private func roastingLoadingView(intensity: RoastIntensity) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Animated Roast Icon
            RoastLoadingIcon()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(intensity == .posterized ? "COOKING SAVAGE ROAST..." : "DUNKING ON 'EM...")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }
    
    // MARK: - Bottom Input Section
    
    private var bottomInputSection: some View {
        VStack(spacing: 0) {
            // Intensity Level Buttons
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach([RoastIntensity.trashTalk, .dunkedOn, .posterized], id: \.self) { intensity in
                    Button(action: {
                        viewModel.selectedIntensity = intensity
                    }) {
                        Text(intensity.rawValue)
                            .font(DesignSystem.Typography.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.selectedIntensity == intensity ? intensity.contentColor : DesignSystem.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(viewModel.selectedIntensity == intensity ? 
                                       (intensity == .posterized ? Color(hex: "FF4500") : 
                                        intensity == .dunkedOn ? Color(hex: "FF8C00") : 
                                        Color(hex: "FFCC00")) :
                                       DesignSystem.Colors.backgroundCard)
                            .cornerRadius(DesignSystem.CornerRadius.sm)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.md)
            
            // Input Row
            HStack(spacing: DesignSystem.Spacing.sm) {
                // Text Input
                ZStack(alignment: .leading) {
                    if viewModel.inputText.isEmpty && !isInputFocused {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("e.g. My Lakers friend talking trash after getting swept...")
                                .font(DesignSystem.Typography.footnote)
                                .foregroundColor(DesignSystem.Colors.textPlaceholder)
                                .lineLimit(1)
                            
                            if subscriptionManager.isPremium {
                                Text("PREMIUM: UNLIMITED")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.accentCyan)
                            } else {
                                let remaining = max(0, 1 - usageManager.textRoastCount)
                                Text("FREE: \(remaining) TEXT ROAST\(remaining == 1 ? "" : "S") LEFT")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.accentYellow)
                            }
                        }
                        .padding(.leading, DesignSystem.Spacing.sm)
                    }
                    
                    TextField("", text: $viewModel.inputText, axis: .vertical)
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .focused($isInputFocused)
                        .padding(DesignSystem.Spacing.sm)
                        .lineLimit(1...5) // Allow up to 5 lines before scrolling
                }
                .frame(minHeight: 44)
                .background(DesignSystem.Colors.backgroundCard)
                .cornerRadius(DesignSystem.CornerRadius.lg)
                
                // Send Button
                Button(action: {
                    isInputFocused = false
                    
                    // Check if user can generate roast
                    if !usageManager.canGenerateTextRoast(isPremium: subscriptionManager.isPremium) {
                        showPaywall = true
                        return
                    }
                    
                    guard let userId = authManager.currentUser?.id else { return }
                    Task {
                        await viewModel.generateRoast(
                            using: llmManager,
                            userId: userId,
                            usageManager: usageManager,
                            onFirstRoast: {
                                // Show paywall after first roast (5-7 seconds)
                                Task { @MainActor in
                                    try? await Task.sleep(nanoseconds: UInt64.random(in: 5_000_000_000...7_000_000_000))
                                    if !subscriptionManager.isPremium {
                                        showPaywall = true
                                    }
                                }
                            }
                        )
                    }
                }) {
                    Image(systemName: "arrow.right")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(DesignSystem.Colors.accentCyan)
                        .cornerRadius(DesignSystem.CornerRadius.lg)
                }
                .disabled(!viewModel.canGenerate)
                .opacity(viewModel.canGenerate ? 1.0 : 0.5)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            
            // Regenerate Button (always visible, disabled when no output)
            Button(action: {
                // Check if user can regenerate roast
                if !usageManager.canGenerateTextRoast(isPremium: subscriptionManager.isPremium) {
                    showPaywall = true
                    return
                }
                
                guard let userId = authManager.currentUser?.id else { return }
                Task {
                    await viewModel.regenerateRoast(using: llmManager, userId: userId, usageManager: usageManager)
                }
            }) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title3)
                    Text("REGENERATE")
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.bold)
                }
                .foregroundColor(viewModel.hasOutput ? DesignSystem.Colors.accentCyan : DesignSystem.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(viewModel.hasOutput ? DesignSystem.Colors.accentCyan.opacity(0.15) : DesignSystem.Colors.backgroundCard)
                .cornerRadius(DesignSystem.CornerRadius.md)
            }
            .disabled(!viewModel.hasOutput || viewModel.isGenerating)
            .opacity(viewModel.hasOutput ? 1.0 : 0.4)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .animation(.easeInOut(duration: 0.3), value: viewModel.hasOutput)
        }
        .background(DesignSystem.Colors.backgroundPrimary)
        .overlay(
            Rectangle()
                .fill(DesignSystem.Colors.border)
                .frame(height: 1),
            alignment: .top
        )
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Components

private struct RoastLoadingIcon: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(DesignSystem.Colors.primaryOrange.opacity(0.3), lineWidth: 2)
                .frame(width: 40, height: 40)
            
            Image(systemName: "flame.fill")
                .font(.system(size: 20))
                .foregroundColor(DesignSystem.Colors.primaryOrange)
                .scaleEffect(isAnimating ? 1.2 : 0.9)
                .opacity(isAnimating ? 1.0 : 0.7)
                .animation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(LLMManager())
        .environmentObject(AuthManager())
        .environmentObject(SubscriptionManager())
        .environmentObject(UsageManager())
}
