//
//  HomeView.swift
//  boilerplate
//
//  RoastGPT Clone - Main roast generation screen
//  Created by Ankur on 1/12/26.
//

import SwiftUI
import PhotosUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var llmManager: LLMManager
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    @State private var selectedInputMode: InputMode = .text
    
    enum InputMode {
        case text
        case image
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Control for Input Mode
                Picker("Input Mode", selection: $selectedInputMode) {
                    Label("Text", systemImage: "text.quote").tag(InputMode.text)
                    Label("Image", systemImage: "photo").tag(InputMode.image)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content based on selected mode
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Input Section (changes based on mode)
                        if selectedInputMode == .text {
                            textInputSection
                        } else {
                            imageInputSection
                        }
                        
                        // Generate Button
                        generateButton
                        
                        // Output Section
                        if viewModel.hasOutput {
                            outputSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("RoastGPT")
            .navigationBarTitleDisplayMode(.large)
            .photosPicker(
                isPresented: $viewModel.showImagePicker,
                selection: $viewModel.selectedPhoto,
                matching: .images
            )
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
            .onChange(of: viewModel.selectedPhoto) { oldValue, newValue in
                Task {
                    await viewModel.processSelectedPhoto()
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Get Roasted")
                .font(.title)
                .fontWeight(.bold)
            
            Text(selectedInputMode == .text ? "Enter text to get roasted" : "Upload a screenshot to get roasted")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    // MARK: - Text Input Section
    
    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Type your text here...", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(5...10)
                .disabled(viewModel.isProcessing)
            
            Text("\(viewModel.inputText.count) characters")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Image Input Section
    
    private var imageInputSection: some View {
        VStack(spacing: 16) {
            // Upload Button or Preview
            if let image = viewModel.uploadedImage {
                uploadedImagePreview(image)
            } else {
                uploadButton
            }
            
            // OCR Status
            if viewModel.isExtractingText {
                HStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Extracting text from image...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            // OCR Result or No Text Message
            if viewModel.uploadedImage != nil && !viewModel.isExtractingText {
                if let ocrText = viewModel.extractedText, !ocrText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Extracted Text:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    
                        ScrollView {
                            Text(ocrText)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                        }
                        .frame(maxHeight: 120)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                } else {
                    // No text found - show helpful message
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.orange)
                        Text("No text found in image. You can still enter text manually above.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private var uploadButton: some View {
        Button(action: {
            viewModel.showImagePicker = true
        }) {
            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                Text("Upload Screenshot")
                    .font(.headline)
                
                Text("Tap to select from photos")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    private func uploadedImagePreview(_ image: UIImage) -> some View {
        VStack(spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
                .cornerRadius(12)
            
            Button(action: {
                viewModel.clearImage()
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Remove Image")
                }
                .font(.caption)
                .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Generate Button
    
    private var generateButton: some View {
        Button(action: {
            guard let userId = authManager.currentUser?.id else { return }
            Task {
                await viewModel.generateRoast(using: llmManager, userId: userId)
            }
        }) {
            HStack {
                if viewModel.isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "flame.fill")
                }
                Text(viewModel.isGenerating ? "Generating..." : "🔥 Generate Roast")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canGenerate ? Color.orange : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.canGenerate)
    }
    
    // MARK: - Output Section
    
    private var outputSection: some View {
        StreamingTextCard(
            title: "Your Roast",
            text: viewModel.currentRoast,
            isStreaming: viewModel.isGenerating,
            onCopy: {
                viewModel.copyRoast()
            },
            onShare: {
                viewModel.shareRoast()
            },
            onRegenerate: {
                guard let userId = authManager.currentUser?.id else { return }
                Task {
                    await viewModel.regenerateRoast(using: llmManager, userId: userId)
                }
            }
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(LLMManager())
        .environmentObject(AuthManager())
        .environmentObject(SubscriptionManager())
}
