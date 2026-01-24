//
//  OnboardingViewModel.swift
//  boilerplate
//
//  View models for onboarding flow
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI

// MARK: - Onboarding View Model

import AuthenticationServices

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var showTailor: Bool = false
    @Published var showTerms: Bool = false
    @Published var showPrivacy: Bool = false
    @Published var agreedToTerms: Bool = false
    @Published var error: Error?
    
    private let analyticsManager = AnalyticsManager()
    
    func signInAndContinue(authManager: AuthManager) async {
        guard agreedToTerms else { return }
        
        isLoading = true
        error = nil
        
        analyticsManager.logEvent(.signInStarted)
        
        do {
            try await authManager.signInAnonymously()
            
            analyticsManager.logEvent(.signInCompleted(method: "anonymous"))
            analyticsManager.logEvent(.onboardingCompleted)
            
            // Navigate to tailor view
            showTailor = true
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Apple Sign In
    
    func configureAppleSignIn(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    
    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>, authManager: AuthManager) async {
        guard agreedToTerms else { return }
        
        isLoading = true
        error = nil
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                do {
                    // Extract user info
                    let userID = appleIDCredential.user
                    let email = appleIDCredential.email
                    let fullName = appleIDCredential.fullName
                    
                    // TODO: Send to Firebase Auth
                    // For now, sign in anonymously and store Apple user data
                    try await authManager.signInAnonymously()
                    
                    analyticsManager.logEvent(.signInCompleted(method: "apple"))
                    analyticsManager.logEvent(.onboardingCompleted)
                    
                    print("✅ Apple Sign In successful")
                    print("User ID: \(userID)")
                    if let email = email {
                        print("Email: \(email)")
                    }
                    if let fullName = fullName {
                        print("Name: \(fullName.givenName ?? "") \(fullName.familyName ?? "")")
                    }
                    
                    // Navigate to tailor view
                    showTailor = true
                    
                } catch {
                    self.error = error
                }
            }
            
        case .failure(let error):
            self.error = error
        }
        
        isLoading = false
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle(authManager: AuthManager) async {
        guard agreedToTerms else { return }
        
        isLoading = true
        error = nil
        
        analyticsManager.logEvent(.signInStarted)
        
        do {
            try await authManager.signInWithGoogle()
            
            analyticsManager.logEvent(.signInCompleted(method: "google"))
            analyticsManager.logEvent(.onboardingCompleted)
            
            // Navigate to tailor view
            showTailor = true
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

// MARK: - Tailor View Model (Sports Team Selection)

@MainActor
class TailorViewModel: ObservableObject {
    @Published var selectedSport: SportType = .nba // Defaulting to NBA, UI selection hidden
    @Published var myTeam: SportsTeam?
    @Published var rivalTeams: [SportsTeam] = []
    @Published var selectedIntensity: RoastIntensity = .posterized
    @Published var showTeamPicker: Bool = false
    @Published var showRivalPicker: Bool = false
    
    private let storageManager = StorageManager()
    private let firebaseService = FirebaseService.shared
    
    // Popular teams to show as suggestions based on sport
    var suggestedTeams: [SportsTeam] {
        switch selectedSport {
        case .nba:
            return [
                NBAData.allTeams.first { $0.id == "LAL" }!,
                NBAData.allTeams.first { $0.id == "GSW" }!,
                NBAData.allTeams.first { $0.id == "CHI" }!
            ]
        case .nfl:
            return [
                NFLData.allTeams.first { $0.id == "KC" }!,
                NFLData.allTeams.first { $0.id == "DAL" }!,
                NFLData.allTeams.first { $0.id == "SF" }!
            ]
        }
    }
    
    var canContinue: Bool {
        myTeam != nil && !rivalTeams.isEmpty
    }
    
    func removeRival(_ team: SportsTeam) {
        rivalTeams.removeAll { $0.id == team.id }
    }
    
    func selectSport(_ sport: SportType) {
        guard selectedSport != sport else { return }
        selectedSport = sport
        // Reset selections when sport changes
        myTeam = nil
        rivalTeams = []
    }
    
    func savePreferences(userId: String? = nil) async {
        guard let myTeam = myTeam else { return }
        
        let preferences = UserSportsPreferences(
            selectedSport: selectedSport,
            myTeam: myTeam,
            rivalTeams: rivalTeams,
            intensity: selectedIntensity
        )
        
        // Save locally
        storageManager.saveUserSportsPreferences(preferences)
        
        // Save to Firebase if userId provided
        if let userId = userId {
            do {
                try await firebaseService.saveUserPreferences(preferences, userId: userId)
            } catch {
                print("❌ [Tailor] Failed to sync preferences to Firebase: \(error.localizedDescription)")
            }
        }
    }
    
    func loadPreferences(userId: String) async {
        do {
            if let cloudPrefs = try await firebaseService.loadUserPreferences(userId: userId) {
                self.selectedSport = cloudPrefs.selectedSport
                self.myTeam = cloudPrefs.myTeam
                self.rivalTeams = cloudPrefs.rivalTeams
                self.selectedIntensity = cloudPrefs.intensity
                
                // Also update local storage with cloud data
                storageManager.saveUserSportsPreferences(cloudPrefs)
            }
        } catch {
            print("❌ [Tailor] Failed to load preferences from Firebase: \(error.localizedDescription)")
        }
    }
}
