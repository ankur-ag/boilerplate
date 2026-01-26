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
    @Published var error: Error?
    
    private let storageManager = StorageManager()
    
    var groupedConversations: [String: [Conversation]] {
        Dictionary(grouping: conversations) { conversation in
            conversation.timestamp.formatted(.dateTime.year().month().day())
        }
    }
    
    // MARK: - Load Conversations
    
    func loadConversations(userId: String) async {
        // 1. Load from local cache immediately for instant UI
        let localData = loadLocalConversations()
        if !localData.isEmpty {
            self.conversations = localData
            print("📦 [History] Loaded \(localData.count) conversations from local cache")
        } else {
            isLoading = true
        }
        
        // 2. Background sync (placeholder for Firebase/API)
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 500_000_000)
            
            // In a real app, you'd fetch from your CloudService here:
            // let cloudData = try await CloudService.shared.loadConversations(userId: userId)
            // self.conversations = cloudData
            
            self.isLoading = false
            saveLocalConversations()
            
        } catch {
            self.isLoading = false
            self.error = error
            print("⚠️ [History] sync failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Actions
    
    func deleteConversation(_ conversation: Conversation) {
        conversations.removeAll { $0.id == conversation.id }
        saveLocalConversations()
        // TODO: Delete from cloud
    }
    
    func deleteAllConversations() {
        conversations.removeAll()
        saveLocalConversations()
        // TODO: Delete all from cloud
    }
    
    // MARK: - Persistence
    
    private func loadLocalConversations() -> [Conversation] {
        do {
            if let loaded = try storageManager.load([Conversation].self, forKey: StorageKeys.conversations) {
                return loaded.sorted { $0.timestamp > $1.timestamp }
            }
        } catch {
            print("❌ Failed to load local conversations: \(error)")
        }
        return []
    }
    
    private func saveLocalConversations() {
        do {
            try storageManager.save(conversations, forKey: StorageKeys.conversations)
        } catch {
            print("❌ Failed to save local conversations: \(error)")
        }
    }
}
