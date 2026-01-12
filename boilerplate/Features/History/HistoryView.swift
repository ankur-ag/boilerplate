//
//  HistoryView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.conversations.isEmpty {
                    emptyState
                } else {
                    conversationsList
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: viewModel.deleteAllConversations) {
                            Label("Delete All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Conversations Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your chat history will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var conversationsList: some View {
        List {
            ForEach(viewModel.groupedConversations.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(date)) {
                    ForEach(viewModel.groupedConversations[date] ?? []) { conversation in
                        ConversationRow(conversation: conversation)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteConversation(conversation)
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

// MARK: - Conversation Row

private struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(conversation.title)
                .font(.headline)
            
            Text(conversation.preview)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(conversation.timestamp.formatted(.dateTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(conversation.messages.count) messages")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
