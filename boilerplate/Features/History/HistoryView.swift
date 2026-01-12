//
//  HistoryView.swift
//  boilerplate
//
//  RoastGPT Clone - History of roast sessions
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.sessions.isEmpty {
                    emptyState
                } else {
                    sessionsList
                }
            }
            .navigationTitle("History")
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
                    }
                }
            }
            .refreshable {
                await viewModel.loadSessions(userId: authManager.currentUser?.id ?? "anonymous")
            }
            .task {
                await viewModel.loadSessions(userId: authManager.currentUser?.id ?? "anonymous")
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading history...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "flame.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Roasts Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Generate your first roast to see it here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    // MARK: - Sessions List
    
    private var sessionsList: some View {
        List {
            ForEach(viewModel.groupedSessions.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(date)) {
                    ForEach(viewModel.groupedSessions[date] ?? []) { session in
                        NavigationLink(destination: RoastDetailView(session: session)) {
                            RoastSessionRow(session: session)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
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
    }
}

// MARK: - Roast Session Row

private struct RoastSessionRow: View {
    let session: RoastSession
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon or Image Thumbnail
            if session.hasImage {
                // TODO: Load actual image thumbnail
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Image(systemName: "text.quote")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .frame(width: 50, height: 50)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Input Preview
                Text(session.inputText.prefix(50) + (session.inputText.count > 50 ? "..." : ""))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                // Roast Preview
                Text(session.preview + (session.roastText.count > 100 ? "..." : ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Timestamp
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(session.timestamp.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Roast Detail View

struct RoastDetailView: View {
    let session: RoastSession
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Original Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Original Text")
                        .font(.headline)
                    
                    Text(session.inputText)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
                
                // OCR Text (if available)
                if let ocrText = session.ocrText {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Extracted from Image")
                            .font(.headline)
                        
                        Text(ocrText)
                            .font(.caption)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(12)
                    }
                }
                
                // Roast
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("🔥 The Roast")
                            .font(.headline)
                        
                        Spacer()
                        
                        if session.regenerationCount > 0 {
                            Text("Regenerated \(session.regenerationCount)x")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(session.roastText)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Actions
                HStack(spacing: 16) {
                    Button(action: {
                        UIPasteboard.general.string = session.roastText
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        shareRoast(session.roastText)
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                // Metadata
                VStack(alignment: .leading, spacing: 8) {
                    Text("Details")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Created:")
                        Spacer()
                        Text(session.timestamp.formatted(date: .long, time: .shortened))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    if session.hasImage {
                        HStack {
                            Text("Source:")
                            Spacer()
                            Text("Image Upload")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Roast Details")
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

#Preview {
    HistoryView()
        .environmentObject(AuthManager())
}
