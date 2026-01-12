//
//  HomeView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Section
                    welcomeSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Recent Activity
                    if !viewModel.recentConversations.isEmpty {
                        recentActivitySection
                    }
                    
                    // Subscription Banner
                    if subscriptionManager.subscriptionStatus == .free {
                        subscriptionBanner
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back!")
                .font(.title)
                .fontWeight(.bold)
            
            Text(authManager.currentUser?.displayName ?? "User")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                QuickActionCard(
                    icon: "message.fill",
                    title: "New Chat",
                    color: .blue
                )
                
                QuickActionCard(
                    icon: "clock.fill",
                    title: "History",
                    color: .purple
                )
                
                QuickActionCard(
                    icon: "star.fill",
                    title: "Favorites",
                    color: .orange
                )
                
                QuickActionCard(
                    icon: "gearshape.fill",
                    title: "Settings",
                    color: .gray
                )
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
            
            ForEach(viewModel.recentConversations.prefix(3)) { conversation in
                RecentConversationRow(conversation: conversation)
            }
        }
    }
    
    private var subscriptionBanner: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                Text("Upgrade to Premium")
                    .fontWeight(.semibold)
            }
            
            Text("Get unlimited messages and advanced features")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Learn More") {
                viewModel.showPaywall = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Quick Action Card

private struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Recent Conversation Row

private struct RecentConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(conversation.preview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(conversation.timestamp.formatted(.relative(presentation: .named)))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}
