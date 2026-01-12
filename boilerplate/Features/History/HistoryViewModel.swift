//
//  HistoryViewModel.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var isLoading: Bool = false
    
    var groupedConversations: [String: [Conversation]] {
        Dictionary(grouping: conversations) { conversation in
            conversation.timestamp.formatted(.dateTime.year().month().day())
        }
    }
    
    init() {
        loadConversations()
    }
    
    func refresh() async {
        isLoading = true
        
        // TODO: Sync with backend
        // TODO: Reload from local storage
        
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s
        
        loadConversations()
        
        isLoading = false
    }
    
    func deleteConversation(_ conversation: Conversation) {
        // TODO: Delete from storage
        conversations.removeAll { $0.id == conversation.id }
    }
    
    func deleteAllConversations() {
        // TODO: Delete all from storage
        conversations.removeAll()
    }
    
    private func loadConversations() {
        // TODO: Load from persistent storage
        // Placeholder
        conversations = []
    }
}
