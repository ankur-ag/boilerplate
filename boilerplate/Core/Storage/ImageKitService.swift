//
//  ImageKitService.swift
//  boilerplate
//
//  Service for uploading files to ImageKit.io
//

import Foundation

class ImageKitService {
    static let shared = ImageKitService()
    
    private let publicKey: String
    private let privateKey: String
    private let urlEndpoint: String
    
    private init() {
        self.publicKey = ProcessInfo.processInfo.environment["IMAGEKIT_PUBLIC_KEY"] ?? ""
        self.privateKey = ProcessInfo.processInfo.environment["IMAGEKIT_PRIVATE_KEY"] ?? ""
        self.urlEndpoint = ProcessInfo.processInfo.environment["IMAGEKIT_URL_ENDPOINT"] ?? ""
    }
    
    var isConfigured: Bool {
        !privateKey.isEmpty && !urlEndpoint.isEmpty
    }
    
    /// Upload image data to ImageKit
    func uploadImage(_ imageData: Data, fileName: String) async throws -> String {
        guard isConfigured else {
            throw ImageKitError.notConfigured
        }
        
        let url = URL(string: "https://upload.imagekit.io/api/v1/files/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Basic Auth with Private Key
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
            mimeType: "image/png"
        )
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ImageKitError.uploadFailed("Network error")
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            throw ImageKitError.uploadFailed("HTTP \(httpResponse.statusCode)")
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let urlString = json["url"] as? String else {
            throw ImageKitError.uploadFailed("Invalid response format")
        }
        
        return urlString
    }
    
    private func createMultipartBody(data: Data, boundary: String, fileName: String, mimeType: String) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"fileName\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(fileName)\r\n".data(using: .utf8)!)
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
