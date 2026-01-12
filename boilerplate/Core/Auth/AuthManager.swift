//
//  AuthManager.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI
import FirebaseAuth

/// Manages authentication state and operations
/// Supports anonymous auth by default, with extensibility for Apple Sign In, etc.
@MainActor
class AuthManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var currentUser: User?
    @Published private(set) var isInitializing: Bool = true
    @Published private(set) var error: AuthError?
    
    // MARK: - Initialization
    
    init() {
        // Set up Firebase Auth state listener
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            Task { @MainActor in
                if let firebaseUser = firebaseUser {
                    self?.handleAuthStateChanged(firebaseUser: firebaseUser)
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    func initialize() async {
        isInitializing = true
        
        // Check if user is already signed in
        if let firebaseUser = Auth.auth().currentUser {
            handleAuthStateChanged(firebaseUser: firebaseUser)
            print("✅ User already authenticated: \(firebaseUser.uid)")
        } else {
            // Auto sign in anonymously
            await signInAnonymously()
        }
        
        isInitializing = false
    }
    
    private func handleAuthStateChanged(firebaseUser: FirebaseAuth.User) {
        currentUser = User(
            id: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName ?? "Anonymous User",
            isAnonymous: firebaseUser.isAnonymous
        )
        isAuthenticated = true
        error = nil
    }
    
    // MARK: - Authentication Methods
    
    /// Sign in anonymously (default auth method)
    func signInAnonymously() async {
        do {
            let result = try await Auth.auth().signInAnonymously()
            print("✅ Anonymous sign-in successful: \(result.user.uid)")
            
            // Auth state listener will update currentUser
            
        } catch {
            print("❌ Anonymous sign-in failed: \(error.localizedDescription)")
            self.error = .signInFailed(error.localizedDescription)
        }
    }
    
    /// Sign in with Apple
    func signInWithApple() async {
        // TODO: Implement Apple Sign In
        // TODO: Exchange Apple credential for backend token
        // TODO: Link anonymous account if needed
        error = .notImplemented
    }
    
    /// Sign out current user
    func signOut() async {
        do {
            // TODO: Clear Firebase session
            // TODO: Clear local storage
            // TODO: Revoke backend tokens
            
            currentUser = nil
            isAuthenticated = false
            error = nil
            
        } catch {
            self.error = .signOutFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Account Management
    
    /// Upgrade anonymous account to permanent account
    func upgradeAnonymousAccount() async {
        // TODO: Implement account upgrade flow
        // TODO: Link anonymous account to Apple Sign In
        error = .notImplemented
    }
    
    /// Delete current user account
    func deleteAccount() async {
        // TODO: Implement account deletion
        // TODO: Delete all user data from backend
        // TODO: Remove local data
        error = .notImplemented
    }
}

// MARK: - User Model

struct User: Identifiable, Codable {
    let id: String
    let email: String?
    let displayName: String?
    let isAnonymous: Bool
    let createdAt: Date
    let lastSignInAt: Date
    
    init(
        id: String,
        email: String? = nil,
        displayName: String? = nil,
        isAnonymous: Bool = false,
        createdAt: Date = Date(),
        lastSignInAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.isAnonymous = isAnonymous
        self.createdAt = createdAt
        self.lastSignInAt = lastSignInAt
    }
}

// MARK: - Auth Error

enum AuthError: LocalizedError {
    case signInFailed(String)
    case signOutFailed(String)
    case notImplemented
    case invalidCredentials
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .signInFailed(let message):
            return "Sign in failed: \(message)"
        case .signOutFailed(let message):
            return "Sign out failed: \(message)"
        case .notImplemented:
            return "This feature is not yet implemented"
        case .invalidCredentials:
            return "Invalid credentials"
        case .networkError:
            return "Network error occurred"
        }
    }
}
