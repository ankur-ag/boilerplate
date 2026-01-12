//
//  FirebaseService.swift
//  boilerplate
//
//  RoastGPT Clone - Firebase integration layer
//  Created by Ankur on 1/12/26.
//

import Foundation

/// Firebase service layer for RoastGPT
/// TODO: Implement actual Firebase calls when Firebase SDK is added
class FirebaseService {
    
    // MARK: - Roast Sessions
    
    /// Save a roast session to Firestore
    /// Path: sessions/{sessionId}
    func saveRoastSession(_ session: RoastSession) async throws {
        // TODO: Implement Firebase Firestore save
        // Example:
        // let db = Firestore.firestore()
        // try await db.collection("sessions").document(session.id).setData(session.toDictionary())
        
        print("📝 [Firebase] Saving roast session: \(session.id)")
        
        // For now, just simulate success
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
    }
    
    /// Load all roast sessions for a user
    /// Path: sessions (where userId == userId)
    func loadRoastSessions(userId: String) async throws -> [RoastSession] {
        // TODO: Implement Firebase Firestore query
        // Example:
        // let db = Firestore.firestore()
        // let query = db.collection("sessions")
        //     .whereField("userId", isEqualTo: userId)
        //     .order(by: "timestamp", descending: true)
        // let snapshot = try await query.getDocuments()
        // return snapshot.documents.compactMap { RoastSession(from: $0.data()) }
        
        print("📚 [Firebase] Loading roast sessions for user: \(userId)")
        
        // For now, return empty array
        return []
    }
    
    /// Delete a roast session
    func deleteRoastSession(sessionId: String, userId: String) async throws {
        // TODO: Implement Firebase Firestore delete
        // Example:
        // let db = Firestore.firestore()
        // try await db.collection("sessions").document(sessionId).delete()
        
        print("🗑️ [Firebase] Deleting roast session: \(sessionId)")
        
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2s
    }
    
    // MARK: - Usage Tracking
    
    /// Track user usage
    /// Path: usage/{userId}
    func trackUsage(userId: String, sessionId: String) async throws {
        // TODO: Implement Firebase Firestore usage tracking
        // Example:
        // let db = Firestore.firestore()
        // let usageRef = db.collection("usage").document(userId)
        // try await usageRef.setData([
        //     "lastRoastAt": FieldValue.serverTimestamp(),
        //     "totalRoasts": FieldValue.increment(Int64(1)),
        //     "sessions": FieldValue.arrayUnion([sessionId])
        // ], merge: true)
        
        print("📊 [Firebase] Tracking usage for user: \(userId)")
    }
    
    /// Get user usage statistics
    func getUserUsage(userId: String) async throws -> UserUsage {
        // TODO: Implement Firebase Firestore query
        // Example:
        // let db = Firestore.firestore()
        // let doc = try await db.collection("usage").document(userId).getDocument()
        // return UserUsage(from: doc.data())
        
        print("📈 [Firebase] Getting usage for user: \(userId)")
        
        return UserUsage(userId: userId, totalRoasts: 0, lastRoastAt: nil)
    }
    
    // MARK: - Image Storage
    
    /// Upload image to Firebase Storage
    /// Path: images/{userId}/{sessionId}.jpg
    func uploadImage(_ image: UIImage, userId: String, sessionId: String) async throws -> String {
        // TODO: Implement Firebase Storage upload
        // Example:
        // let storage = Storage.storage()
        // let ref = storage.reference().child("images/\(userId)/\(sessionId).jpg")
        // guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        //     throw FirebaseServiceError.imageConversionFailed
        // }
        // _ = try await ref.putDataAsync(imageData)
        // let url = try await ref.downloadURL()
        // return url.absoluteString
        
        print("📤 [Firebase] Uploading image for session: \(sessionId)")
        
        // Return mock URL
        return "https://firebasestorage.googleapis.com/mock/\(sessionId).jpg"
    }
    
    /// Delete image from Firebase Storage
    func deleteImage(url: String) async throws {
        // TODO: Implement Firebase Storage delete
        // Example:
        // let storage = Storage.storage()
        // let ref = storage.reference(forURL: url)
        // try await ref.delete()
        
        print("🗑️ [Firebase] Deleting image: \(url)")
    }
}

// MARK: - User Usage Model

struct UserUsage {
    let userId: String
    let totalRoasts: Int
    let lastRoastAt: Date?
    let sessions: [String]
    
    init(userId: String, totalRoasts: Int, lastRoastAt: Date?, sessions: [String] = []) {
        self.userId = userId
        self.totalRoasts = totalRoasts
        self.lastRoastAt = lastRoastAt
        self.sessions = sessions
    }
}

// MARK: - Firebase Service Error

enum FirebaseServiceError: LocalizedError {
    case imageConversionFailed
    case uploadFailed
    case downloadFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image"
        case .uploadFailed:
            return "Failed to upload to Firebase"
        case .downloadFailed:
            return "Failed to download from Firebase"
        case .deleteFailed:
            return "Failed to delete from Firebase"
        }
    }
}

// MARK: - Extensions for Firebase Conversion

extension RoastSession {
    /// Convert to dictionary for Firebase
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "userId": userId,
            "inputText": inputText,
            "roastText": roastText,
            "timestamp": timestamp,
            "regenerationCount": regenerationCount
        ]
        
        if let imageURL = imageURL {
            dict["imageURL"] = imageURL
        }
        
        if let ocrText = ocrText {
            dict["ocrText"] = ocrText
        }
        
        return dict
    }
    
    /// Initialize from Firebase dictionary
    init?(from dict: [String: Any]) {
        guard let id = dict["id"] as? String,
              let userId = dict["userId"] as? String,
              let inputText = dict["inputText"] as? String,
              let roastText = dict["roastText"] as? String,
              let timestamp = dict["timestamp"] as? Date else {
            return nil
        }
        
        self.id = id
        self.userId = userId
        self.inputText = inputText
        self.roastText = roastText
        self.timestamp = timestamp
        self.imageURL = dict["imageURL"] as? String
        self.ocrText = dict["ocrText"] as? String
        self.regenerationCount = dict["regenerationCount"] as? Int ?? 0
    }
}
