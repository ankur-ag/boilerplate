//
//  FirebaseService.swift
//  boilerplate
//
//  RoastGPT Clone - Firebase integration layer
//  Created by Ankur on 1/12/26.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

/// Firebase service layer for RoastGPT
/// Handles Firestore database operations and Storage
class FirebaseService {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {
        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings
    }
    
    // MARK: - Roast Sessions
    
    /// Save a roast session to Firestore
    /// Path: sessions/{sessionId}
    func saveRoastSession(_ session: RoastSession) async throws {
        let data: [String: Any] = [
            "id": session.id,
            "userId": session.userId,
            "inputText": session.inputText,
            "roastText": session.roastText,
            "imageURL": session.imageURL as Any,
            "ocrText": session.ocrText as Any,
            "timestamp": Timestamp(date: session.timestamp),
            "source": session.source.rawValue
        ]
        
        do {
            try await db.collection("sessions").document(session.id).setData(data)
            print("✅ [Firebase] Session saved: \(session.id)")
        } catch {
            print("❌ [Firebase] Save failed: \(error.localizedDescription)")
            throw FirebaseServiceError.saveFailed(error.localizedDescription)
        }
    }
    
    /// Load all roast sessions for a user
    /// Path: sessions/ where userId == userId
    func loadRoastSessions(userId: String) async throws -> [RoastSession] {
        do {
            let snapshot = try await db.collection("sessions")
                .whereField("userId", isEqualTo: userId)
                .order(by: "timestamp", descending: true)
                .getDocuments()
            
            let sessions = snapshot.documents.compactMap { doc -> RoastSession? in
                let data = doc.data()
                
                guard let id = data["id"] as? String,
                      let userId = data["userId"] as? String,
                      let inputText = data["inputText"] as? String,
                      let roastText = data["roastText"] as? String,
                      let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
                      let sourceRaw = data["source"] as? String,
                      let source = RoastInputSource(rawValue: sourceRaw) else {
                    print("⚠️ [Firebase] Failed to parse session: \(doc.documentID)")
                    return nil
                }
                
                return RoastSession(
                    id: id,
                    userId: userId,
                    inputText: inputText,
                    roastText: roastText,
                    imageURL: data["imageURL"] as? String,
                    ocrText: data["ocrText"] as? String,
                    timestamp: timestamp,
                    source: source
                )
            }
            
            print("✅ [Firebase] Loaded \(sessions.count) sessions")
            return sessions
            
        } catch {
            print("❌ [Firebase] Load failed: \(error.localizedDescription)")
            throw FirebaseServiceError.loadFailed(error.localizedDescription)
        }
    }
    
    /// Delete a roast session
    /// Path: sessions/{sessionId}
    func deleteRoastSession(_ sessionId: String) async throws {
        do {
            try await db.collection("sessions").document(sessionId).delete()
            print("✅ [Firebase] Session deleted: \(sessionId)")
        } catch {
            print("❌ [Firebase] Delete failed: \(error.localizedDescription)")
            throw FirebaseServiceError.deleteFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Usage Tracking
    
    /// Track user usage for rate limiting / analytics
    /// Path: usage/{userId}
    func trackUsage(userId: String, tokensUsed: Int) async throws {
        let userUsageRef = db.collection("usage").document(userId)
        
        do {
            try await userUsageRef.setData([
                "userId": userId,
                "roastsGenerated": FieldValue.increment(Int64(1)),
                "lastRoastAt": Timestamp(date: Date()),
                "totalTokensUsed": FieldValue.increment(Int64(tokensUsed))
            ], merge: true)
            
            print("✅ [Firebase] Usage tracked for user: \(userId)")
        } catch {
            // Don't throw - usage tracking is non-critical
            print("⚠️ [Firebase] Usage tracking failed: \(error.localizedDescription)")
        }
    }
    
    /// Get user usage stats
    func getUserUsage(userId: String) async throws -> UserUsage {
        do {
            let doc = try await db.collection("usage").document(userId).getDocument()
            
            guard let data = doc.data() else {
                // Return empty usage if document doesn't exist
                return UserUsage(
                    userId: userId,
                    roastsGenerated: 0,
                    lastRoastAt: Date(),
                    totalTokensUsed: 0
                )
            }
            
            return UserUsage(
                userId: userId,
                roastsGenerated: data["roastsGenerated"] as? Int ?? 0,
                lastRoastAt: (data["lastRoastAt"] as? Timestamp)?.dateValue() ?? Date(),
                totalTokensUsed: data["totalTokensUsed"] as? Int ?? 0
            )
            
        } catch {
            print("⚠️ [Firebase] Failed to get usage: \(error.localizedDescription)")
            // Return empty usage on error
            return UserUsage(
                userId: userId,
                roastsGenerated: 0,
                lastRoastAt: Date(),
                totalTokensUsed: 0
            )
        }
    }
    
    // MARK: - Image Storage
    
    /// Upload image data to Firebase Storage
    /// Path: images/{userId}/{sessionId}.jpg
    func uploadImage(_ imageData: Data, userId: String, sessionId: String) async throws -> String {
        let ref = storage.reference().child("images/\(userId)/\(sessionId).jpg")
        
        do {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            _ = try await ref.putDataAsync(imageData, metadata: metadata)
            let url = try await ref.downloadURL()
            
            print("✅ [Firebase] Image uploaded: \(sessionId)")
            return url.absoluteString
            
        } catch {
            print("❌ [Firebase] Image upload failed: \(error.localizedDescription)")
            throw FirebaseServiceError.uploadFailed(error.localizedDescription)
        }
    }
    
    /// Delete image from Firebase Storage
    func deleteImage(url: String) async throws {
        do {
            let ref = storage.reference(forURL: url)
            try await ref.delete()
            print("✅ [Firebase] Image deleted: \(url)")
        } catch {
            print("⚠️ [Firebase] Image delete failed: \(error.localizedDescription)")
            // Don't throw - image deletion is non-critical
        }
    }
}

// MARK: - Firebase Service Errors

enum FirebaseServiceError: LocalizedError {
    case notInitialized
    case saveFailed(String)
    case loadFailed(String)
    case deleteFailed(String)
    case uploadFailed(String)
    case imageConversionFailed
    
    var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Firebase is not initialized"
        case .saveFailed(let message):
            return "Failed to save data: \(message)"
        case .loadFailed(let message):
            return "Failed to load data: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete data: \(message)"
        case .uploadFailed(let message):
            return "Failed to upload file: \(message)"
        case .imageConversionFailed:
            return "Failed to convert image to data"
        }
    }
}

// MARK: - User Usage Model

struct UserUsage: Codable {
    let userId: String
    let roastsGenerated: Int
    let lastRoastAt: Date
    let totalTokensUsed: Int
}
