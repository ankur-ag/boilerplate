//
//  AuthManager.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignIn

/// Manages authentication state and operations
/// Supports anonymous auth by default, with extensibility for Apple and Google Sign In.
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
        } else {
            // Auto sign in anonymously if no session exists
            await signInAnonymously()
        }
        
        isInitializing = false
    }
    
    private func handleAuthStateChanged(firebaseUser: FirebaseAuth.User) {
        currentUser = User(
            id: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName ?? "User",
            isAnonymous: firebaseUser.isAnonymous
        )
        isAuthenticated = true
        error = nil
    }
    
    // MARK: - Authentication Methods
    
    /// Sign in anonymously
    func signInAnonymously() async {
        do {
            _ = try await Auth.auth().signInAnonymously()
        } catch {
            self.error = .signInFailed(error.localizedDescription)
        }
    }
    
    /// Sign in with Google
    func signInWithGoogle() async throws {
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.signInFailed("Could not find root view controller")
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = result.user
            
            guard let idToken = user.idToken?.tokenString else {
                throw AuthError.signInFailed("Google ID Token missing")
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            _ = try await Auth.auth().signIn(with: credential)
            
        } catch {
            self.error = .signInFailed(error.localizedDescription)
            throw error
        }
    }
    
    /// Sign in with Apple (Placeholder for implementation)
    func signInWithApple() async {
        // Implementation typically involves ASAuthorizationAppleIDButton and delegate
        error = .notImplemented
    }
    
    /// Sign out current user
    func signOut() async {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            self.error = .signOutFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Account Management
    
    func deleteAccount() async {
        do {
            try await Auth.auth().currentUser?.delete()
            signOutTab()
        } catch {
            self.error = .signOutFailed(error.localizedDescription)
        }
    }
    
    private func signOutTab() {
        currentUser = nil
        isAuthenticated = false
    }
}

// MARK: - User Model

struct User: Identifiable, Codable {
    let id: String
    let email: String?
    let displayName: String?
    let isAnonymous: Bool
    
    init(
        id: String,
        email: String? = nil,
        displayName: String? = nil,
        isAnonymous: Bool = false
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.isAnonymous = isAnonymous
    }
}

// MARK: - Auth Error

enum AuthError: LocalizedError {
    case signInFailed(String)
    case signOutFailed(String)
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .signInFailed(let message): return "Sign in failed: \(message)"
        case .signOutFailed(let message): return "Sign out failed: \(message)"
        case .notImplemented: return "This feature is not yet implemented"
        }
    }
}
