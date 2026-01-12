//
//  StorageManager.swift
//  boilerplate
//
//  Created by Ankur on 1/12/26.
//

import Foundation

/// Protocol for data persistence
protocol StorageManaging {
    func save<T: Codable>(_ value: T, forKey key: String) throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T?
    func delete(forKey key: String)
    func clear()
}

/// Local storage manager using UserDefaults and FileManager
class StorageManager: StorageManaging {
    private let userDefaults: UserDefaults
    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(userDefaults: UserDefaults = .standard, fileManager: FileManager = .default) {
        self.userDefaults = userDefaults
        self.fileManager = fileManager
    }
    
    // MARK: - UserDefaults Storage
    
    func save<T: Codable>(_ value: T, forKey key: String) throws {
        let data = try encoder.encode(value)
        userDefaults.set(data, forKey: key)
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        return try decoder.decode(type, from: data)
    }
    
    func delete(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    func clear() {
        if let bundleId = Bundle.main.bundleIdentifier {
            userDefaults.removePersistentDomain(forName: bundleId)
        }
    }
    
    // MARK: - File Storage
    
    func saveToFile<T: Codable>(_ value: T, filename: String) throws {
        let url = try getDocumentsDirectory().appendingPathComponent(filename)
        let data = try encoder.encode(value)
        try data.write(to: url)
    }
    
    func loadFromFile<T: Codable>(_ type: T.Type, filename: String) throws -> T? {
        let url = try getDocumentsDirectory().appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: url)
        return try decoder.decode(type, from: data)
    }
    
    func deleteFile(filename: String) throws {
        let url = try getDocumentsDirectory().appendingPathComponent(filename)
        
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    // MARK: - Helpers
    
    private func getDocumentsDirectory() throws -> URL {
        try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
}

// MARK: - Storage Keys

enum StorageKeys {
    static let currentUser = "current_user"
    static let conversations = "conversations"
    static let appConfig = "app_config"
    static let subscriptionStatus = "subscription_status"
}
