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
    @Published var currentRoast: String = "" // POSTERIZED level
    @Published var mediumRoast: String = "" // DUNKED ON level
    @Published var submittedInput: String = ""
    @Published var selectedIntensity: RoastIntensity = .posterized
    @Published var error: Error?
    @Published var userPreferences: UserSportsPreferences?
    
    // Media Input
    @Published var selectedImage: UIImage?
    @Published var selectedMedia: MediaAttachment?
    @Published var showPhotoPicker: Bool = false
    @Published var photoSelection: PhotosPickerItem? {
        didSet {
            if photoSelection != nil {
                Task { await handlePhotoSelection() }
            }
        }
    }
    
    @Published private(set) var isGenerating: Bool = false
    @Published private(set) var currentSession: RoastSession?
    
    // MARK: - Dependencies
    
    private let firebaseService = FirebaseService.shared
    private let storageManager = StorageManager()
    private let mediaManager = MediaManager()
    
    // MARK: - Initialization
    
    init() {
        loadUserPreferences()
    }
    
    // MARK: - Computed Properties
    
    var canGenerate: Bool {
        (!inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil) && !isGenerating
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
    
    // MARK: - Media Handling
    
    func handlePhotoSelection() async {
        guard let item = photoSelection else { return }
        
        do {
            let attachments = try await mediaManager.processPhotoPickerResults([item])
            if let attachment = attachments.first {
                await MainActor.run {
                    self.selectedMedia = attachment
                    if let data = attachment.thumbnailData {
                        self.selectedImage = UIImage(data: data)
                    }
                }
            }
        } catch {
            print("❌ Error processing photo selection: \(error)")
            self.error = error
        }
    }
    
    func clearMedia() {
        selectedImage = nil
        selectedMedia = nil
        photoSelection = nil
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
        
        // Prepare attachments
        var attachments: [MediaAttachment] = []
        if let media = selectedMedia {
            attachments.append(media)
        }
        
        // Generate POSTERIZED level (highest)
        let posterizedPrompt = buildRoastPrompt(for: inputForRoast, intensity: .posterized)
        
        do {
            // Generate posterized roast (non-streaming)
            let response = try await llmManager.sendPrompt(
                posterizedPrompt,
                context: [],
                attachments: attachments
            )
            self.currentRoast = response.content
            
            // Generate medium level roast
            await self.generateMediumRoast(
                using: llmManager,
                userId: userId,
                inputForRoast: inputForRoast,
                usageManager: usageManager,
                isFirstRoast: isFirstRoast,
                onFirstRoast: onFirstRoast,
                attachments: attachments
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
        onFirstRoast: (() -> Void)?,
        attachments: [MediaAttachment]
    ) async {
        let mediumPrompt = buildRoastPrompt(for: inputForRoast, intensity: .dunkedOn)
        
        do {
            // Generate medium roast (non-streaming for simplicity)
            let response = try await llmManager.sendPrompt(
                mediumPrompt,
                context: [],
                attachments: attachments
            )
            self.mediumRoast = response.content
            
            // Determine source type (OCR if image was present)
            let source: RoastSource = attachments.isEmpty ? .text : .ocr
            
            // Create session with both roast levels
            let session = RoastSession(
                userId: userId,
                inputText: inputForRoast,
                roastText: self.currentRoast,
                secondaryRoastText: self.mediumRoast,
                imageURL: attachments.first?.localURL?.absoluteString, // Save local URL for now
                ocrText: nil,
                source: source,
                intensity: self.selectedIntensity,
                sport: userPreferences?.selectedSport ?? .nba
            )
            
            self.currentSession = session
            
            // Save to Firebase
            await self.saveSession(session)
            
            self.isGenerating = false
            
            // Clear input after successful generation
            self.inputText = ""
            self.clearMedia()
            
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
        // We probably should persist the previous media here if we want to regenerate with image, 
        // but simple regeneration might just use text context. 
        // For now, let's assume regeneration clears currentRoast but uses stored text. 
        // If image was used, we'd need to keep `submittedMedia`. 
        // Skipping complex media regeneration logic for now to keep it simple.
        
        currentRoast = ""
        mediumRoast = ""
        await generateRoast(using: llmManager, userId: userId, usageManager: usageManager)
    }
    
    func clearOutput() {
        currentRoast = ""
        mediumRoast = ""
        submittedInput = ""
        inputText = ""
        clearMedia()
        currentSession = nil
    }
    
    func loadSession(_ session: RoastSession) {
        self.currentSession = session
        self.submittedInput = session.inputText
        self.currentRoast = session.roastText
        self.mediumRoast = session.secondaryRoastText ?? ""
        self.inputText = ""
        // TODO: Load image from session.imageURL if needed for display
        self.isGenerating = false
    }
    
    // MARK: - Prompt Building
    
    private func buildRoastPrompt(for text: String, intensity: RoastIntensity) -> String {
        let hasImageContext = selectedImage != nil ? "The user has provided an image to be roasted." : ""
        let textContext = text.isEmpty ? "Roast this image based on its visual content." : "\"\(text)\""
        
        return """
        You are a savage but clever NBA roast writer creating short, punchy basketball roasts meant for group chats and memes.

        Goal:
        Generate ONE high-impact NBA roast based on the user’s context. The roast should be funny, sharp, and immediately understandable to NBA fans.
        
        \(hasImageContext)

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
        clearMedia()
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
