//
//  SecretConfig.swift
//  boilerplate
//

import Foundation

enum SecretConfig {
    static func value(for key: String) -> String {
        // 1. Try Environment Variable (Local Debug)
        if let envVar = ProcessInfo.processInfo.environment[key], !envVar.isEmpty {
            return envVar
        }
        
        // 2. Try Info.plist (Bundled for TestFlight/App Store)
        if let plistVar = Bundle.main.object(forInfoDictionaryKey: key) as? String, !plistVar.isEmpty, plistVar != "$( \(key))" {
            return plistVar
        }
        
        return ""
    }
    
    // LLM Services
    static var geminiAPIKey: String { value(for: "GEMINI_API_KEY") }
    static var openAIAPIKey: String { value(for: "OPENAI_API_KEY") }
    static var replicateAPIToken: String { value(for: "REPLICATE_API_TOKEN") }
    
    // Payments
    static var revenueCatAPIKey: String {
        let key = value(for: "REVENUECAT_API_KEY")
        return key.isEmpty ? "appl_tAGaGojvSDcCIzzbSzPgyJbikfm" : key
    }
    
    // ImageKit
    static var imageKitPublicKey: String { value(for: "IMAGEKIT_PUBLIC_KEY") }
    static var imageKitURL: String { value(for: "IMAGEKIT_URL_ENDPOINT") }
    static var imageKitPrivateKey: String { value(for: "IMAGEKIT_PRIVATE_KEY") }
    
    // Cloudflare R2
    static var r2AccountID: String { value(for: "R2_ACCOUNT_ID") }
    static var r2BucketName: String { value(for: "R2_BUCKET_NAME") }
    static var r2AccessKeyID: String { value(for: "R2_ACCESS_KEY_ID") }
    static var r2SecretAccessKey: String { value(for: "R2_SECRET_ACCESS_KEY") }
    static var r2PublicURLPrefix: String { value(for: "R2_PUBLIC_URL_PREFIX") }
}
