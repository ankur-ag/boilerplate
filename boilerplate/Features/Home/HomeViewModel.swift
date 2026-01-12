//
//  HomeViewModel.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var recentConversations: [Conversation] = []
    @Published var isLoading: Bool = false
    @Published var showPaywall: Bool = false
    
    init() {
        // TODO: Load recent conversations from storage
        loadRecentConversations()
    }
    
    func refresh() async {
        isLoading = true
        
        // TODO: Fetch latest data from backend
        // TODO: Sync conversation history
        
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s
        
        loadRecentConversations()
        
        isLoading = false
    }
    
    private func loadRecentConversations() {
        // TODO: Load from persistent storage
        // Placeholder data
        recentConversations = []
    }
}

// MARK: - Conversation Model

struct Conversation: Identifiable {
    let id: String
    let title: String
    let preview: String
    let timestamp: Date
    let messages: [LLMMessage]
    
    init(
        id: String = UUID().uuidString,
        title: String,
        preview: String,
        timestamp: Date = Date(),
        messages: [LLMMessage] = []
    ) {
        self.id = id
        self.title = title
        self.preview = preview
        self.timestamp = timestamp
        self.messages = messages
    }
}
