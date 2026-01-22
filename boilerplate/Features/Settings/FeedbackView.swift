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
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Title
                        Text("Support & Feedback")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.primaryOrange)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.top, DesignSystem.Spacing.lg)
                            .padding(.bottom, DesignSystem.Spacing.md)
                        
                        Text("Get help or request features")
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
            
            // Category Pills
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(FeedbackCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
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
                    Text("Tell us what you think...")
                        .font(.system(size: 15))
                        .foregroundColor(DesignSystem.Colors.textPlaceholder)
                        .padding(.top, 12)
                        .padding(.leading, 16)
                }
                
                TextEditor(text: $viewModel.feedbackText)
                    .font(.system(size: 15))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 160)
                    .padding(12)
            }
            .background(DesignSystem.Colors.backgroundCard)
            .cornerRadius(DesignSystem.CornerRadius.lg)
            
            // Character count
            Text("\(viewModel.feedbackText.count) characters")
                .font(.system(size: 13))
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button(action: {
            Task {
                await viewModel.submitFeedback()
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if viewModel.isSubmitting {
                    ProgressView()
                        .tint(.white)
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
            .background(viewModel.canSubmit ? DesignSystem.Colors.primaryOrange : DesignSystem.Colors.textSecondary)
            .cornerRadius(DesignSystem.CornerRadius.lg)
        }
        .disabled(!viewModel.canSubmit)
        .padding(.top, DesignSystem.Spacing.md)
    }
}

// MARK: - Category Pill

private struct CategoryPill: View {
    let category: FeedbackCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.shortTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : DesignSystem.Colors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? DesignSystem.Colors.primaryOrange : DesignSystem.Colors.backgroundCard)
                .cornerRadius(20)
        }
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
    
    var canSubmit: Bool {
        !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }
    
    func submitFeedback() async {
        guard canSubmit else { return }
        
        isSubmitting = true
        error = nil
        
        // Simulate API call
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s
            
            // TODO: Implement actual feedback submission to backend
            // await firebaseService.submitFeedback(category: selectedCategory, text: feedbackText)
            
            showSuccessAlert = true
            
        } catch {
            self.error = error
        }
        
        isSubmitting = false
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
