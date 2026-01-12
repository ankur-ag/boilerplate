//
//  HistoryViewModel.swift
//  boilerplate
//
//  RoastGPT Clone - History screen business logic
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var sessions: [RoastSession] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let firebaseService = FirebaseService.shared
    private let storageManager = StorageManager()
    
    var groupedSessions: [String: [RoastSession]] {
        Dictionary(grouping: sessions) { session in
            session.timestamp.formatted(.dateTime.year().month().day())
        }
    }
    
    // MARK: - Load Sessions
    
    func loadSessions(userId: String) async {
        isLoading = true
        
        do {
            // Try to load from Firebase first
            sessions = try await firebaseService.loadRoastSessions(userId: userId)
            
            // If empty, load from local storage as fallback
            if sessions.isEmpty {
                sessions = loadLocalSessions()
            }
            
        } catch {
            // Fallback to local storage on error
            sessions = loadLocalSessions()
            ErrorHandler.log(error, context: "Loading roast sessions")
        }
        
        isLoading = false
    }
    
    // MARK: - Delete Sessions
    
    func deleteSession(_ session: RoastSession) {
        sessions.removeAll { $0.id == session.id }
        
        Task {
            do {
                try await firebaseService.deleteRoastSession(session.id)
            } catch {
                ErrorHandler.log(error, context: "Deleting roast session")
            }
            
            saveLocalSessions()
        }
    }
    
    func deleteAllSessions() {
        sessions.removeAll()
        
        Task {
            // TODO: Delete all from Firebase
            saveLocalSessions()
        }
    }
    
    // MARK: - Local Storage
    
    private func loadLocalSessions() -> [RoastSession] {
        do {
            if let loaded = try storageManager.load([RoastSession].self, forKey: "roast_sessions") {
                return loaded.sorted { $0.timestamp > $1.timestamp }
            }
        } catch {
            ErrorHandler.log(error, context: "Loading local roast sessions")
        }
        
        return []
    }
    
    private func saveLocalSessions() {
        do {
            try storageManager.save(sessions, forKey: "roast_sessions")
        } catch {
            ErrorHandler.log(error, context: "Saving local roast sessions")
        }
    }
}
