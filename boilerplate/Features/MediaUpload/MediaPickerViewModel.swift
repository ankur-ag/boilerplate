//
//  MediaPickerViewModel.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
class MediaPickerViewModel: ObservableObject {
    @Published var selectedAttachments: [MediaAttachment] = []
    @Published var showPhotoPicker = false
    @Published var showCamera = false
    @Published var showDocumentPicker = false
    @Published var photoSelection: [PhotosPickerItem] = []
    @Published var error: MediaError?
    
    private let mediaManager = MediaManager()
    
    // MARK: - Photo Picker
    
    func openPhotoPicker() {
        showPhotoPicker = true
    }
    
    func loadPhotoPickerResults() async {
        guard !photoSelection.isEmpty else { return }
        
        do {
            let attachments = try await mediaManager.processPhotoPickerResults(photoSelection)
            selectedAttachments.append(contentsOf: attachments)
            photoSelection = []
        } catch let error as MediaError {
            self.error = error
        } catch {
            self.error = .uploadFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Camera
    
    func openCamera() async {
        let hasPermission = await mediaManager.checkCameraPermission()
        
        if hasPermission {
            showCamera = true
        } else {
            error = .permissionDenied
        }
    }
    
    func processCameraImage(_ image: UIImage) async {
        do {
            let attachment = try await mediaManager.processCameraImage(image)
            selectedAttachments.append(attachment)
        } catch let error as MediaError {
            self.error = error
        } catch {
            self.error = .uploadFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Video Picker
    
    func openVideoPicker() {
        // Use photo picker with video filter
        photoSelection = []
        showPhotoPicker = true
        // TODO: Configure for video selection
    }
    
    // MARK: - Document Picker
    
    func openDocumentPicker() {
        showDocumentPicker = true
    }
    
    func processDocuments(_ urls: [URL]) async {
        for url in urls {
            do {
                let attachment = try await mediaManager.processDocument(from: url)
                selectedAttachments.append(attachment)
            } catch let error as MediaError {
                self.error = error
            } catch {
                self.error = .uploadFailed(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Management
    
    func removeAttachment(_ attachment: MediaAttachment) {
        selectedAttachments.removeAll { $0.id == attachment.id }
    }
    
    func clearAll() {
        selectedAttachments.removeAll()
    }
}
