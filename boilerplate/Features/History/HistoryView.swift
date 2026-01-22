//
//  HistoryView.swift
//  boilerplate
//
//  Posterized - History of roast sessions matching Figma designs
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @EnvironmentObject private var authManager: AuthManager
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                DesignSystem.Colors.backgroundPrimary
                    .ignoresSafeArea()
                
                Group {
                    if viewModel.isLoading {
                        loadingView
                    } else if filteredSessions.isEmpty {
                        emptyState
                    } else {
                        sessionsList
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(DesignSystem.Colors.backgroundSecondary, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: {
                            viewModel.deleteAllSessions()
                        }) {
                            Label("Delete All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search posterizes...")
            .refreshable {
                await viewModel.loadSessions(userId: authManager.currentUser?.id ?? "anonymous")
            }
            .task {
                await viewModel.loadSessions(userId: authManager.currentUser?.id ?? "anonymous")
            }
        }
    }
    
    // MARK: - Filtered Sessions
    
    private var filteredSessions: [RoastSession] {
        if searchText.isEmpty {
            return viewModel.sessions
        } else {
            return viewModel.sessions.filter { session in
                session.inputText.localizedCaseInsensitiveContains(searchText) ||
                session.roastText.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(DesignSystem.Colors.primaryOrange)
            
            Text("Loading history...")
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.primaryOrange.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "clock.fill")
                    .font(.system(size: 50))
                    .foregroundColor(DesignSystem.Colors.primaryOrange)
            }
            
            Text(searchText.isEmpty ? "No Posterizes Yet" : "No Results")
                .font(DesignSystem.Typography.title2)
                .fontWeight(.bold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text(searchText.isEmpty ? "Drop your first take to see it here" : "Try a different search term")
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xxxl)
        }
        .padding()
    }
    
    // MARK: - Sessions List
    
    private var sessionsList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(groupedSessions.keys.sorted(by: >), id: \.self) { dateKey in
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        // Section Header
                        Text(dateKey)
                            .font(DesignSystem.Typography.caption1)
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.top, DesignSystem.Spacing.sm)
                        
                        // Sessions for this date
                        ForEach(groupedSessions[dateKey] ?? []) { session in
                            NavigationLink(destination: roastedView(for: session)) {
                                RoastSessionCard(session: session)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deleteSession(session)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
    
    private var groupedSessions: [String: [RoastSession]] {
        Dictionary(grouping: filteredSessions) { session in
            relativeDateString(for: session.timestamp)
        }
    }
    
    private func relativeDateString(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            return "This Week"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date)
        }
    }
    
    @ViewBuilder
    private func roastedView(for session: RoastSession) -> some View {
        if session.source == .image {
            ImageRoastView(session: session)
        } else {
            HomeView(session: session)
        }
    }
}

// MARK: - Roast Session Card

private struct RoastSessionCard: View {
    let session: RoastSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Header with timestamp
            HStack {
                Image(systemName: session.source == .image ? "photo" : "text.quote")
                    .font(.system(size: DesignSystem.IconSize.sm))
                    .foregroundColor(DesignSystem.Colors.primaryOrange)
                
                Spacer()
                
                Text(session.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            // Input preview
            Text(session.inputText)
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .lineLimit(2)
            
            // Roast preview (Deeper than text input)
            Text(session.roastText)
                .font(DesignSystem.Typography.footnote)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .lineLimit(2)
            
            // Source & Intensity Tags
            HStack(spacing: DesignSystem.Spacing.xs) {
                // Intensity Tag
                Text(session.intensity.rawValue)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(session.intensity.contentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(session.intensity.color)
                    .cornerRadius(2)
                
                // Sport Tag
                Image(systemName: session.sport.icon)
                    .font(.system(size: 8))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .padding(3)
                    .background(DesignSystem.Colors.backgroundTertiary)
                    .clipShape(Circle())
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: DesignSystem.IconSize.xs))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.backgroundCard)
        .cornerRadius(DesignSystem.CornerRadius.md)
        .designSystemShadow(DesignSystem.Shadow.card)
    }
}

// MARK: - Roast Detail View

struct RoastDetailView: View {
    let session: RoastSession
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Metadata
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        Text(session.timestamp.formatted(date: .long, time: .shortened))
                            .font(DesignSystem.Typography.caption1)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        // Intensity Tag
                        Text(session.intensity.rawValue)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(session.intensity.contentColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(session.intensity.color)
                            .cornerRadius(4)
                            .padding(.top, 4)
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                    
                    // Input
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        HStack {
                            Image(systemName: "quote.opening")
                                .font(.system(size: DesignSystem.IconSize.sm))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            
                            Text("Original Text")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                        
                        Text(session.inputText)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .padding(DesignSystem.Spacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(DesignSystem.Colors.backgroundCard)
                            .cornerRadius(DesignSystem.CornerRadius.md)
                    }
                    
                    // Roast Output
                    RoastCard(
                        title: "The Posterize",
                        text: session.roastText,
                        isStreaming: false,
                        onCopy: {
                            UIPasteboard.general.string = session.roastText
                        },
                        onShare: {
                            shareRoast(session.roastText)
                        }
                    )
                }
                .padding(DesignSystem.Spacing.lg)
            }
        }
            .navigationTitle("Posterize Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func shareRoast(_ text: String) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        rootVC.present(activityVC, animated: true)
    }
}

#Preview("History - Empty") {
    HistoryView()
        .environmentObject(AuthManager())
}

#Preview("Detail") {
    NavigationStack {
        RoastDetailView(
            session: RoastSession(
                userId: "test",
                inputText: "I'm the best developer in the world",
                roastText: "Oh really? The 'best developer' still uses print statements for debugging and thinks CSS stands for 'Can't Style Stuff'.",
                source: .text
            )
        )
    }
}
