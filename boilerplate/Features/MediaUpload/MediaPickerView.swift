//
//  MediaPickerView.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import SwiftUI
import PhotosUI

struct MediaPickerView: View {
    @StateObject private var viewModel = MediaPickerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let onMediaSelected: ([MediaAttachment]) -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Options Grid
                    optionsGrid
                    
                    // Selected Media Preview
                    if !viewModel.selectedAttachments.isEmpty {
                        selectedMediaSection
                    }
                }
                .padding()
            }
            .navigationTitle("Add Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onMediaSelected(viewModel.selectedAttachments)
                        dismiss()
                    }
                    .disabled(viewModel.selectedAttachments.isEmpty)
                }
            }
            .photosPicker(
                isPresented: $viewModel.showPhotoPicker,
                selection: $viewModel.photoSelection,
                maxSelectionCount: 5,
                matching: .images
            )
            .sheet(isPresented: $viewModel.showCamera) {
                CameraView { image in
                    Task {
                        await viewModel.processCameraImage(image)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showDocumentPicker) {
                DocumentPickerView { urls in
                    Task {
                        await viewModel.processDocuments(urls)
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
        .task {
            await viewModel.loadPhotoPickerResults()
        }
    }
    
    private var optionsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            MediaOptionCard(
                icon: "photo.on.rectangle",
                title: "Photo Library",
                color: .blue
            ) {
                viewModel.openPhotoPicker()
            }
            
            MediaOptionCard(
                icon: "camera.fill",
                title: "Camera",
                color: .purple
            ) {
                Task {
                    await viewModel.openCamera()
                }
            }
            
            MediaOptionCard(
                icon: "doc.fill",
                title: "Documents",
                color: .orange
            ) {
                viewModel.openDocumentPicker()
            }
            
            MediaOptionCard(
                icon: "video.fill",
                title: "Video",
                color: .red
            ) {
                viewModel.openVideoPicker()
            }
        }
    }
    
    private var selectedMediaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected (\(viewModel.selectedAttachments.count))")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.selectedAttachments) { attachment in
                        MediaThumbnailView(attachment: attachment)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    viewModel.removeAttachment(attachment)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .offset(x: 8, y: -8)
                            }
                    }
                }
            }
        }
    }
}

// MARK: - Media Option Card

private struct MediaOptionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Media Thumbnail View

struct MediaThumbnailView: View {
    let attachment: MediaAttachment
    
    var body: some View {
        VStack(spacing: 4) {
            // Thumbnail
            if let thumbnail = attachment.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
                    .clipped()
            } else {
                // Placeholder for non-image files
                ZStack {
                    Color.gray.opacity(0.2)
                    
                    Image(systemName: attachment.type.systemIcon)
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
                .frame(width: 100, height: 100)
                .cornerRadius(8)
            }
            
            // File info
            Text(attachment.fileName)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 100)
            
            Text(attachment.fileSizeFormatted)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
