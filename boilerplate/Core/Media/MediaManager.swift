//
//  MediaManager.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import UIKit
import SwiftUI
import PhotosUI
import AVFoundation

/// Manages media operations: picking, processing, uploading
@MainActor
class MediaManager: ObservableObject {
    @Published private(set) var uploadState: MediaUploadState = .idle
    @Published private(set) var selectedMedia: [MediaAttachment] = []
    
    private let configuration: MediaConfiguration
    private let storageManager: StorageManager
    
    init(
        configuration: MediaConfiguration = .default,
        storageManager: StorageManager = StorageManager()
    ) {
        self.configuration = configuration
        self.storageManager = storageManager
    }
    
    // MARK: - Photo Library Access
    
    func checkPhotoLibraryPermission() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return newStatus == .authorized || newStatus == .limited
        default:
            return false
        }
    }
    
    // MARK: - Camera Access
    
    func checkCameraPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
    
    // MARK: - Process Photo Picker Results
    
    func processPhotoPickerResults(_ results: [PhotosPickerItem]) async throws -> [MediaAttachment] {
        var attachments: [MediaAttachment] = []
        
        for item in results {
            if let attachment = try await processPhotoPickerItem(item) {
                attachments.append(attachment)
            }
        }
        
        return attachments
    }
    
    private func processPhotoPickerItem(_ item: PhotosPickerItem) async throws -> MediaAttachment? {
        // Load image data
        guard let data = try await item.loadTransferable(type: Data.self) else {
            return nil
        }
        
        // Create UIImage
        guard let image = UIImage(data: data) else {
            throw MediaError.invalidImage
        }
        
        // Compress and resize
        let processedImage = try await processImage(image)
        
        // Convert to JPEG
        guard let imageData = processedImage.jpegData(compressionQuality: configuration.imageCompressionQuality) else {
            throw MediaError.compressionFailed
        }
        
        // Create thumbnail
        let thumbnail = try await createThumbnail(from: processedImage)
        let thumbnailData = thumbnail.jpegData(compressionQuality: 0.5)
        
        // Convert to base64 for API
        let base64String = imageData.base64EncodedString()
        
        // Save to temporary location
        let tempURL = try saveToTemporaryDirectory(data: imageData, fileName: "image_\(UUID().uuidString).jpg")
        
        return MediaAttachment(
            type: .image,
            fileName: tempURL.lastPathComponent,
            fileSize: imageData.count,
            mimeType: "image/jpeg",
            localURL: tempURL,
            thumbnailData: thumbnailData,
            base64Data: base64String,
            width: Int(processedImage.size.width),
            height: Int(processedImage.size.height)
        )
    }
    
    // MARK: - Process Camera Image
    
    func processCameraImage(_ image: UIImage) async throws -> MediaAttachment {
        // Process and compress
        let processedImage = try await processImage(image)
        
        guard let imageData = processedImage.jpegData(compressionQuality: configuration.imageCompressionQuality) else {
            throw MediaError.compressionFailed
        }
        
        // Create thumbnail
        let thumbnail = try await createThumbnail(from: processedImage)
        let thumbnailData = thumbnail.jpegData(compressionQuality: 0.5)
        
        // Convert to base64
        let base64String = imageData.base64EncodedString()
        
        // Save to temporary location
        let tempURL = try saveToTemporaryDirectory(data: imageData, fileName: "camera_\(UUID().uuidString).jpg")
        
        return MediaAttachment(
            type: .image,
            fileName: tempURL.lastPathComponent,
            fileSize: imageData.count,
            mimeType: "image/jpeg",
            localURL: tempURL,
            thumbnailData: thumbnailData,
            base64Data: base64String,
            width: Int(processedImage.size.width),
            height: Int(processedImage.size.height)
        )
    }
    
    // MARK: - Process Video
    
    func processVideo(from url: URL) async throws -> MediaAttachment {
        let asset = AVURLAsset(url: url)
        
        // Get video properties
        let duration = try await asset.load(.duration).seconds
        let tracks = try await asset.load(.tracks)
        
        guard let videoTrack = tracks.first(where: { $0.mediaType == .video }) else {
            throw MediaError.invalidVideo
        }
        
        let size = try await videoTrack.load(.naturalSize)
        
        // Generate thumbnail
        let thumbnailImage = try await generateVideoThumbnail(from: asset)
        let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.5)
        
        // Get file size
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let fileSize = fileAttributes[.size] as? Int ?? 0
        
        // Check size limit
        guard fileSize <= configuration.maxVideoSize else {
            throw MediaError.fileTooLarge
        }
        
        return MediaAttachment(
            type: .video,
            fileName: url.lastPathComponent,
            fileSize: fileSize,
            mimeType: "video/mp4",
            localURL: url,
            thumbnailData: thumbnailData,
            width: Int(size.width),
            height: Int(size.height),
            duration: duration
        )
    }
    
    // MARK: - Process Document
    
    func processDocument(from url: URL) async throws -> MediaAttachment {
        // Access security-scoped resource
        guard url.startAccessingSecurityScopedResource() else {
            throw MediaError.permissionDenied
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        // Read file data
        let data = try Data(contentsOf: url)
        
        // Check size
        guard data.count <= configuration.maxFileSize else {
            throw MediaError.fileTooLarge
        }
        
        // Validate file type
        let fileExtension = url.pathExtension.lowercased()
        guard configuration.allowedDocumentFormats.contains(fileExtension) else {
            throw MediaError.invalidFileType
        }
        
        // Save to temporary location
        let tempURL = try saveToTemporaryDirectory(data: data, fileName: url.lastPathComponent)
        
        return MediaAttachment(
            type: .document,
            fileName: url.lastPathComponent,
            fileSize: data.count,
            mimeType: mimeType(for: fileExtension),
            localURL: tempURL
        )
    }
    
    // MARK: - Image Processing
    
    private func processImage(_ image: UIImage) async throws -> UIImage {
        // Resize if needed
        let maxDimension = configuration.maxImageDimension
        let size = image.size
        
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }
        
        let scale = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                image.draw(in: CGRect(origin: .zero, size: newSize))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                continuation.resume(returning: resizedImage ?? image)
            }
        }
    }
    
    private func createThumbnail(from image: UIImage) async throws -> UIImage {
        let thumbnailSize = CGSize(width: 200, height: 200)
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 1.0)
                image.draw(in: CGRect(origin: .zero, size: thumbnailSize))
                let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                continuation.resume(returning: thumbnail ?? image)
            }
        }
    }
    
    private func generateVideoThumbnail(from asset: AVURLAsset) async throws -> UIImage {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1.0, preferredTimescale: 600)
        let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - File Management
    
    private func saveToTemporaryDirectory(data: Data, fileName: String) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        try data.write(to: fileURL)
        return fileURL
    }
    
    private func mimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "heic": return "image/heic"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        case "pdf": return "application/pdf"
        case "txt": return "text/plain"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        default: return "application/octet-stream"
        }
    }
    
    // MARK: - Upload
    
    func uploadMedia(_ attachment: MediaAttachment) async throws {
        uploadState = .uploading(progress: 0.0)
        
        // TODO: Implement actual upload to your backend/storage service
        // For now, we'll simulate upload progress
        
        for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
            uploadState = .uploading(progress: progress)
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
        }
        
        uploadState = .completed
    }
    
    // MARK: - Cleanup
    
    func deleteTemporaryFiles() {
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: tempDir,
                includingPropertiesForKeys: nil
            )
            
            for url in contents {
                try? FileManager.default.removeItem(at: url)
            }
        } catch {
            ErrorHandler.log(error, context: "Cleaning up temporary files")
        }
    }
}
