//
//  OnboardingViewModel.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "sparkles",
            title: "Welcome to AI Assistant",
            description: "Your intelligent companion powered by advanced AI"
        ),
        OnboardingPage(
            imageName: "message.fill",
            title: "Natural Conversations",
            description: "Chat naturally and get intelligent responses in real-time"
        ),
        OnboardingPage(
            imageName: "bolt.fill",
            title: "Fast & Reliable",
            description: "Get instant responses with our optimized infrastructure"
        )
    ]
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    func nextPage() {
        withAnimation {
            if currentPage < pages.count - 1 {
                currentPage += 1
            }
        }
    }
    
    func previousPage() {
        withAnimation {
            if currentPage > 0 {
                currentPage -= 1
            }
        }
    }
    
    func completeOnboarding(_ appConfigManager: AppConfigManager, authManager: AuthManager) {
        Task {
            // Sign in anonymously when getting started
            await authManager.signInAnonymously()
            appConfigManager.completeOnboarding()
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}
