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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Input Section
                    inputSection
                    
                    // OR Divider
                    orDivider
                    
                    // Image Upload Section
                    imageUploadSection
                    
                    // Generate Button
                    generateButton
                    
                    // Output Section
                    if viewModel.hasOutput {
                        outputSection
                    }
                }
                .padding()
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
            
            Text("Enter text or upload a screenshot to get roasted by AI")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    // MARK: - Input Section
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter Text")
                .font(.headline)
            
            TextField("Type your text here...", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(5...10)
                .disabled(viewModel.isProcessing)
            
            Text("\(viewModel.inputText.count) characters")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - OR Divider
    
    private var orDivider: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            Text("OR")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
        }
    }
    
    // MARK: - Image Upload Section
    
    private var imageUploadSection: some View {
        VStack(spacing: 16) {
            Text("Upload Screenshot")
                .font(.headline)
            
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
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Text("Upload Image")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
            )
        }
        .disabled(viewModel.isProcessing)
    }
    
    private func uploadedImagePreview(_ image: UIImage) -> some View {
        VStack(spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .cornerRadius(12)
                .clipped()
            
            Button(action: {
                viewModel.clearImage()
            }) {
                Label("Remove Image", systemImage: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Generate Button
    
    private var generateButton: some View {
        Button(action: {
            Task {
                await viewModel.generateRoast(using: llmManager, userId: authManager.currentUser?.id ?? "anonymous")
            }
        }) {
            HStack {
                if viewModel.isGenerating {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Image(systemName: "flame.fill")
                    Text("Generate Roast")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(viewModel.canGenerate ? Color.orange : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.canGenerate || viewModel.isProcessing)
    }
    
    // MARK: - Output Section
    
    private var outputSection: some View {
        StreamingTextCard(
            title: "🔥 Your Roast",
            text: viewModel.currentRoast,
            isStreaming: viewModel.isGenerating,
            onCopy: {
                viewModel.copyRoast()
            },
            onShare: {
                viewModel.shareRoast()
            },
            onRegenerate: {
                Task {
                    await viewModel.regenerateRoast(using: llmManager, userId: authManager.currentUser?.id ?? "anonymous")
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
