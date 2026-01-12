//
//  TextRoastView.swift
//  boilerplate
//
//  RoastGPT Clone - Text input roasting
//  Created by Ankur on 1/12/26.
//

import SwiftUI

struct TextRoastView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject private var llmManager: LLMManager
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Text Input
                    textInputSection
                    
                    // Generate Button
                    generateButton
                    
                    // Output Section
                    if viewModel.hasOutput {
                        outputSection
                    }
                }
                .padding()
            }
            .navigationTitle("Text Roast")
            .navigationBarTitleDisplayMode(.large)
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
            
            Text("Enter text to get brutally roasted by AI")
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
            Text("Your Text")
                .font(.headline)
            
            TextField("Type anything here...", text: $viewModel.inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(5...15)
                .disabled(viewModel.isProcessing)
            
            HStack {
                Text("\(viewModel.inputText.count) characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !viewModel.inputText.isEmpty {
                    Button("Clear") {
                        viewModel.inputText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                }
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
    TextRoastView()
        .environmentObject(LLMManager())
        .environmentObject(AuthManager())
}
