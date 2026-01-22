//
//  HomeViewModel.swift
//  boilerplate
//
//  Posterized - Text-based roast generation logic
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI
import PhotosUI
import UIKit

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
    @Published var primaryRoastText: String = "" // Matches selectedIntensity
    @Published var secondaryRoastText: String = "" // Alternative intensity
    @Published var submittedInput: String = ""
    @Published var selectedIntensity: RoastIntensity = .posterized
    @Published var isGenerating: Bool = false
    @Published var error: Error?
    @Published var userPreferences: UserSportsPreferences?
    @Published private(set) var currentSession: RoastSession?
    
    // Captured intensities for display (fixed after generation)
    @Published var generatedPrimaryIntensity: RoastIntensity?
    @Published var generatedSecondaryIntensity: RoastIntensity?
    
    private let firebaseService = FirebaseService.shared
    private let storageManager = StorageManager()
    private var hasLoadedPreferences = false
    
    var hasOutput: Bool {
        !primaryRoastText.isEmpty
    }
    
    var secondaryIntensity: RoastIntensity {
        switch selectedIntensity {
        case .posterized: return .dunkedOn
        case .dunkedOn: return .posterized
        case .trashTalk: return .dunkedOn
        }
    }
    
    var canGenerate: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isGenerating
    }
    
    init() {
        self.userPreferences = storageManager.loadUserSportsPreferences()
    }
    
    func refreshPreferences(userId: String) async {
        // Only refresh once to avoid overwriting user's current selection
        guard !hasLoadedPreferences else { return }
        hasLoadedPreferences = true
        
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
            print("❌ [TextRoast] Failed to refresh preferences from Firebase: \(error.localizedDescription)")
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
        
        // Track if this is first roast
        let isFirstRoast: Bool = usageManager?.textRoastCount == 0
        
        isGenerating = true
        primaryRoastText = ""
        secondaryRoastText = ""
        error = nil
        
        let inputForRoast = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        submittedInput = inputForRoast
        
        // Capture intensities for display
        self.generatedPrimaryIntensity = selectedIntensity
        self.generatedSecondaryIntensity = secondaryIntensity
        
        // Clear inputs immediately
        inputText = ""
        
        // Generate PRIMARY roast (Selected Intensity)
        let primaryPrompt = buildRoastPrompt(for: inputForRoast, intensity: selectedIntensity)
        
        do {
            // Generate primary roast (non-streaming)
            let response = try await llmManager.sendPrompt(
                primaryPrompt,
                context: [],
                attachments: []
            )
            self.primaryRoastText = response.content
            
            // Generate SECONDARY roast (Alternative)
            await self.generateSecondaryRoast(
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
    
    private func generateSecondaryRoast(
        using llmManager: LLMManager,
        userId: String,
        inputForRoast: String,
        usageManager: UsageManager?,
        isFirstRoast: Bool,
        onFirstRoast: (() -> Void)?
    ) async {
        let secondaryPrompt = buildRoastPrompt(for: inputForRoast, intensity: secondaryIntensity)
        
        do {
            // Generate secondary roast
            let response = try await llmManager.sendPrompt(
                secondaryPrompt,
                context: [],
                attachments: []
            )
            self.secondaryRoastText = response.content
            
            // Create session
            let session = RoastSession(
                userId: userId,
                inputText: inputForRoast,
                roastText: self.primaryRoastText,
                secondaryRoastText: self.secondaryRoastText,
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
        primaryRoastText = ""
        secondaryRoastText = ""
        await generateRoast(using: llmManager, userId: userId, usageManager: usageManager)
    }
    
    func clearOutput() {
        primaryRoastText = ""
        secondaryRoastText = ""
        submittedInput = ""
        inputText = ""
        currentSession = nil
        error = nil
        generatedPrimaryIntensity = nil
        generatedSecondaryIntensity = nil
    }
    
    func loadSession(_ session: RoastSession) {
        self.currentSession = session
        self.submittedInput = session.inputText
        self.primaryRoastText = session.roastText
        self.secondaryRoastText = session.secondaryRoastText ?? ""
        self.inputText = ""
        self.isGenerating = false
        
        // Restore generated intensities from session
        self.generatedPrimaryIntensity = session.intensity
        // Determine what the secondary intensity would have been
        switch session.intensity {
        case .posterized: self.generatedSecondaryIntensity = .dunkedOn
        case .dunkedOn: self.generatedSecondaryIntensity = .posterized
        case .trashTalk: self.generatedSecondaryIntensity = .dunkedOn
        }
    }
    
    // MARK: - Prompt Building
    
    private func buildRoastPrompt(for text: String, intensity: RoastIntensity) -> String {
        let textContext = text.isEmpty ? "Roast this generic situation." : "\"\(text)\""
        
        return """
        You are a savage but clever NBA roast writer creating short, punchy basketball roasts meant for group chats and memes.

        Goal:
        Generate ONE high-impact NBA roast based on the user’s context. The roast should be funny, sharp, and immediately understandable to NBA fans.
        
        Tone & style:
        - Witty, confident, and ruthless but playful
        - Reads like something that would get screenshotted in a group chat
        - No long explanations, no essays
        - Modern NBA fan humor (Twitter / Reddit / locker-room banter style)

        Roast intensity is controlled by {intensity}:
        - trash talk (mild): playful teasing, light embarrassment
        - dunk on (medium): obvious humiliation, sharper insults
        - posterized (severe, default): maximum roast, ruthless but clever

        Rules:
        - If real NBA players or teams are mentioned, roast them directly and clearly (no vague references).
        - Avoid self-harm, suicide, or mocking disabilities or medical conditions.
        - Roast allowed topics include: choking, clutch failures, “washed” debates, ring debates, ego, media hype, fanbase delusion, ref favoritism, fake toughness, load management jokes, etc.
        - Keep it sharp, not hateful.

        Input:
        - Context: \(textContext)
        - Intensity: \(intensity.rawValue.replacingOccurrences(of: "_", with: " "))

        Output requirements:
        - Output a SINGLE roast.
        - 1–2 lines max.
        - No emojis unless they genuinely add punch.
        - No disclaimers, no explanations, no alternatives.
        - The roast should stand alone as a meme caption.
        """
    }
    
    // MARK: - Actions
    
    func copyRoast() {
        UIPasteboard.general.string = primaryRoastText
    }
    
    func shareRoast(_ text: String? = nil) {
        let textToShare = text ?? primaryRoastText
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
