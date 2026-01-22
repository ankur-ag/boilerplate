//
//  ImageKitService.swift
//  boilerplate
//
//  Created by Antigravity on 1/22/26.
//

import Foundation

/// Service for uploading files to ImageKit.io
class ImageKitService {
    static let shared = ImageKitService()
    
    private let publicKey: String
    private let privateKey: String
    private let urlEndpoint: String
    
    // Hardcoded for now based on typical setup, or could be env vars
    // User hasn't provided keys yet, so we'll check Env or default to empty
    
    private init() {
        self.publicKey = ProcessInfo.processInfo.environment["IMAGEKIT_PUBLIC_KEY"] ?? ""
        self.privateKey = ProcessInfo.processInfo.environment["IMAGEKIT_PRIVATE_KEY"] ?? ""
        self.urlEndpoint = ProcessInfo.processInfo.environment["IMAGEKIT_URL_ENDPOINT"] ?? ""
    }
    
    var isConfigured: Bool {
        !privateKey.isEmpty && !urlEndpoint.isEmpty
    }
    
    /// Upload image data to ImageKit
    /// - Parameters:
    ///   - imageData: The raw PNG/JPG data
    ///   - fileName: The destination filename
    /// - Returns: The public URL of the uploaded image
    func uploadImage(_ imageData: Data, fileName: String) async throws -> String {
        guard isConfigured else {
            // Log for debugging
            print("⚠️ ImageKit not configured. Missing IMAGEKIT_PRIVATE_KEY or IMAGEKIT_URL_ENDPOINT.")
            throw ImageKitError.notConfigured
        }
        
        let url = URL(string: "https://upload.imagekit.io/api/v1/files/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Basic Auth with Private Key (Password is empty)
        let authString = "\(privateKey):"
        if let authData = authString.data(using: .utf8) {
            let base64Auth = authData.base64EncodedString()
            request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization")
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartBody(
            data: imageData,
            boundary: boundary,
            fileName: fileName,
            mimeType: "image/png" // Assuming PNG based on previous context, but ImageKit handles others
        )
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ImageKitError.uploadFailed("Network error")
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
             if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                 print("❌ [ImageKit] Error: \(errorJson)")
             }
            throw ImageKitError.uploadFailed("HTTP \(httpResponse.statusCode)")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let urlString = json["url"] as? String else {
            throw ImageKitError.uploadFailed("Invalid response format")
        }
        
        print("✅ [ImageKit] Uploaded: \(urlString)")
        return urlString
    }
    
    private func createMultipartBody(data: Data, boundary: String, fileName: String, mimeType: String) -> Data {
        var body = Data()
        
        // File Data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        
        // Filename parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"fileName\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(fileName)\r\n".data(using: .utf8)!)
        
        // Use Unique Filename = false to overwrite if needed, or true to ensure safety.
        // Let's use false to control names via our own logic if possible, or true by default.
        // ImageKit default is usually checking existence.
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

enum ImageKitError: LocalizedError {
    case notConfigured
    case uploadFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured: return "ImageKit service is not configured."
        case .uploadFailed(let msg): return "ImageKit upload failed: \(msg)"
        }
    }
}
