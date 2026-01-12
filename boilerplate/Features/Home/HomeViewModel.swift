//
//  HomeViewModel.swift
//  boilerplate
//
//  RoastGPT Clone - Home screen business logic
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI
import PhotosUI

// MARK: - Conversation Model (for backward compatibility with PromptViewModel)

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
    @Published var uploadedImage: UIImage?
    @Published var extractedText: String?
    @Published var currentRoast: String = ""
    @Published var showImagePicker: Bool = false
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var error: Error?
    
    @Published private(set) var isExtractingText: Bool = false
    @Published private(set) var isGenerating: Bool = false
    @Published private(set) var currentSession: RoastSession?
    
    // MARK: - Dependencies
    
    private let ocrManager = OCRManager()
    private let firebaseService = FirebaseService.shared
    
    // MARK: - Computed Properties
    
    var canGenerate: Bool {
        (!inputText.isEmpty || extractedText != nil) && !isProcessing
    }
    
    var isProcessing: Bool {
        isExtractingText || isGenerating
    }
    
    var hasOutput: Bool {
        !currentRoast.isEmpty
    }
    
    private var effectiveInputText: String {
        if let extracted = extractedText, !extracted.isEmpty {
            return extracted
        }
        return inputText
    }
    
    // MARK: - Image Processing
    
    func processSelectedPhoto() async {
        guard let photo = selectedPhoto else {
            return
        }
        
        // Clear selectedPhoto immediately to avoid re-triggering onChange
        // Store reference before clearing
        let photoToProcess = photo
        selectedPhoto = nil
        
        do {
            // Load image data
            guard let data = try await photoToProcess.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                return
            }
            
            uploadedImage = image
            
            // Extract text using OCR
            await extractTextFromImage(image)
            
        } catch {
            self.error = error
        }
    }
    
    private func extractTextFromImage(_ image: UIImage) async {
        isExtractingText = true
        
        do {
            let text = try await ocrManager.recognizeText(from: image)
            let cleaned = ocrManager.cleanExtractedText(text)
            
            extractedText = cleaned
            
            // Clear manual input when we have OCR text
            if !cleaned.isEmpty {
                inputText = ""
            }
            
        } catch let error as OCRError {
            // Don't treat noTextFound as a hard error - user can still generate roast from manual input
            if case .noTextFound = error {
                extractedText = nil
                // Don't set self.error - this is not a fatal error
            } else {
                self.error = error
                extractedText = nil
            }
        } catch {
            self.error = error
            extractedText = nil
        }
        
        isExtractingText = false
    }
    
    func clearImage() {
        uploadedImage = nil
        extractedText = nil
        selectedPhoto = nil
    }
    
    // MARK: - Roast Generation
    
    func generateRoast(using llmManager: LLMManager, userId: String) async {
        guard canGenerate else { return }
        
        isGenerating = true
        currentRoast = ""
        error = nil
        
        let inputForRoast = effectiveInputText
        let prompt = buildRoastPrompt(for: inputForRoast)
        
        do {
            // Use streaming for real-time response
            try await llmManager.streamPrompt(
                prompt,
                context: [],
                onChunk: { [weak self] chunk in
                    Task { @MainActor in
                        self?.currentRoast += chunk
                    }
                },
                onComplete: { [weak self] response in
                    Task { @MainActor in
                        guard let self = self else { return }
                        
                        // Create session
                        let session = RoastSession(
                            userId: userId,
                            inputText: inputForRoast,
                            roastText: self.currentRoast,
                            imageURL: nil, // TODO: Upload image to Firebase Storage
                            ocrText: self.extractedText
                        )
                        
                        self.currentSession = session
                        
                        // Save to Firebase
                        await self.saveSession(session)
                        
                        self.isGenerating = false
                    }
                }
            )
            
        } catch {
            self.error = error
            isGenerating = false
        }
    }
    
    func regenerateRoast(using llmManager: LLMManager, userId: String) async {
        // Clear current roast and regenerate
        currentRoast = ""
        await generateRoast(using: llmManager, userId: userId)
    }
    
    // MARK: - Prompt Building
    
    private func buildRoastPrompt(for text: String) -> String {
        return """
        You are RoastGPT, a savage AI roast generator. Your job is to deliver brutal, witty, and hilarious roasts.
        
        Be creative, be savage, but keep it entertaining. Use humor, wordplay, and clever observations.
        
        Here's the text to roast:
        
        "\(text)"
        
        Now deliver an epic roast (2-4 sentences):
        """
    }
    
    // MARK: - Actions
    
    func copyRoast() {
        UIPasteboard.general.string = currentRoast
        // TODO: Show success feedback
    }
    
    func shareRoast() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [currentRoast],
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
