//
//  MediaModels.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Media Type

enum MediaType: String, Codable {
    case image
    case video
    case document
    case audio
    
    var systemIcon: String {
        switch self {
        case .image: return "photo"
        case .video: return "video"
        case .document: return "doc"
        case .audio: return "waveform"
        }
    }
}

// MARK: - Media Attachment

struct MediaAttachment: Identifiable, Codable {
    let id: String
    let type: MediaType
    let fileName: String
    let fileSize: Int
    let mimeType: String
    let localURL: URL?
    let remoteURL: URL?
    let thumbnailData: Data?
    let base64Data: String?
    let width: Int?
    let height: Int?
    let duration: TimeInterval?
    let createdAt: Date
    
    init(
        id: String = UUID().uuidString,
        type: MediaType,
        fileName: String,
        fileSize: Int,
        mimeType: String,
        localURL: URL? = nil,
        remoteURL: URL? = nil,
        thumbnailData: Data? = nil,
        base64Data: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        duration: TimeInterval? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.localURL = localURL
        self.remoteURL = remoteURL
        self.thumbnailData = thumbnailData
        self.base64Data = base64Data
        self.width = width
        self.height = height
        self.duration = duration
        self.createdAt = createdAt
    }
    
    var thumbnail: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
    
    var fileSizeFormatted: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSize))
    }
}

// MARK: - Media Upload State

enum MediaUploadState: Equatable {
    case idle
    case uploading(progress: Double)
    case completed
    case failed(error: String)
    
    var isUploading: Bool {
        if case .uploading = self { return true }
        return false
    }
}

// MARK: - Media Configuration

struct MediaConfiguration {
    let maxImageSize: Int
    let maxVideoSize: Int
    let maxFileSize: Int
    let allowedImageFormats: [String]
    let allowedVideoFormats: [String]
    let allowedDocumentFormats: [String]
    let imageCompressionQuality: CGFloat
    let maxImageDimension: CGFloat
    
    static let `default` = MediaConfiguration(
        maxImageSize: 10 * 1024 * 1024,        // 10 MB
        maxVideoSize: 100 * 1024 * 1024,       // 100 MB
        maxFileSize: 25 * 1024 * 1024,         // 25 MB
        allowedImageFormats: ["jpg", "jpeg", "png", "heic", "webp"],
        allowedVideoFormats: ["mp4", "mov", "m4v"],
        allowedDocumentFormats: ["pdf", "txt", "doc", "docx", "xls", "xlsx"],
        imageCompressionQuality: 0.8,
        maxImageDimension: 2048
    )
}

// MARK: - Media Error

enum MediaError: LocalizedError {
    case invalidFileType
    case fileTooLarge
    case compressionFailed
    case uploadFailed(String)
    case permissionDenied
    case invalidImage
    case invalidVideo
    
    var errorDescription: String? {
        switch self {
        case .invalidFileType:
            return "This file type is not supported"
        case .fileTooLarge:
            return "File is too large. Please choose a smaller file."
        case .compressionFailed:
            return "Failed to compress media"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .permissionDenied:
            return "Permission denied. Please enable access in Settings."
        case .invalidImage:
            return "Invalid or corrupted image"
        case .invalidVideo:
            return "Invalid or corrupted video"
        }
    }
}
