//
//  CloudflareR2Service.swift
//  boilerplate
//
//  Created by Antigravity on 1/22/26.
//

import Foundation
import CryptoKit

/// Service for uploading files to Cloudflare R2 using S3-compatible API
class CloudflareR2Service {
    static let shared = CloudflareR2Service()
    
    private let accountID: String
    private let bucketName: String
    private let accessKeyID: String
    private let secretAccessKey: String
    private let publicURLPrefix: String
    
    private init() {
        self.accountID = (ProcessInfo.processInfo.environment["R2_ACCOUNT_ID"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.bucketName = (ProcessInfo.processInfo.environment["R2_BUCKET_NAME"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.accessKeyID = (ProcessInfo.processInfo.environment["R2_ACCESS_KEY_ID"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.secretAccessKey = (ProcessInfo.processInfo.environment["R2_SECRET_ACCESS_KEY"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.publicURLPrefix = (ProcessInfo.processInfo.environment["R2_PUBLIC_URL_PREFIX"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var r2Host: String {
        "\(bucketName).\(accountID).r2.cloudflarestorage.com"
    }
    
    var isConfigured: Bool {
        !accountID.isEmpty && !bucketName.isEmpty && !accessKeyID.isEmpty && !secretAccessKey.isEmpty
    }
    
    /// Upload image data to R2 asynchronously
    /// - Parameters:
    ///   - imageData: The raw PNG/JPG data
    ///   - fileName: The destination path within the bucket
    /// - Returns: The public URL or the R2 endpoint URL
    func uploadImage(_ imageData: Data, fileName: String) async throws -> String {
        guard isConfigured else {
            throw R2Error.notConfigured
        }
        
        let host = r2Host
        let endpoint = "https://\(host)/\(fileName)"
        guard let url = URL(string: endpoint) else {
            throw R2Error.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let contentType = "image/png"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // AWS SigV4 implementation
        let now = Date()
        let amzDate = ISO8601DateFormatter.s3Timestamp(from: now)
        let dateStamp = ISO8601DateFormatter.s3DateOnly(from: now)
        
        request.setValue(amzDate, forHTTPHeaderField: "x-amz-date")
        request.setValue(host, forHTTPHeaderField: "Host")
        
        // Content Hash
        let contentHash = SHA256.hash(data: imageData).compactMap { String(format: "%02x", $0) }.joined()
        request.setValue(contentHash, forHTTPHeaderField: "x-amz-content-sha256")
        
        // Signing
        let region = "auto"
        let service = "s3"
        let credentialScope = "\(dateStamp)/\(region)/\(service)/aws4_request"
        
        // Canonical Request
        let canonicalUri = "/\(fileName)"
        let canonicalQueryString = ""
        let canonicalHeaders = "content-type:\(contentType)\nhost:\(host)\nx-amz-content-sha256:\(contentHash)\nx-amz-date:\(amzDate)\n"
        let signedHeaders = "content-type;host;x-amz-content-sha256;x-amz-date"
        let canonicalRequest = "PUT\n\(canonicalUri)\n\(canonicalQueryString)\n\(canonicalHeaders)\n\(signedHeaders)\n\(contentHash)"
        
        let canonicalRequestHash = SHA256.hash(data: canonicalRequest.data(using: .utf8)!).compactMap { String(format: "%02x", $0) }.joined()
        
        // String to Sign
        let stringToSign = "AWS4-HMAC-SHA256\n\(amzDate)\n\(credentialScope)\n\(canonicalRequestHash)"
        
        // Calculate Signature
        let signingKey = getSignatureKey(key: secretAccessKey, dateStamp: dateStamp, regionName: region, serviceName: service)
        let signature = hmac(stringToSign, key: signingKey)
        
        let authorizationHeader = "AWS4-HMAC-SHA256 Credential=\(accessKeyID)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)"
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        
        // Upload
        let (data, response) = try await URLSession.shared.upload(for: request, from: imageData)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw R2Error.uploadFailed("HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0): \(errorBody)")
        }
        
        // Return the final URL. Use public prefix if available, otherwise return bucket-level endpoint.
        if !publicURLPrefix.isEmpty {
            var cleanPrefix = publicURLPrefix.hasSuffix("/") ? String(publicURLPrefix.dropLast()) : publicURLPrefix
            if !cleanPrefix.hasPrefix("http") {
                cleanPrefix = "https://\(cleanPrefix)"
            }
            let cleanFileName = fileName.hasPrefix("/") ? String(fileName.dropFirst()) : fileName
            let url = "\(cleanPrefix)/\(cleanFileName)"
            return url
        } else {
            return endpoint
        }
    }
    
    /// Converts an internal R2 bucket URL to a public URL if a prefix is configured
    func publicizeURL(_ originalURL: String) -> String {
        guard !publicURLPrefix.isEmpty, !originalURL.isEmpty else { return originalURL }
        
        let host = r2Host
        let internalPrefix = "https://\(host)/"
        
        if originalURL.hasPrefix(internalPrefix) {
            let fileName = originalURL.replacingOccurrences(of: internalPrefix, with: "")
            var cleanPrefix = publicURLPrefix.hasSuffix("/") ? String(publicURLPrefix.dropLast()) : publicURLPrefix
            if !cleanPrefix.hasPrefix("http") {
                cleanPrefix = "https://\(cleanPrefix)"
            }
            return "\(cleanPrefix)/\(fileName)"
        }
        
        // If it's already a non-internal URL but missing prefix, still ensure https
        // But DON'T touch local file URLs
        var finalURL = originalURL
        if !finalURL.hasPrefix("http") && !finalURL.hasPrefix("file") && !finalURL.isEmpty {
            finalURL = "https://\(finalURL)"
        }
        
        return finalURL
    }
    
    // MARK: - Crypto Helpers
    
    private func hmac(_ string: String, key: SymmetricKey) -> String {
        let signature = HMAC<SHA256>.authenticationCode(for: string.data(using: .utf8)!, using: key)
        return signature.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func hmacHexToKey(_ hex: String, key: SymmetricKey) -> SymmetricKey {
        let data = hex.data(using: .utf8)!
        let signature = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return SymmetricKey(data: signature)
    }
    
    private func hmacDataToKey(_ data: Data, key: SymmetricKey) -> SymmetricKey {
        let signature = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return SymmetricKey(data: signature)
    }
    
    private func getSignatureKey(key: String, dateStamp: String, regionName: String, serviceName: String) -> SymmetricKey {
        let kDate = hmacDataToKey(dateStamp.data(using: .utf8)!, key: SymmetricKey(data: "AWS4\(key)".data(using: .utf8)!))
        let kRegion = hmacDataToKey(regionName.data(using: .utf8)!, key: kDate)
        let kService = hmacDataToKey(serviceName.data(using: .utf8)!, key: kRegion)
        let kSigning = hmacDataToKey("aws4_request".data(using: .utf8)!, key: kService)
        return kSigning
    }
}

// MARK: - Errors

enum R2Error: LocalizedError {
    case notConfigured
    case invalidURL
    case uploadFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured: return "Cloudflare R2 environment variables not found."
        case .invalidURL: return "Invalid R2 URL constructed."
        case .uploadFailed(let msg): return "R2 Upload failed: \(msg)"
        }
    }
}

// MARK: - Date Formatting

extension ISO8601DateFormatter {
    static func s3Timestamp(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withYear, .withMonth, .withDay, .withTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let formatted = formatter.string(from: date).replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ":", with: "")
        // ISO8601 string already has Z, but replacing occurrences might have removed it if it was part of time.
        // Usually it's YYYYMMDDTHHmmSSZ
        if !formatted.hasSuffix("Z") {
            return formatted + "Z"
        }
        return formatted
    }
    
    static func s3DateOnly(from date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withYear, .withMonth, .withDay]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date).replacingOccurrences(of: "-", with: "")
    }
}
