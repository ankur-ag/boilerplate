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
    
    static var geminiAPIKey: String { value(for: "GEMINI_API_KEY") }
    static var openAIAPIKey: String { value(for: "OPENAI_API_KEY") }
    static var revenueCatAPIKey: String {
        let key = value(for: "REVENUECAT_API_KEY")
        return key.isEmpty ? "appl_tAGaGojvSDcCIzzbSzPgyJbikfm" : key
    }
}
