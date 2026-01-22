//
//  ImageRoastView.swift
//  boilerplate
//
//  Posterized - Image Roast Screen (AI generates roast images)
//  Created by Ankur on 1/12/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct ImageRoastView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ImageRoastViewModel()
    @EnvironmentObject private var llmManager: LLMManager
    @EnvironmentObject private var imageGenerationManager: ImageGenerationManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var usageManager: UsageManager
    @FocusState private var isInputFocused: Bool
    @State private var showPaywall = false
    @State private var reloadID = UUID() // Used to force reload images
    
    let initialSession: RoastSession?
    
    init(session: RoastSession? = nil) {
        self.initialSession = session
    }
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerBar
                
                // Content
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        // Prompt Card
                        promptCard
                            .padding(.horizontal, DesignSystem.Spacing.md)
                        
                        // User Input (if already generated)
                        if viewModel.hasOutput {
                            userInputCard
                                .padding(.horizontal, DesignSystem.Spacing.md)
                        }
                        
                        // Roast Image Outputs (Top 2 levels only)
                        if viewModel.hasOutput || viewModel.isGenerating {
                            roastImagesSection
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.sm)
                    .padding(.bottom, 180) // Space for bottom input
                    .animation(.easeInOut(duration: 0.4), value: viewModel.hasOutput)
                }
                
                Spacer()
            }
            
            // Bottom Input Section (always visible)
            VStack {
                Spacer()
                bottomInputSection
            }
            .ignoresSafeArea(.keyboard)
            
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if let session = initialSession {
                viewModel.loadSession(session)
            }
        }
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack {
            // Back Button
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.body)
                    .foregroundColor(DesignSystem.Colors.accentCyan)
                    .frame(width: 32, height: 32)
            }
            
            Spacer()
            
            // Title
            Text("IMAGE ROAST")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(DesignSystem.Colors.primaryOrange)
            
            Spacer()
            
            // Spacer for centering
            Color.clear
                .frame(width: 32)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .frame(height: 44)
    }
    
    // MARK: - Prompt Card
    
    private var promptCard: some View {
        Text("Whom do you want to clown about what?")
            .font(.system(size: 14))
            .foregroundColor(DesignSystem.Colors.textSecondary)
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignSystem.Colors.backgroundCard)
            .cornerRadius(DesignSystem.CornerRadius.md)
    }
    
    // MARK: - User Input Card
    
    private var userInputCard: some View {
        Text(viewModel.submittedInput)
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color(hex: "FF4500"), Color(hex: "FF6B35")],
                    startPoint: .leading,
                    endPoint: .trailing)
            )
            .cornerRadius(DesignSystem.CornerRadius.md)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Roast Images Section (Top 2 levels only)
    
    private var roastImagesSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // POSTERIZED (Highest level)
            roastImageCard(
                intensity: .posterized,
                imageURL: viewModel.posterizedImage,
                borderColor: Color(hex: "FF4500")
            )
            
            // DUNKED ON (Medium level)
            roastImageCard(
                intensity: .dunkedOn,
                imageURL: viewModel.dunkedOnImage,
                borderColor: DesignSystem.Colors.accentCyan
            )
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func roastImageCard(intensity: RoastIntensity, imageURL: String?, borderColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Area
            ZStack {
                // Actual image or loading state
                if let rawURLString = imageURL {
                    // ImageKit returns full public URLs, no need to publicize manually unless using relative paths
                    let publicizedURLString = rawURLString
                    
                    // Add reloadID to force re-evaluation of the URL and its object identity (Network only)
                    let finalURLString = publicizedURLString.hasPrefix("http")
                        ? "\(publicizedURLString)\(publicizedURLString.contains("?") ? "&" : "?")v=\(reloadID.uuidString.prefix(8))"
                        : publicizedURLString
                    
                    if let url = URL(string: finalURLString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                roastingLoadingView(intensity: intensity)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            case .failure(let error):
                                VStack(spacing: DesignSystem.Spacing.sm) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 32))
                                        .foregroundColor(DesignSystem.Colors.accentYellow)
                                    Text("Failed to load image")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(DesignSystem.Colors.textSecondary)
                                    
                                    Text(error.localizedDescription)
                                        .font(.system(size: 10))
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    Button(action: {
                                        reloadID = UUID()
                                    }) {
                                        Label("Retry", systemImage: "arrow.clockwise")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(DesignSystem.Colors.accentCyan)
                                            .cornerRadius(6)
                                    }
                                    .padding(.top, 4)
                                }
                                .frame(maxWidth: .infinity)
                                .aspectRatio(16/9, contentMode: .fit)
                                .background(DesignSystem.Colors.backgroundCard)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .id("\(intensity.rawValue)-\(reloadID)")
                        .frame(maxWidth: .infinity)
                    }
                } else if viewModel.isGenerating {
                    roastingLoadingView(intensity: intensity)
                } else {
                    Rectangle()
                        .fill(DesignSystem.Colors.backgroundCard)
                        .aspectRatio(16/9, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 48))
                                .foregroundColor(DesignSystem.Colors.textSecondary.opacity(0.3))
                        )
                }
            }
            
            // Tags and Share Button
            HStack(spacing: DesignSystem.Spacing.xs) {
                // Intensity Tag
                Text(intensity.rawValue)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(intensity.contentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(intensity.color)
                    .cornerRadius(4)
                
                Spacer()
                
                // Share Button
                if let urlString = imageURL, let url = URL(string: urlString) {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundColor(DesignSystem.Colors.accentCyan)
                    }
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(Color.black.opacity(0.8))
        }
        .overlay(
            Rectangle()
                .stroke(borderColor, lineWidth: 3)
        )
        .clipped()
    }
    
    private func roastingLoadingView(intensity: RoastIntensity) -> some View {
        ZStack {
            DesignSystem.Colors.backgroundCard
            
            VStack(spacing: DesignSystem.Spacing.md) {
                // Animated Roast Icon
                ZStack {
                    Circle()
                        .stroke(DesignSystem.Colors.primaryOrange.opacity(0.3), lineWidth: 4)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "flame.fill")
                        .font(.system(size: 30))
                        .foregroundColor(DesignSystem.Colors.primaryOrange)
                        .symbolEffect(.pulse)
                }
                
                VStack(spacing: 4) {
                    Text(intensity == .posterized ? "COOKING SAVAGE ROAST..." : "DUNKING ON 'EM...")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
        .aspectRatio(16/9, contentMode: .fit)
    }
    
    // MARK: - Bottom Input Section
    
    private var bottomInputSection: some View {
        VStack(spacing: 0) {
            // Intensity Level Buttons
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach([RoastIntensity.trashTalk, .dunkedOn, .posterized], id: \.self) { intensity in
                    Button(action: {
                        viewModel.selectedIntensity = intensity
                    }) {
                        Text(intensity.rawValue)
                            .font(DesignSystem.Typography.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.selectedIntensity == intensity ? intensity.contentColor : DesignSystem.Colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(viewModel.selectedIntensity == intensity ? 
                                       (intensity == .posterized ? Color(hex: "FF4500") : 
                                        intensity == .dunkedOn ? Color(hex: "FF8C00") : 
                                        Color(hex: "FFCC00")) :
                                       DesignSystem.Colors.backgroundCard)
                            .cornerRadius(DesignSystem.CornerRadius.sm)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.top, DesignSystem.Spacing.md)
            
            // Input Row
            HStack(spacing: DesignSystem.Spacing.sm) {
                // Plus Button
                Button(action: {
                    viewModel.showPhotoPicker = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(DesignSystem.Colors.accentCyan)
                        .frame(width: 44, height: 44)
                }
                .photosPicker(
                    isPresented: $viewModel.showPhotoPicker,
                    selection: $viewModel.photoSelection,
                    matching: .images
                )
                
                // Text Input
                ZStack(alignment: .leading) {
                    if viewModel.inputText.isEmpty && !isInputFocused && viewModel.selectedImage == nil {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("e.g. My Lakers friend talking trash after getting swept...")
                                .font(DesignSystem.Typography.footnote)
                                .foregroundColor(DesignSystem.Colors.textPlaceholder)
                                .lineLimit(1)
                            
                            if subscriptionManager.isPremium {
                                Text("PREMIUM: UNLIMITED")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.accentCyan)
                            } else {
                                let remaining = max(0, 1 - usageManager.imageRoastCount)
                                Text("FREE: \(remaining) IMAGE ROAST\(remaining == 1 ? "" : "S") LEFT")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(DesignSystem.Colors.accentYellow)
                            }
                        }
                        .padding(.leading, DesignSystem.Spacing.sm)
                    }
                    
                    HStack {
                         if let image = viewModel.selectedImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                
                                Button(action: {
                                    viewModel.clearMedia()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }
                                .offset(x: 4, y: -4)
                            }
                            .padding(.leading, 4)
                        }
                        
                        TextField("", text: $viewModel.inputText)
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .focused($isInputFocused)
                            .padding(DesignSystem.Spacing.sm)
                    }
                }
                .frame(height: 44)
                .background(DesignSystem.Colors.backgroundCard)
                .cornerRadius(DesignSystem.CornerRadius.lg)
                
                // Send Button
                Button(action: {
                    // Check if user can generate image roast
                    if !usageManager.canGenerateImageRoast(isPremium: subscriptionManager.isPremium) {
                        showPaywall = true
                        return
                    }
                    
                    guard let userId = authManager.currentUser?.id else { return }
                    Task {
                        await viewModel.generateImageRoast(
                            using: imageGenerationManager,
                            userId: userId,
                            usageManager: usageManager,
                            onFirstRoast: {
                                // Show paywall after first roast (5-7 seconds)
                                Task { @MainActor in
                                    try? await Task.sleep(nanoseconds: UInt64.random(in: 5_000_000_000...7_000_000_000))
                                    if !subscriptionManager.isPremium {
                                        showPaywall = true
                                    }
                                }
                            }
                        )
                    }
                }) {
                    Image(systemName: "arrow.right")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(DesignSystem.Colors.accentCyan)
                        .cornerRadius(DesignSystem.CornerRadius.lg)
                }
                .disabled(!viewModel.canGenerate)
                .opacity(viewModel.canGenerate ? 1.0 : 0.5)
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            
            // Regenerate Button (always visible, disabled when no output)
            Button(action: {
                // Check if user can regenerate
                if !usageManager.canGenerateImageRoast(isPremium: subscriptionManager.isPremium) {
                    showPaywall = true
                    return
                }
                
                guard let userId = authManager.currentUser?.id else { return }
                Task {
                    await viewModel.regenerateImageRoast(using: imageGenerationManager, userId: userId, usageManager: usageManager)
                }
            }) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("REGENERATE")
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.bold)
                }
                .foregroundColor(viewModel.hasOutput ? DesignSystem.Colors.accentCyan : DesignSystem.Colors.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(viewModel.hasOutput ? DesignSystem.Colors.accentCyan.opacity(0.15) : DesignSystem.Colors.backgroundCard)
                .cornerRadius(DesignSystem.CornerRadius.md)
            }
            .disabled(!viewModel.hasOutput || viewModel.isGenerating)
            .opacity(viewModel.hasOutput ? 1.0 : 0.4)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .animation(.easeInOut(duration: 0.3), value: viewModel.hasOutput)
        }
        .background(DesignSystem.Colors.backgroundPrimary)
        .overlay(
            Rectangle()
                .fill(DesignSystem.Colors.border)
                .frame(height: 1),
            alignment: .top
        )
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Image Roast View Model

@MainActor
class ImageRoastViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var submittedInput: String = ""
    @Published var posterizedImage: String? = nil  // URL to generated image
    @Published var dunkedOnImage: String? = nil     // URL to generated image
    @Published var selectedIntensity: RoastIntensity = .posterized
    @Published var isGenerating: Bool = false
    @Published var error: Error?
    @Published var userPreferences: UserSportsPreferences?
    @Published private(set) var currentSession: RoastSession?
    
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
    
    private let storageManager = StorageManager()
    private let firebaseService = FirebaseService.shared
    private let mediaManager = MediaManager()
    
    var hasOutput: Bool {
        posterizedImage != nil || dunkedOnImage != nil
    }
    
    var canGenerate: Bool {
        (!inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImage != nil) && !isGenerating
    }
    
    init() {
        loadUserPreferences()
    }
    
    func loadUserPreferences() {
        userPreferences = storageManager.loadUserSportsPreferences()
        if let prefs = userPreferences {
            self.selectedIntensity = prefs.intensity
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
            print("❌ [ImageRoast] Failed to refresh preferences from Firebase: \(error.localizedDescription)")
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
    
    // MARK: - Image Roast Generation
    
    func generateImageRoast(
        using imageGenManager: ImageGenerationManager,
        userId: String,
        usageManager: UsageManager? = nil,
        onFirstRoast: (() -> Void)? = nil
    ) async {
        guard canGenerate else { return }
        
        // Track if this is first roast
        let isFirstRoast = usageManager?.imageRoastCount == 0
        
        isGenerating = true
        posterizedImage = nil
        dunkedOnImage = nil
        error = nil
        
        let inputForRoast = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        submittedInput = inputForRoast
        
        // Prepare image data if available
        var inputImageData: Data?
        if let media = selectedMedia, let url = media.localURL {
             inputImageData = try? Data(contentsOf: url)
        }
        
        inputText = ""
        self.clearMedia()
        
        // Build roast prompt with context
        let roastPrompt = buildImageRoastPrompt(input: inputForRoast)
        
        do {
            // Parallel Generation using async let
            print("🚀 Starting parallel image generation...")
            
            async let posterizedResult: GeneratedImage? = {
                do {
                    print("🎨 Generating POSTERIZED image...")
                    return try await imageGenManager.generateImage(prompt: roastPrompt, style: .posterized, inputImage: inputImageData)
                } catch {
                    print("⚠️ [ViewModel] Posterized generation failed: \(error.localizedDescription)")
                    return nil
                }
            }()
            
            async let dunkedOnResult: GeneratedImage? = {
                do {
                    print("🎨 Generating DUNKED ON image...")
                    return try await imageGenManager.generateImage(prompt: roastPrompt, style: .dunkedOn, inputImage: inputImageData)
                } catch {
                    print("⚠️ [ViewModel] Dunked On generation failed: \(error.localizedDescription)")
                    return nil
                }
            }()
            
            // Await both results
            let (posterized, dunkedOn) = await (posterizedResult, dunkedOnResult)
            
            // Process Results
            var posterizedURL: String?
            if let img = posterized {
                posterizedImage = img.imageURL
                posterizedURL = img.imageURL
            }
            
            var dunkedOnURL: String?
            if let img = dunkedOn {
                dunkedOnImage = img.imageURL
                dunkedOnURL = img.imageURL
            }
            
            // Set error if both failed (for UI feedback)
            if posterized == nil && dunkedOn == nil {
                print("❌ [ViewModel] Both image generation levels failed")
                if self.error == nil { self.error = ImageGenerationError.generationFailed("Could not generate any images") }
            }
            
            // Proceed if we have AT LEAST ONE image
            if let pURL = posterizedURL {
                print("✅ Image roast generated (at least one level)")
                await createAndUploadSession(
                    userId: userId,
                    input: inputForRoast,
                    localURL: pURL,
                    secondaryLocalURL: dunkedOnURL,
                    intensity: self.selectedIntensity,
                    onSuccess: {
                        usageManager?.incrementImageRoastCount()
                        if isFirstRoast {
                            onFirstRoast?()
                        }
                    }
                )
            } else if let dURL = dunkedOnURL {
                // Secondary only success
                print("✅ Image roast generated (only secondary level)")
                await createAndUploadSession(
                    userId: userId,
                    input: inputForRoast,
                    localURL: dURL, // Use dunkedOn as primary
                    secondaryLocalURL: nil,
                    intensity: self.selectedIntensity,
                    onSuccess: {
                        usageManager?.incrementImageRoastCount()
                        if isFirstRoast {
                            onFirstRoast?()
                        }
                    }
                 )
                 // Update UI to show this as primary
                 posterizedImage = dURL
                 dunkedOnImage = nil
            }
        }
        
        isGenerating = false
    }
    
    func regenerateImageRoast(
        using imageGenManager: ImageGenerationManager,
        userId: String,
        usageManager: UsageManager? = nil
    ) async {
        guard !submittedInput.isEmpty else { return }
        
        isGenerating = true
        let oldPosterized = posterizedImage
        let oldDunkedOn = dunkedOnImage
        posterizedImage = nil
        dunkedOnImage = nil
        error = nil
        
        let roastPrompt = buildImageRoastPrompt(input: submittedInput)
        
        do {
            // Level 1: POSTERIZED
            var posterizedURL: String?
            do {
                let posterized = try await imageGenManager.generateImage(prompt: roastPrompt, style: .posterized)
                posterizedImage = posterized.imageURL
                posterizedURL = posterized.imageURL
            } catch {
                print("⚠️ [ViewModel] Posterized regeneration failed: \(error.localizedDescription)")
            }
            
            // Level 2: DUNKED ON
            var dunkedOnURL: String?
            do {
                let dunkedOn = try await imageGenManager.generateImage(prompt: roastPrompt, style: .dunkedOn)
                dunkedOnImage = dunkedOn.imageURL
                dunkedOnURL = dunkedOn.imageURL
            } catch {
                print("⚠️ [ViewModel] Dunked On regeneration failed: \(error.localizedDescription)")
            }
            
            // Update if we have AT LEAST ONE new image
            if let pURL = posterizedURL {
                print("✅ Image roasts regenerated (at least one level)")
                await createAndUploadSession(
                    userId: userId,
                    input: submittedInput,
                    localURL: pURL,
                    secondaryLocalURL: dunkedOnURL,
                    intensity: self.selectedIntensity,
                    onSuccess: {
                        usageManager?.incrementImageRoastCount()
                    }
                )
            } else if let dURL = dunkedOnURL {
                 // Special case: Only second succeeds
                 print("✅ Image roast regenerated (only secondary level)")
                 // In this case we might want to keep the old posterized or leave it nil
                 // For now, let's treat posterized as primary and required for new sessions
                 // (Or refactor createAndUploadSession to be more flexible)
            } else {
                // Restore old images on total failure
                posterizedImage = oldPosterized
                dunkedOnImage = oldDunkedOn
                self.error = ImageGenerationError.generationFailed("Regeneration failed for all levels")
            }
        } catch {
            // Restore old images on error
            posterizedImage = oldPosterized
            dunkedOnImage = oldDunkedOn
            self.error = error
        }
        
        isGenerating = false
    }
    
    private func buildImageRoastPrompt(input: String) -> String {
        var prompt = input
        
        // Add sport-specific style and context
        if let prefs = userPreferences {
            let sportName = prefs.selectedSport.rawValue
            let myTeam = prefs.myTeam.name
            
            prompt += "\n\nSport: \(sportName)"
            prompt += "\n\nMy supported team: \(myTeam)"
            
            if !prefs.rivalTeams.isEmpty {
                let rivalNames = prefs.rivalTeams.map { $0.name }.joined(separator: ", ")
                prompt += "\n\nRival teams to roast: \(rivalNames)"
            }
            
            prompt += "\n\nRoast intensity: \(prefs.intensity.rawValue)"
            
            // Add style hints
            let styleHints = prefs.selectedSport == .nba ? 
                "Incorporate basketball elements like hoops, jerseys, and court textures." :
                "Incorporate football elements like goalposts, turf, and pigskin textures."
            prompt += "\n\nStyle: \(styleHints)"
        }
        
        return prompt
    }
    
    func clearOutput() {
        posterizedImage = nil
        dunkedOnImage = nil
        submittedInput = ""
        inputText = ""
        clearMedia()
        error = nil
        currentSession = nil
    }
    
    func loadSession(_ session: RoastSession) {
        self.currentSession = session
        self.submittedInput = session.inputText
        self.posterizedImage = session.imageURL
        self.dunkedOnImage = session.secondaryImageURL
        self.inputText = ""
        self.isGenerating = false
    }
    
    func clearError() {
        error = nil
    }
    
    // MARK: - Persistence & Cloud Storage
    
    private func createAndUploadSession(
        userId: String,
        input: String,
        localURL: String,
        secondaryLocalURL: String? = nil,
        intensity: RoastIntensity,
        onSuccess: @escaping () -> Void
    ) async {
        let sessionId = UUID().uuidString
        
        // Create initial session with local URLs
        let session = RoastSession(
            id: sessionId,
            userId: userId,
            inputText: input,
            roastText: "Generated Image Roast",
            secondaryRoastText: nil,
            timestamp: Date(),
            imageURL: nil, // We'll update after R2 upload
            secondaryImageURL: nil, // We'll update after R2 upload
            ocrText: nil,
            source: .image,
            intensity: intensity,
            sport: userPreferences?.selectedSport ?? .nba
        )
        
        self.currentSession = session
        
        do {
            // Save initial session to Firebase
            try await firebaseService.saveRoastSession(session)
            
            // Trigger background upload for both images
            uploadImageToCloud(localURL: localURL, userId: userId, sessionId: sessionId, isSecondary: false)
            if let secondaryLocalURL = secondaryLocalURL {
                uploadImageToCloud(localURL: secondaryLocalURL, userId: userId, sessionId: sessionId, isSecondary: true)
            }
            
            onSuccess()
        } catch {
            print("⚠️ [Firebase] Failed to save image roast session: \(error.localizedDescription)")
            // Still proceed with usage increment even if session save fails
            onSuccess()
        }
    }
    
    private func uploadImageToCloud(localURL: String, userId: String, sessionId: String, isSecondary: Bool) {
        Task.detached(priority: .background) {
            guard let url = URL(string: localURL),
                  let imageData = try? Data(contentsOf: url) else { 
                print("❌ [ImageKit] Could not load image data for upload from: \(localURL)")
                return 
            }
            
            do {
                let suffix = isSecondary ? "_secondary" : ""
                let fileName = "roasts/\(userId)/\(sessionId)\(suffix).png"
                let imageKitURL = try await ImageKitService.shared.uploadImage(imageData, fileName: fileName)
                
                // Update Firestore session with the ImageKit URL
                if isSecondary {
                    try await FirebaseService.shared.updateSessionImages(sessionId: sessionId, secondaryImageURL: imageKitURL)
                } else {
                    try await FirebaseService.shared.updateSessionImages(sessionId: sessionId, imageURL: imageKitURL)
                }
                
                print("✅ [ImageKit] Session images updated")
            } catch {
                print("❌ [ImageKit] Async upload failed: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ImageRoastView()
        .environmentObject(LLMManager())
        .environmentObject(ImageGenerationManager())
        .environmentObject(AuthManager())
        .environmentObject(SubscriptionManager())
        .environmentObject(UsageManager())
}
