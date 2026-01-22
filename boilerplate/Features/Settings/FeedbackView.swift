//
//  FeedbackView.swift
//  boilerplate
//
//  Feedback form matching Figma designs
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FeedbackViewModel()
    @FocusState private var isMessageFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Title with Icon
                        HStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(DesignSystem.Colors.primaryOrange)
                            
                            Text("Support & Feedback")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(DesignSystem.Colors.primaryOrange)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.top, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.sm)
                        
                        Text("Help us improve by sharing your thoughts")
                            .font(.system(size: 15))
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.bottom, DesignSystem.Spacing.xl)
                        
                        VStack(spacing: DesignSystem.Spacing.xl) {
                            // Category Selection
                            categorySection
                            
                            // Feedback Input
                            feedbackSection
                            
                            // Submit Button
                            submitButton
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.bottom, DesignSystem.Spacing.xxl)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isMessageFocused = false
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for your feedback! We'll review it soon.")
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
        }
    }
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Category")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            // Modern Tab Selector
            HStack(spacing: 0) {
                ForEach(FeedbackCategory.allCases, id: \.self) { category in
                    CategoryTab(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
            .background(DesignSystem.Colors.backgroundCard)
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(DesignSystem.Colors.textTertiary.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Feedback Section
    
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Message")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            ZStack(alignment: .topLeading) {
                if viewModel.feedbackText.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tell us what you think...")
                            .font(.system(size: 15))
                            .foregroundColor(DesignSystem.Colors.textPlaceholder)
                        
                        Text("Be as detailed as you'd like")
                            .font(.system(size: 13))
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }
                    .padding(.top, 12)
                    .padding(.leading, 16)
                }
                
                TextEditor(text: $viewModel.feedbackText)
                    .focused($isMessageFocused)
                    .font(.system(size: 15))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 160)
                    .padding(12)
            }
            .background(DesignSystem.Colors.backgroundCard)
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(
                        viewModel.feedbackText.isEmpty 
                            ? DesignSystem.Colors.textTertiary.opacity(0.1)
                            : DesignSystem.Colors.primaryOrange.opacity(0.3),
                        lineWidth: 1
                    )
            )
            
            // Character count
            HStack {
                Spacer()
                Text("\(viewModel.feedbackText.count) characters")
                    .font(.system(size: 13))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button(action: {
            Task {
                await viewModel.submitFeedback(userEmail: nil)
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if viewModel.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                    
                    Text("Sending...")
                        .font(.system(size: 17, weight: .semibold))
                } else {
                    Text("Submit Feedback")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if viewModel.canSubmit {
                        LinearGradient(
                            colors: [
                                DesignSystem.Colors.primaryOrange,
                                DesignSystem.Colors.primaryOrange.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        DesignSystem.Colors.textTertiary.opacity(0.3)
                    }
                }
            )
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .shadow(
                color: viewModel.canSubmit 
                    ? DesignSystem.Colors.primaryOrange.opacity(0.3)
                    : Color.clear,
                radius: 8,
                y: 4
            )
        }
        .disabled(!viewModel.canSubmit)
        .scaleEffect(viewModel.canSubmit ? 1.0 : 0.98)
        .animation(.spring(response: 0.3), value: viewModel.canSubmit)
        .padding(.top, DesignSystem.Spacing.md)
    }
}

// MARK: - Category Tab

private struct CategoryTab: View {
    let category: FeedbackCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Icon
                Image(systemName: category.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isSelected ? category.color : DesignSystem.Colors.textSecondary)
                
                // Label
                Text(category.shortTitle)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(category.color.opacity(0.1))
                            .padding(4)
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Feedback View Model

@MainActor
class FeedbackViewModel: ObservableObject {
    @Published var selectedCategory: FeedbackCategory = .general
    @Published var feedbackText: String = ""
    @Published var isSubmitting: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var error: Error?
    
    private let slackService = SlackService.shared
    
    var canSubmit: Bool {
        !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }
    
    func submitFeedback(userEmail: String? = nil) async {
        guard canSubmit else { return }
        
        isSubmitting = true
        error = nil
        
        do {
            try await slackService.sendFeedback(
                category: selectedCategory,
                message: feedbackText,
                userEmail: userEmail
            )
            
            // Success
            showSuccessAlert = true
            feedbackText = ""
            selectedCategory = .general
        } catch {
            self.error = error
        }
        
        isSubmitting = false
    }
    
    // Fallback: Open mail composer if Slack fails or for user preference
    func openMailComposer() {
        let subject = "Posterized Feedback: \(selectedCategory.shortTitle)"
        let body = """
        Category: \(selectedCategory.title)
        
        Message:
        \(feedbackText)
        
        --------------------------------
        Device: \(UIDevice.current.model)
        System: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
        """
        
        let recipient = "support@hyretalents.com"
        
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = recipient
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        
        if let url = components.url {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("❌ Cannot open mail client")
            }
        }
    }
}

// MARK: - Feedback Category

enum FeedbackCategory: String, CaseIterable {
    case bug = "bug"
    case feature = "feature"
    case general = "general"
    
    var title: String {
        switch self {
        case .bug:
            return "Report a Bug"
        case .feature:
            return "Request a Feature"
        case .general:
            return "General Feedback"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .bug:
            return "Bug"
        case .feature:
            return "Feature"
        case .general:
            return "General"
        }
    }
    
    var icon: String {
        switch self {
        case .bug:
            return "ladybug.fill"
        case .feature:
            return "lightbulb.fill"
        case .general:
            return "bubble.left.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bug:
            return DesignSystem.Colors.accentRed
        case .feature:
            return DesignSystem.Colors.accentYellow
        case .general:
            return DesignSystem.Colors.primaryOrange
        }
    }
}

#Preview {
    FeedbackView()
}
