//
//  HomeViewModel.swift
//  boilerplate
//
//  Posterized - Text-based roast generation logic
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI

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

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var inputText: String = ""
    @Published var currentRoast: String = "" // POSTERIZED level
    @Published var mediumRoast: String = "" // DUNKED ON level
    @Published var submittedInput: String = ""
    @Published var selectedIntensity: RoastIntensity = .posterized
    @Published var error: Error?
    @Published var userPreferences: UserSportsPreferences?
    
    @Published private(set) var isGenerating: Bool = false
    @Published private(set) var currentSession: RoastSession?
    
    // MARK: - Dependencies
    
    private let firebaseService = FirebaseService.shared
    private let storageManager = StorageManager()
    
    // MARK: - Initialization
    
    init() {
        loadUserPreferences()
    }
    
    // MARK: - Computed Properties
    
    var canGenerate: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating
    }
    
    var hasOutput: Bool {
        !currentRoast.isEmpty
    }
    
    var isProcessing: Bool {
        isGenerating
    }
    
    // MARK: - User Preferences
    
    func loadUserPreferences() {
        if let prefs = try? storageManager.load(UserSportsPreferences.self, forKey: "sports_preferences") {
            userPreferences = prefs
        }
    }
    
    func refreshPreferences(userId: String) async {
        do {
            if let cloudPrefs = try await firebaseService.loadUserPreferences(userId: userId) {
                await MainActor.run {
                    self.userPreferences = cloudPrefs
                    self.selectedIntensity = cloudPrefs.intensity
                }
                // Save locally too
                storageManager.saveUserSportsPreferences(cloudPrefs)
            }
        } catch {
            print("❌ [Home] Failed to refresh preferences from Firebase: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Roast Generation
    
    func generateRoast(
        using llmManager: LLMManager,
        userId: String,
        usageManager: UsageManager? = nil,
        onFirstRoast: (() -> Void)? = nil
    ) async {
        guard canGenerate else { return }
        
        print("🎯 generateRoast called")
        print("🎯 llmManager isConfigured: \(llmManager.isConfigured)")
        
        // Track if this is first roast
        let isFirstRoast = usageManager?.textRoastCount == 0
        
        isGenerating = true
        currentRoast = ""
        mediumRoast = ""
        error = nil
        
        let inputForRoast = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        submittedInput = inputForRoast
        
        // Generate POSTERIZED level (highest)
        let posterizedPrompt = buildRoastPrompt(for: inputForRoast, intensity: .posterized)
        
        do {
            // Generate posterized roast (non-streaming)
            let response = try await llmManager.sendPrompt(posterizedPrompt, context: [])
            self.currentRoast = response.content
            
            // Generate medium level roast
            await self.generateMediumRoast(
                using: llmManager,
                userId: userId,
                inputForRoast: inputForRoast,
                usageManager: usageManager,
                isFirstRoast: isFirstRoast,
                onFirstRoast: onFirstRoast
            )
        } catch {
            self.error = error
            isGenerating = false
        }
    }
    
    private func generateMediumRoast(
        using llmManager: LLMManager,
        userId: String,
        inputForRoast: String,
        usageManager: UsageManager?,
        isFirstRoast: Bool,
        onFirstRoast: (() -> Void)?
    ) async {
        let mediumPrompt = buildRoastPrompt(for: inputForRoast, intensity: .dunkedOn)
        
        do {
            // Generate medium roast (non-streaming for simplicity)
            let response = try await llmManager.sendPrompt(mediumPrompt, context: [])
            self.mediumRoast = response.content
            
            // Create session with both roast levels
            let session = RoastSession(
                userId: userId,
                inputText: inputForRoast,
                roastText: self.currentRoast,
                secondaryRoastText: self.mediumRoast,
                imageURL: nil,
                ocrText: nil,
                source: .text,
                intensity: self.selectedIntensity,
                sport: userPreferences?.selectedSport ?? .nba
            )
            
            self.currentSession = session
            
            // Save to Firebase
            await self.saveSession(session)
            
            self.isGenerating = false
            
            // Clear input after successful generation
            self.inputText = ""
            
            // Increment usage count
            usageManager?.incrementTextRoastCount()
            
            // Trigger first roast callback
            if isFirstRoast {
                onFirstRoast?()
            }
            
        } catch {
            self.error = error
            self.isGenerating = false
        }
    }
    
    func regenerateRoast(using llmManager: LLMManager, userId: String, usageManager: UsageManager? = nil) async {
        // Use the submitted input to regenerate
        inputText = submittedInput
        currentRoast = ""
        mediumRoast = ""
        await generateRoast(using: llmManager, userId: userId, usageManager: usageManager)
    }
    
    func clearOutput() {
        currentRoast = ""
        mediumRoast = ""
        submittedInput = ""
        inputText = ""
        currentSession = nil
    }
    
    func loadSession(_ session: RoastSession) {
        self.currentSession = session
        self.submittedInput = session.inputText
        self.currentRoast = session.roastText
        self.mediumRoast = session.secondaryRoastText ?? ""
        self.inputText = ""
        self.isGenerating = false
    }
    
    // MARK: - Prompt Building
    
    private func buildRoastPrompt(for text: String, intensity: RoastIntensity) -> String {
        // Load user sports preferences
        var sportsContext = ""
        var selectedSport: SportType = .nba
        
        if let savedPrefs = try? storageManager.load(UserSportsPreferences.self, forKey: "sports_preferences") {
            selectedSport = savedPrefs.selectedSport
            let myTeam = savedPrefs.myTeam.fullName
            let rivals = savedPrefs.rivalTeams.map { $0.fullName }.joined(separator: ", ")
            
            sportsContext = """
            Context: The user is a \(myTeam) fan. Their rivals are: \(rivals).
            """
        }
        
        let intensityInstruction: String
        switch intensity {
        case .trashTalk:
            intensityInstruction = "Keep it light and playful. Use gentle ribbing and friendly banter."
        case .dunkedOn:
            intensityInstruction = "Deliver a solid roast with clever wordplay. Medium heat, entertaining burns."
        case .posterized:
            intensityInstruction = "Go absolutely savage. Maximum brutality. Destroy them with no mercy. Pull out all the stops."
        }
        
        let sportSpecificInstruction = selectedSport == .nba ? 
            "Use NBA references, player comparisons, championship droughts, playoff failures, and rivalry history. Be creative with basketball metaphors and terminology." :
            "Use NFL references, player stats, Super Bowl droughts, draft bust history, and team failures. Use football metaphors like fumbles, interceptions, and goal-line stands."
        
        return """
        You are Posterized AI, a sports roasting expert specializing in \(selectedSport.rawValue) trash talk. Your job is to deliver clever, savage, and hilarious sports roasts.
        
        \(sportsContext)
        
        Intensity level: \(intensity.rawValue)
        \(intensityInstruction)
        
        \(sportSpecificInstruction)
        
        Here's the text to roast:
        
        "\(text)"
        
        Now deliver a \(selectedSport.rawValue)-themed roast (2-4 sentences):
        """
    }
    
    // MARK: - Actions
    
    func copyRoast() {
        UIPasteboard.general.string = currentRoast
        // TODO: Show success toast/feedback
    }
    
    func shareRoast(_ text: String? = nil) {
        let textToShare = text ?? currentRoast
        guard !textToShare.isEmpty else { return }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        // For iPad
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        rootVC.present(activityVC, animated: true)
    }
    
    func clearInput() {
        inputText = ""
    }
    
    // MARK: - Data Persistence
    
    private func saveSession(_ session: RoastSession) async {
        do {
            try await firebaseService.saveRoastSession(session)
        } catch {
            // Log error but don't show to user
            ErrorHandler.log(error, context: "Saving roast session")
        }
    }
    
    // MARK: - Error Handling
    
    func clearError() {
        error = nil
    }
}
