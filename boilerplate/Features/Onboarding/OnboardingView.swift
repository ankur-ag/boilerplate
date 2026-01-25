//
//  OnboardingView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var appConfigManager: AppConfigManager
    
    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(viewModel.pages.indices, id: \.self) { index in
                OnboardingPageView(page: viewModel.pages[index])
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay(alignment: .bottom) {
            bottomButtons
                .padding()
        }
    }
    
    private var bottomButtons: some View {
        HStack {
            if viewModel.currentPage > 0 {
                Button("Back") {
                    viewModel.previousPage()
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            Button(viewModel.isLastPage ? "Get Started" : "Next") {
                if viewModel.isLastPage {
                    viewModel.completeOnboarding(appConfigManager, authManager: authManager)
                } else {
                    viewModel.nextPage()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Onboarding Page View

private struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: page.imageName)
                .font(.system(size: 100))
                .foregroundColor(.accentColor)
            
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}
